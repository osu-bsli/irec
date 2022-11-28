from data_controllers.iliad_data_controller import IliadDataController
from iliad.arm_control import ArmControl
from utils import packet_util
import serial
import pytest
import dearpygui.dearpygui as gui
import time

@pytest.mark.parametrize(
    "camera_status, srad_fc_status, cots_fc_status",
    [
        (False, False, False),
        (False, False, True),
        (False, True, False),
        (False, True, True),
        (True, False, False),
        (True, False, True),
        (True, True, False),
        (True, True, True),
    ]
)
def test_receive_arm_status(camera_status: bool, srad_fc_status: bool, cots_fc_status: bool) -> None:

    # Setup headless gui
    gui.create_context()
    gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
    gui.setup_dearpygui()

    # Get ArmControl instance
    iliad = IliadDataController('test_iliad')
    iliad.set_config({
        'port_name': 'COM2',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    })
    iliad.open()
    arm_control = ArmControl('test_arm_ctl', iliad)

    # Open another port
    port = serial.Serial(
        port='COM1',
        baudrate=9600,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )

    # Do the test
    assert arm_control.is_camera_armed == False
    assert arm_control.is_srad_fc_armed == False
    assert arm_control.is_cots_fc_armed == False
    port.write(
        packet_util.create_packet(packet_util.PACKET_TYPE_ARM_STATUS, time.time(), (camera_status, srad_fc_status, cots_fc_status))
    )
    for i in range(100):
        iliad.update()
        arm_control.update()
    assert arm_control.is_camera_armed == camera_status
    assert arm_control.is_srad_fc_armed == srad_fc_status
    assert arm_control.is_cots_fc_armed == cots_fc_status

    # Clean up
    iliad.close()
    port.close()
    gui.destroy_context()

@pytest.mark.parametrize(
    "arm_statuses",
    [
        [
            (False, False, False),
        ],
        [
            (False, False, False),
            (False, False, False),
            (False, True, False),
            (False, True, False),
        ],
        [
            (False, False, False),
            (False, False, True),
            (False, True, False),
            (False, True, True),
            (True, False, False),
            (True, False, True),
            (True, True, False),
            (True, True, True),
        ],
        [
            (False, False, False),
            (False, True, True),
            (True, True, True),
            (False, True, False),
            (True, False, False),
            (True, True, False),
            (False, False, True),
            (True, False, True),
        ],
    ]
)
def test_receive_multiple_arm_status(arm_statuses: list[tuple[bool, bool, bool]]) -> None:

    # Setup headless gui
    gui.create_context()
    gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
    gui.setup_dearpygui()

    # Get ArmControl instance
    iliad = IliadDataController('test_iliad')
    iliad.set_config({
        'port_name': 'COM2',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    })
    iliad.open()
    arm_control = ArmControl('test_arm_ctl', iliad)

    # Open another port
    port = serial.Serial(
        port='COM1',
        baudrate=9600,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )

    # Do the test
    for status_tuple in arm_statuses:
        port.write(
            packet_util.create_packet(packet_util.PACKET_TYPE_ARM_STATUS, time.time(), (status_tuple[0], status_tuple[1], status_tuple[2]))
        )
        for i in range(100):
            iliad.update()
            arm_control.update()
        assert arm_control.is_camera_armed == status_tuple[0]
        assert arm_control.is_srad_fc_armed == status_tuple[1]
        assert arm_control.is_cots_fc_armed == status_tuple[2]

    # Clean up
    iliad.close()
    port.close()
    gui.destroy_context()