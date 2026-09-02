/*
 * Stage 0 feasibility spike — the "firmware" side, loaded via dlmopen.
 *
 * Mirrors the parts of the FreeRTOS POSIX port that matter for the SITL plan:
 *   - a global in .bss whose isolation across dlmopen namespaces we want to prove
 *   - a worker ("task") pthread handed off to/from the host via condition
 *     variables (the port uses event_wait/event_signal the same way)
 *   - a pthread_key for thread-local identity (the port's prvIsFreeRTOSThread)
 *   - a host-driven tick: the host calls spike_tick(), NO signals anywhere
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

/* Lives in .bss — must be independent per dlmopen namespace. */
static uint64_t g_tick_count = 0;
static uint64_t g_task_ran = 0;

static pthread_t        worker;
static pthread_mutex_t  m   = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t   cv  = PTHREAD_COND_INITIALIZER;
static int              run_token = 0;   /* host -> worker: please run */
static int              done_token = 0;  /* worker -> host: finished a step */
static int              stop = 0;

static pthread_key_t    id_key;
static const char       host_id[] = "HOST";
static const char       task_id[] = "TASK";
static const char       *g_worker_saw = "(unset)";

/* Like the port's prvIsFreeRTOSThread(): identify the calling thread via TLS. */
const char *spike_whoami(void)
{
    void *v = pthread_getspecific(id_key);
    return v ? (const char *)v : "(none)";
}

/* What the worker thread observed for its own TLS identity. */
const char *spike_worker_saw(void) { return g_worker_saw; }

static void *worker_main(void *arg)
{
    (void)arg;
    pthread_setspecific(id_key, (void *)task_id);
    g_worker_saw = spike_whoami();

    pthread_mutex_lock(&m);
    for (;;) {
        while (!run_token && !stop)
            pthread_cond_wait(&cv, &m);
        if (stop) break;
        run_token = 0;

        /* "task body": touch the .bss global. */
        g_task_ran++;

        done_token = 1;
        pthread_cond_signal(&cv);
    }
    pthread_mutex_unlock(&m);
    return NULL;
}

void spike_init(void)
{
    pthread_key_create(&id_key, NULL);
    pthread_setspecific(id_key, (void *)host_id);
    g_worker_saw = "(unset)";
    g_tick_count = 0;
    g_task_ran = 0;
    stop = 0;
    pthread_create(&worker, NULL, worker_main, NULL);
}

/* Host-driven tick: advance virtual time and run the worker one step. No signal. */
void spike_tick(void)
{
    g_tick_count++;

    pthread_mutex_lock(&m);
    run_token = 1;
    pthread_cond_signal(&cv);
    while (!done_token)
        pthread_cond_wait(&cv, &m);
    done_token = 0;
    pthread_mutex_unlock(&m);
}

uint64_t spike_ticks(void)    { return g_tick_count; }
uint64_t spike_task_runs(void){ return g_task_ran; }

void spike_shutdown(void)
{
    pthread_mutex_lock(&m);
    stop = 1;
    pthread_cond_signal(&cv);
    pthread_mutex_unlock(&m);
    pthread_join(worker, NULL);
    pthread_key_delete(id_key);
}
