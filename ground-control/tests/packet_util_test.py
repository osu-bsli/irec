from utils import packet_util

def test_get_packet_types():
    assert list(packet_util.get_packet_types(
        packet_util.PACKET_TYPE_ACCELERATION + packet_util.PACKET_TYPE_ALTITUDE
    )) == [
        packet_util.PACKET_TYPE_ALTITUDE,
        packet_util.PACKET_TYPE_ACCELERATION,
    ]