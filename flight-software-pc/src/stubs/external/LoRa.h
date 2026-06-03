#pragma once

#include <cstdint>
#include <cstddef>
#include <cstdlib>
#include <cstdio>

#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <errno.h>

#include <SPI.h>

#include "shared.h"

#define STUB_LORA_SOCKET_IS_CLIENT 0
#define STUB_LORA_SOCKET_IS_SERVER 1

class LoRaClass
{
private:
    uint32_t _frf = 0;
    int _isClientOrServer = STUB_LORA_SOCKET_IS_SERVER;

    /* Unix socket for connection simulation */
    int _socket_fd = -1;

    void disconnect_socket()
    {
        if (_socket_fd >= 0) { close(_socket_fd); _socket_fd = -1; }
    }

public:
    bool has_begun = 0;

    int begin(long frequency)
    {
        this->disconnect_socket();
        has_begun = 1;

        /* Open Unix socket for connection simulation */
        _socket_fd = socket(AF_UNIX, SOCK_STREAM, 0);
        stub_println("Obtained Unix socket fd: %d", _socket_fd);
        
        /* Enable SO_REUSEADDR (set to 1) so socket file is reusable after process exit */
        int opt = 1;
        setsockopt(_socket_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

        if (_socket_fd < 0) return false;

        const char *runtime_dir = getenv("XDG_RUNTIME_DIR");

        sockaddr_un addr{};
        memset(&addr, 0, sizeof(struct sockaddr_un));
        addr.sun_family = AF_UNIX;
        snprintf(addr.sun_path, sizeof(addr.sun_path), "%sflight-software-pc.sock", runtime_dir);

        if (_isClientOrServer == STUB_LORA_SOCKET_IS_SERVER) {
            /* Delete existing socket file (binding socket will fail if file already exists) */
            unlink(addr.sun_path);

            stub_println("Attempting to bind to Unix socket as server: %s", addr.sun_path);
    
            if (bind(_socket_fd, (sockaddr*)(&addr), sizeof(addr)) < 0) {
                stub_println("Unix socket failed to bind");
                this->disconnect_socket();
                return false;
            }

            if (listen(_socket_fd, 5) == -1)
            {
                stub_println("Unix socket failed to listen");
                this->disconnect_socket();
                return false;
            }
        } else {
            stub_println("Attempting to connect to Unix socket as client: %s", addr.sun_path);
    
            if (connect(_socket_fd, (sockaddr*)(&addr), sizeof(addr)) < 0) {
                stub_println("Unix socket failed to connect");
                this->disconnect_socket();
                return false;
            }
        }

        stub_println("Unix socket successfully opened");

        return true;
    }

    void setClientOrServer(int val)
    {
        _isClientOrServer = val;
    }

    long getFrequency() {
        // return (_frf * 32000000) >> 19;
        return 123456789;
    }
    void setFrequency(long frequency) {
        _frf = ((uint64_t)frequency << 19) / 32000000;
    }
    void setSignalBandwidth(long sbw) {}

    int packetRssi()
    {
        return -123456789;
    }

    int beginPacket(int implicitHeader = false) { return 1; }
    int endPacket(bool async = false) { return 1; }

    int read() {
        if (_socket_fd < 0) return -1;
        uint8_t c;
        ssize_t n = recv(_socket_fd, &c, 1, MSG_DONTWAIT);          // non-blocking
        return (n == 1) ? (int)(c) : -1;
    }

    size_t write(uint8_t byte) { return this->write(&byte, 1); }
    size_t write(const uint8_t *buffer, size_t size) {
        if (_socket_fd < 0) return 0;
        size_t total = 0;
        while (total < size) {                                  // handle short writes
            ssize_t n = ::write(_socket_fd, buffer + total, size - total);
            if (n < 0) {
                if (errno == EINTR) continue;
                break;
            }
            total += (size_t)(n);
        }
        return total;
     }

    void receive(int size = 0) {}

    void setGain(uint8_t gain) {};

    void setPins(int ss = 0, int reset = 0, int dio0 = 0) {}
    void setSPI(SPIClass &spi) {}

    void onReceive(void (*callback)(int)) {}
};

extern LoRaClass LoRa;