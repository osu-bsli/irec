#include "serial_channel.h"

#include <pthread.h>
#include <deque>

/*
 * Two byte queues bridging the firmware (FreeRTOS tasks) and the host thread.
 * A single mutex guards both; a condition variable lets the host block until
 * the firmware produces a reply byte. The firmware never blocks on the mutex
 * for long (the host only holds it to push/pop), so cooperative scheduling on
 * the firmware side is preserved.
 */
static pthread_mutex_t g_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  g_in_cond = PTHREAD_COND_INITIALIZER;   /* host fed input */
static pthread_cond_t  g_out_cond = PTHREAD_COND_INITIALIZER;  /* firmware replied */
static std::deque<uint8_t> g_in;   /* host -> firmware */
static std::deque<uint8_t> g_out;  /* firmware -> host */

/*
 * The firmware blocks here until the host feeds the next frame, rather than
 * busy-polling. This makes the handoff a deterministic rendezvous (no timing
 * race) and parks the firmware thread while it waits for input. It is safe to
 * block the FreeRTOS task thread here: when the firmware is waiting for the next
 * sensor frame, no other task needs to run (the previous frame is fully
 * processed), so freezing the cooperative scheduler until input arrives is the
 * intended behaviour.
 */
int serial_channel_in_available(void)
{
    pthread_mutex_lock(&g_mutex);
    while (g_in.empty())
        pthread_cond_wait(&g_in_cond, &g_mutex);
    int n = (int)g_in.size();
    pthread_mutex_unlock(&g_mutex);
    return n;
}

int serial_channel_in_read(void)
{
    pthread_mutex_lock(&g_mutex);
    while (g_in.empty())
        pthread_cond_wait(&g_in_cond, &g_mutex);
    int b = g_in.front();
    g_in.pop_front();
    pthread_mutex_unlock(&g_mutex);
    return b;
}

void serial_channel_out_write(uint8_t b)
{
    pthread_mutex_lock(&g_mutex);
    g_out.push_back(b);
    pthread_cond_signal(&g_out_cond);
    pthread_mutex_unlock(&g_mutex);
}

void serial_channel_host_feed(const uint8_t *data, size_t len)
{
    pthread_mutex_lock(&g_mutex);
    for (size_t i = 0; i < len; i++)
        g_in.push_back(data[i]);
    pthread_cond_signal(&g_in_cond);
    pthread_mutex_unlock(&g_mutex);
}

uint8_t serial_channel_host_read_reply(void)
{
    pthread_mutex_lock(&g_mutex);
    while (g_out.empty())
        pthread_cond_wait(&g_out_cond, &g_mutex);
    uint8_t b = g_out.front();
    g_out.pop_front();
    pthread_mutex_unlock(&g_mutex);
    return b;
}

void serial_channel_reset(void)
{
    pthread_mutex_lock(&g_mutex);
    g_in.clear();
    g_out.clear();
    pthread_mutex_unlock(&g_mutex);
}
