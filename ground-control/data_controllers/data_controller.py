import dearpygui.dearpygui as gui
from components.app_component import AppComponent

class DataController(AppComponent):
    """
    Generic data controller class for reading/writing to a port/connection.
    """
    
    # Raise when we can't open().
    class DataControllerException(Exception):
        """
        Generic exception for DataController so people using it know what to catch.

        This is usually raised when DataController.open() fails.
        """
        pass
    
    def open(self) -> None:
        """
        Opens the data source, or initializes it, or whatever.
        """
        raise DataController.DataControllerException('Generic data controller cannot be opened.')
    
    def is_open(self) -> bool:
        """
        Checks if this is open.
        """
        return False
    
    def close(self) -> None:
        """
        Closes the data source, or cleans it up, or whatever.
        """
        pass

