from components.app_component import AppComponent
from data_controllers.iliad_data_controller import IliadDataController
import dearpygui.dearpygui as gui

class ArmControl(AppComponent):
    def __init__(self, identifier: str, iliad: IliadDataController) -> None:
        super().__init__(identifier)

        self.iliad = iliad

        self.is_telemetrum_armed = False
        self.is_stratologger_armed = False
        self.is_camera_armed = False

        with gui.tab(label='Arm Control', parent='app.main_tab_bar'):
            with gui.group(horizontal=True):
                gui.add_text('DISARMED', tag=f'{self.identifier}.camera.status')
                gui.add_button(label='ARM', tag=f'{self.identifier}.camera.arm', callback=lambda: self.arm_camera())
                gui.add_button(label='DISARM', tag=f'{self.identifier}.camera.disarm', callback=lambda: self.disarm_camera())
                gui.add_text('Camera')
                gui.hide_item(f'{self.identifier}.camera.disarm')

            with gui.group(horizontal=True):
                gui.add_text('DISARMED', tag=f'{self.identifier}.srad_fc.status')
                gui.add_button(label='ARM', tag=f'{self.identifier}.srad_fc.arm', callback=lambda: self.arm_srad_fc())
                gui.add_button(label='DISARM', tag=f'{self.identifier}.srad_fc.disarm', callback=lambda: self.disarm_srad_fc())
                gui.add_text('SRAD Flight Computer')
                gui.hide_item(f'{self.identifier}.srad_fc.disarm')

            with gui.group(horizontal=True):
                gui.add_text('DISARMED', tag=f'{self.identifier}.cots_fc.status')
                gui.add_button(label='ARM', tag=f'{self.identifier}.cots_fc.arm', callback=lambda: self.arm_cots_fc())
                gui.add_button(label='DISARM', tag=f'{self.identifier}.cots_fc.disarm', callback=lambda: self.disarm_cots_fc())
                gui.add_text('COTS Flight Computer')
                gui.hide_item(f'{self.identifier}.cots_fc.disarm')
    
    def arm_camera(self) -> None:
        # We hide both buttons because we will wait until we get arm status data to show the correct ones.
        gui.hide_item(f'{self.identifier}.camera.arm')
        gui.hide_item(f'{self.identifier}.camera.disarm')
        self.iliad.arm_telemetrum()
    def disarm_camera(self) -> None:
        gui.hide_item(f'{self.identifier}.camera.arm')
        gui.hide_item(f'{self.identifier}.camera.disarm')
        self.iliad.disarm_telemetrum()

    def arm_srad_fc(self) -> None:
        gui.hide_item(f'{self.identifier}.srad_fc.arm')
        gui.hide_item(f'{self.identifier}.srad_fc.disarm')
        self.iliad.arm_stratologger()
    def disarm_srad_fc(self) -> None:
        gui.hide_item(f'{self.identifier}.srad_fc.arm')
        gui.hide_item(f'{self.identifier}.srad_fc.disarm')
        self.iliad.disarm_stratologger()

    def arm_cots_fc(self) -> None:
        gui.hide_item(f'{self.identifier}.cots_fc.arm')
        gui.hide_item(f'{self.identifier}.cots_fc.disarm')
        self.iliad.arm_cots_flight_computer()
    def disarm_cots_fc(self) -> None:
        gui.hide_item(f'{self.identifier}.cots_fc.arm')
        gui.hide_item(f'{self.identifier}.cots_fc.disarm')
        self.iliad.disarm_cots_flight_computer()

    def update(self) -> None: # TODO: Cache last timestamp so we only update GUI when statuses change.
        status: bool = self.iliad.telemetrum_status.latest() # Can be None.
        if status == True:
            self.is_telemetrum_armed = True
            gui.set_value(f'{self.identifier}.camera.status', 'ARMED')
            gui.hide_item(f'{self.identifier}.camera.arm')
            gui.show_item(f'{self.identifier}.camera.disarm')
        elif status == False:
            self.is_telemetrum_armed = False
            gui.set_value(f'{self.identifier}.camera.status', 'DISARMED')
            gui.show_item(f'{self.identifier}.camera.arm')
            gui.hide_item(f'{self.identifier}.camera.disarm')
        
        status: bool = self.iliad.stratologger_status.latest() # Can be None.
        if status == True:
            self.is_stratologger_armed = True
            gui.set_value(f'{self.identifier}.srad_fc.status', 'ARMED')
            gui.hide_item(f'{self.identifier}.srad_fc.arm')
            gui.show_item(f'{self.identifier}.srad_fc.disarm')
        elif status == False:
            self.is_stratologger_armed = False
            gui.set_value(f'{self.identifier}.srad_fc.status', 'DISARMED')
            gui.show_item(f'{self.identifier}.srad_fc.arm')
            gui.hide_item(f'{self.identifier}.srad_fc.disarm')
        
        status: bool = self.iliad.camera_status.latest() # Can be None.
        if status == True:
            self.is_camera_armed = True
            gui.set_value(f'{self.identifier}.cots_fc.status', 'ARMED')
            gui.hide_item(f'{self.identifier}.cots_fc.arm')
            gui.show_item(f'{self.identifier}.cots_fc.disarm')
        elif status == False:
            self.is_camera_armed = False
            gui.set_value(f'{self.identifier}.cots_fc.status', 'DISARMED')
            gui.show_item(f'{self.identifier}.cots_fc.arm')
            gui.hide_item(f'{self.identifier}.cots_fc.disarm')
