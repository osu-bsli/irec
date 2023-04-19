import packetlib.packet as packet

def test_get_packet_types():
    assert list(packet.get_packet_types(
        packet.PACKET_TYPE_ACCELERATION + packet.PACKET_TYPE_ALTITUDE
    )) == [
        packet.PACKET_TYPE_ALTITUDE,
        packet.PACKET_TYPE_ACCELERATION,
    ]