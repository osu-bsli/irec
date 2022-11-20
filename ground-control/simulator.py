"""
Simulates launch using telmetry data from summer 2022.
"""

from utils import packet_util
import serial

if __name__ == '__main__':
    port = serial.Serial(
        port='COM1',
        baudrate=9600,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )
    