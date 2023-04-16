import ctypes
import sys

_BUFFER_SIZE = 1024

class Packet(ctypes.Structure):
    _fields_ = [
        ('is_ready', ctypes.c_int), # it's actually an int but should be fine
        ('type', ctypes.c_ubyte),
        ('timestamp', ctypes.c_float),

        # arm status
        ('arm_status_1', ctypes.c_int), # actually an int
        ('arm_status_2', ctypes.c_int), # actually an int
        ('arm_status_3', ctypes.c_int), # actually an int

        # altitude
        ('altitude_1', ctypes.c_float),
        ('altitude_2', ctypes.c_float),

        # acceleration
        ('acceleration_x', ctypes.c_float),
        ('acceleration_y', ctypes.c_float),
        ('acceleration_z', ctypes.c_float),

        # gps coordinates
        ('gps_latitude', ctypes.c_float),
        ('gps_longitude', ctypes.c_float),

        # board temperature
        ('board_1_temperature', ctypes.c_float),
        ('board_2_temperature', ctypes.c_float),
        ('board_3_temperature', ctypes.c_float),
        ('board_4_temperature', ctypes.c_float),

        # board voltage
        ('board_1_voltage', ctypes.c_float),
        ('board_2_voltage', ctypes.c_float),
        ('board_3_voltage', ctypes.c_float),
        ('board_4_voltage', ctypes.c_float),

        # board current
        ('board_1_current', ctypes.c_float),
        ('board_2_current', ctypes.c_float),
        ('board_3_current', ctypes.c_float),
        ('board_4_current', ctypes.c_float),

        # battery voltage
        ('battery_1_voltage', ctypes.c_float),
        ('battery_2_voltage', ctypes.c_float),
        ('battery_3_voltage', ctypes.c_float),

        # magnetometer
        ('magnetometer_1', ctypes.c_float),
        ('magnetometer_2', ctypes.c_float),
        ('magnetometer_3', ctypes.c_float),

        # gyroscope
        ('gyroscope_x', ctypes.c_float),
        ('gyroscope_y', ctypes.c_float),
        ('gyroscope_z', ctypes.c_float),

        # gps satellite count
        ('gps_satellites', ctypes.c_short),

        # gps ground speed
        ('gps_ground_speed', ctypes.c_float),
    ]

class Buffer(ctypes.Structure):
    _fields_ = [
        ('data', ctypes.c_ubyte * _BUFFER_SIZE), # array of c_ubyte
        ('size', ctypes.c_int),
    ]

# Determine the path to the static library (changes base on OS)
_lib_path = ""
if sys.platform.startswith('linux') or sys.platform.startswith('linux2'):
    _lib_path = './libparser_shared.so'
elif sys.platform.startswith('freebsd'):
    _lib_path = './libparser_shared.so'
elif sys.platform.startswith('darwin'):
    _lib_path = './libparser_shared.so'
elif sys.platform.startswith('win32'):
    _lib_path = './libparser_shared.dll'
else:
    print('[ERROR] Packetlib doesn\'t support your OS.');
    exit(1);

# Load the static library
_lib = ctypes.CDLL(_lib_path)

# Set argument and return types for each function
_lib.initialize.argtypes = []
_lib.process.argtypes = []
_lib.enqueue.argtypes = [ctypes.c_ubyte]
_lib.get_packet.argtypes = []
_lib.get_packet.restype = ctypes.POINTER(Packet)
_lib.get_buffer.argtypes = []
_lib.get_buffer.restype = ctypes.POINTER(Buffer)

# Initializes/resets libparser
def initialize() -> None:
    _lib.initialize()

# Processes libparser (attempts to parse packets)
def process() -> None:
    _lib.process()

# Enqueues a byte into libparser's buffer
def enqueue(byte: ctypes.c_ubyte) -> None:
    _lib.enqueue(byte)

def get_packet() -> ctypes.POINTER(Packet):
    return _lib.get_packet()

def get_buffer() -> ctypes.POINTER(Buffer):
    return _lib.get_buffer()

# Sets the `is_ready` flag in a Packet struct to 0
def consume_packet(packet_ptr: ctypes.POINTER(Packet)) -> None:
    packet_ptr.contents.is_ready = 0
