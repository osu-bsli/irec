from components.app_component import AppComponent
from data_controllers.iliad_data_controller import IliadDataController
from utils import packet_util
import dearpygui.dearpygui as gui

class ArmControl(AppComponent):
    def __init__(self, identifier: str, iliad: IliadDataController) -> None:
        super().__init__(identifier)

        self.iliad = iliad

        with gui.window(label='Arm Control'):
            with gui.group(horizontal=True):
                gui.add_text('DISARMED', tag=f'{identifier}.camera_board.status')
                gui.add_button(label='ARM', enabled=False, tag=f'{identifier}.camera_board.arm')
                gui.add_button(label='DISARM', tag=f'{identifier}.camera_board.disarm')
                gui.add_text('Camera Board')

    def update(self) -> None:
        """
        Called every frame.

        Any non event/callback based processing should be done here.
        """
        pass