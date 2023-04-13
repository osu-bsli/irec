import ctypes
import sys

_BUFFER_SIZE = 1024

class Packet(ctypes.Structure):
    _fields_ = [
        ('is_ready', ctypes.c_int), # it's actually an int but should be fine
        ('type', ctypes.c_ubyte),
        ('timestamp', ctypes.c_float),

        # High G accelerometer
        ('high_g_accelerometer_x', ctypes.c_float),
        ('high_g_accelerometer_y', ctypes.c_float),
        ('high_g_accelerometer_z', ctypes.c_float),

        # Gyroscope
        ('gyroscope_x', ctypes.c_float),
        ('gyroscope_y', ctypes.c_float),
        ('gyroscope_z', ctypes.c_float),

        # Accelerometer
        ('accelerometer_x', ctypes.c_float),
        ('accelerometer_y', ctypes.c_float),
        ('accelerometer_z', ctypes.c_float),

        # Barometer
        ('barometer_altitude', ctypes.c_float),

        # GPS
        ('gps_altitude', ctypes.c_float),
        ('gps_satellite_count', ctypes.c_ubyte),
        ('gps_latitude', ctypes.c_float),
        ('gps_longitude', ctypes.c_float),
        ('gps_ascent', ctypes.c_float),
        ('gps_ground_speed', ctypes.c_float),

        # Telemetrum Status
        ('telemetrum_status', ctypes.c_ubyte),
        ('telemetrum_current', ctypes.c_float),
        ('telemetrum_voltage', ctypes.c_float),

        # Stratologger Status
        ('stratologger_status', ctypes.c_ubyte),
        ('stratologger_current', ctypes.c_float),
        ('stratologger_voltage', ctypes.c_float),

        # Camera Status
        ('camera_status', ctypes.c_ubyte),
        ('camera_current', ctypes.c_float),
        ('camera_voltage', ctypes.c_float),

        # Battery Status
        ('battery_voltage', ctypes.c_float),
        ('battery_temperature', ctypes.c_float),
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
