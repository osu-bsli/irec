/*
 * Stage 0 feasibility spike — host side.
 *
 * Loads libspike.so into TWO fresh dlmopen namespaces and drives each with a
 * host clock. Proves, for the SITL plan:
 *   (a) .bss/.data globals isolate per namespace (independent tick/task counts)
 *   (b) a worker pthread + pthread_key TLS work inside a namespace
 *   (c) condvar handoff (the port's context-switch model) works in a namespace
 *   (d) dlclose + reload resets global state
 *   (e) no signals used anywhere
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>

typedef struct {
    void *h;
    void     (*init)(void);
    void     (*tick)(void);
    uint64_t (*ticks)(void);
    uint64_t (*task_runs)(void);
    const char *(*whoami)(void);
    const char *(*worker_saw)(void);
    void     (*shutdown)(void);
} Inst;

static int load(Inst *in, const char *path)
{
    in->h = dlmopen(LM_ID_NEWLM, path, RTLD_NOW | RTLD_LOCAL);
    if (!in->h) { fprintf(stderr, "dlmopen(%s): %s\n", path, dlerror()); return -1; }
    in->init      = dlsym(in->h, "spike_init");
    in->tick      = dlsym(in->h, "spike_tick");
    in->ticks     = dlsym(in->h, "spike_ticks");
    in->task_runs = dlsym(in->h, "spike_task_runs");
    in->whoami    = dlsym(in->h, "spike_whoami");
    in->worker_saw= dlsym(in->h, "spike_worker_saw");
    in->shutdown  = dlsym(in->h, "spike_shutdown");
    if (!in->init || !in->tick || !in->ticks || !in->task_runs || !in->whoami || !in->worker_saw || !in->shutdown) {
        fprintf(stderr, "dlsym: %s\n", dlerror()); return -1;
    }
    return 0;
}

int main(int argc, char **argv)
{
    const char *path = (argc > 1) ? argv[1] : "./libspike.so";

    Lmid_t lmid_a = 0, lmid_b = 0;

    Inst a, b;
    if (load(&a, path)) return 1;
    if (load(&b, path)) return 1;

    /* Confirm the two loads really are in different namespaces. */
    dlinfo(a.h, RTLD_DI_LMID, &lmid_a);
    dlinfo(b.h, RTLD_DI_LMID, &lmid_b);
    printf("namespace A lmid=%ld, namespace B lmid=%ld %s\n",
           (long)lmid_a, (long)lmid_b,
           (lmid_a != lmid_b) ? "(distinct OK)" : "(SAME — FAIL)");

    a.init();
    b.init();

    /* Drive A 5 times, B 2 times — counts must diverge if globals isolate. */
    for (int i = 0; i < 5; i++) a.tick();
    for (int i = 0; i < 2; i++) b.tick();

    printf("A: ticks=%lu task_runs=%lu host_tls=%s worker_tls=%s\n",
           (unsigned long)a.ticks(), (unsigned long)a.task_runs(), a.whoami(), a.worker_saw());
    printf("B: ticks=%lu task_runs=%lu host_tls=%s worker_tls=%s\n",
           (unsigned long)b.ticks(), (unsigned long)b.task_runs(), b.whoami(), b.worker_saw());

    int isolation_ok = (a.ticks() == 5 && b.ticks() == 2 &&
                        a.task_runs() == 5 && b.task_runs() == 2);
    printf("(a) global isolation: %s\n", isolation_ok ? "PASS" : "FAIL");

    /* (b/c) TLS identity: host thread sees HOST, worker thread sees TASK. */
    int tls_ok = (a.whoami()[0]=='H' && b.whoami()[0]=='H' &&
                  a.worker_saw()[0]=='T' && b.worker_saw()[0]=='T');
    printf("(b/c) pthread_key TLS distinguishes host vs worker: %s\n", tls_ok ? "PASS" : "FAIL");

    /* (d) dlclose + reload must reset state. */
    a.shutdown();
    b.shutdown();
    dlclose(a.h);
    dlclose(b.h);

    Inst c;
    if (load(&c, path)) return 1;
    c.init();
    c.tick();
    printf("C (reloaded): ticks=%lu task_runs=%lu\n",
           (unsigned long)c.ticks(), (unsigned long)c.task_runs());
    int reset_ok = (c.ticks() == 1 && c.task_runs() == 1);
    printf("(d) reload resets state: %s\n", reset_ok ? "PASS" : "FAIL");
    c.shutdown();
    dlclose(c.h);

    int all = isolation_ok && reset_ok && tls_ok && lmid_a != lmid_b;
    printf("\nSPIKE %s\n", all ? "PASS" : "FAIL");
    return all ? 0 : 1;
}
