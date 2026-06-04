#pragma once

#include <cstdint>
#include <cstddef>
#include <cstdlib>
#include <cstdio>

#include <sys/socket.h>
#include <sys/epoll.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <errno.h>

#include <SPI.h>

#include "shared.h"
#include <time.h>

#include <FreeRTOS.h>
#include <task.h>

#define STUB_LORA_SOCKET_IS_CLIENT 0
#define STUB_LORA_SOCKET_IS_SERVER 1

static void socket_monitor_task(void *pvParameters);

/*
 * Per-instance suffix appended to the Unix socket path. Default is empty (the
 * standalone flight/ground pair share "flight-software-pc.sock"). The SITL
 * embedding (fw_embed.cpp) overrides this so multiple dlmopen'd firmware
 * instances in one process don't collide on the same socket file.
 */
extern "C" const char *stub_lora_socket_suffix(void);

class LoRaClass
{
private:
    uint32_t _frf = 0;
    int _isClientOrServer = STUB_LORA_SOCKET_IS_SERVER;

    /* Unix socket for connection simulation */
    sockaddr_un _sockaddr{};

    void socket_disconnect()
    {
        if (_socket_fd >= 0)
        {
            close(_socket_fd);
            _socket_fd = -1;
        }
    }

    uint8_t tx_buf[256] = {0};
    int tx_buf_i = 0;
    bool is_in_packet = false;

public:
    int _socket_fd = -1;
    bool has_begun = 0;
    void (*_onReceiveCallback)(int);

    int begin(long frequency)
    {
        if (has_begun)
        {
            return 1;
        }

        this->socket_disconnect();
        has_begun = 1;

        while (true)
        {
            /* Open Unix socket for connection simulation */
            _socket_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
            stub_println("Obtained Unix socket fd: %d", _socket_fd);

            /* Enable SO_REUSEADDR (set to 1) so socket file is reusable after process exit */
            int opt = 1;
            setsockopt(_socket_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

            if (_socket_fd < 0)
                return false;

            const char *runtime_dir = getenv("XDG_RUNTIME_DIR");

            memset(&_sockaddr, 0, sizeof(struct sockaddr_un));
            _sockaddr.sun_family = AF_UNIX;
            snprintf(_sockaddr.sun_path, sizeof(_sockaddr.sun_path), "%sflight-software-pc%s.sock", runtime_dir, stub_lora_socket_suffix());

            if (_isClientOrServer == STUB_LORA_SOCKET_IS_SERVER)
            {
                /* Delete existing socket file (binding socket will fail if file already exists) */
                unlink(_sockaddr.sun_path);

                stub_println("Attempting to bind to Unix socket as server: %s", _sockaddr.sun_path);

                if (bind(_socket_fd, (sockaddr *)(&_sockaddr), sizeof(_sockaddr)) < 0)
                {
                    stub_println("Unix socket failed to bind, reattempting in 1 second...");
                    this->socket_disconnect();
                    vTaskDelay(1000);
                    continue;
                }
            }
            else
            {
                stub_println("Attempting to connect to Unix socket as client: %s", _sockaddr.sun_path);

                if (connect(_socket_fd, (sockaddr *)(&_sockaddr), sizeof(_sockaddr)) < 0)
                {
                    stub_println("Unix socket failed to bind, reattempting in 1 second...");
                    this->socket_disconnect();
                    vTaskDelay(1000);
                    continue;
                }
            }

            stub_println("Unix socket successfully opened");
            break;
        }

        if (_isClientOrServer == STUB_LORA_SOCKET_IS_CLIENT)
        {
            xTaskCreate(socket_monitor_task,      /* The function that implements the task. */
                        "fake_data",              /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                        8192,                     /* The size of the stack to allocate to the task. */
                        NULL,                     /* The parameter passed to the task - not used in this simple case. */
                        configMAX_PRIORITIES - 1, /* The priority assigned to the task. */
                        NULL);                    /* The task handle is not required, so NULL is passed. */
        }

        return true;
    }

    void setClientOrServer(int val)
    {
        _isClientOrServer = val;
    }

    long getFrequency()
    {
        // return (_frf * 32000000) >> 19;
        return 123456789;
    }
    void setFrequency(long frequency)
    {
        _frf = ((uint64_t)frequency << 19) / 32000000;
    }
    void setSignalBandwidth(long sbw) {}

    int packetRssi()
    {
        return -123456789;
    }

    int beginPacket(int implicitHeader = false) { return 1; }
    int endPacket(bool async = false)
    {
        int len = tx_buf_i;
        tx_buf_i = 0;
        const sockaddr_un sockaddr_local = _sockaddr;
        if (sendto(this->_socket_fd, tx_buf, len, 0, (sockaddr *)(&sockaddr_local), sizeof(struct sockaddr_un)) < 0)
        {
            stub_println("Packet failed to send to socket");
        }
        else
        {
            stub_println("Packet sent into socket");
        }
        return len;
    }

    int read()
    {
        if (_socket_fd < 0)
            return -1;
        uint8_t c;
        ssize_t n = recv(_socket_fd, &c, 1, MSG_DONTWAIT); // non-blocking
        return (n == 1) ? (int)(c) : -1;
    }

    size_t write(uint8_t byte) { return this->write(&byte, 1); }
    size_t write(const uint8_t *buffer, size_t size)
    {
        size_t total = 0;
        while (total < size)
        { // handle short writes
            if (sizeof(tx_buf) > tx_buf_i)
            {
                tx_buf[tx_buf_i] = buffer[total];
            }
            total++;
        }
        return total;
    }

    void receive(int size = 0) {}

    void setGain(uint8_t gain) {};

    void setPins(int ss = 0, int reset = 0, int dio0 = 0) {}
    void setSPI(SPIClass &spi) {}

    void onReceive(void (*callback)(int))
    {
        this->_onReceiveCallback = callback;
    }

    void _pump_data_from_socket()
    {
        ssize_t packet_size = recv(_socket_fd, NULL, 0, MSG_TRUNC);
        stub_println("packet size: %d", packet_size);
    }
};

extern LoRaClass LoRa;

static void socket_monitor_task(void *pvParameters)
{
    int epoll_fd = epoll_create1(0);
    if (epoll_fd == -1)
        vTaskDelete(NULL);

    struct epoll_event ev;
    ev.events = EPOLLIN;          // Trigger when data is available to read
    ev.data.fd = LoRa._socket_fd; // Attach our Unix socket file descriptor

    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, LoRa._socket_fd, &ev) == -1)
    {
        close(epoll_fd);
        vTaskDelete(NULL);
    }

    const int MAX_EVENTS = 128;
    struct epoll_event events[MAX_EVENTS];

    // Event loop monitoring the Unix socket
    while (1)
    {
        // This blocks efficiently until data arrives on the socket
        int num_fds = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);

        for (int i = 0; i < num_fds; i++)
        {
            if (events[i].events & EPOLLIN)
            {
                // Execute callback function when data arrives
                LoRa._pump_data_from_socket();
            }
        }
    }
}