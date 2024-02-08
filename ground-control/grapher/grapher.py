import time
from enum import Enum
from math import sin
from typing import Optional

import dearpygui.dearpygui as gui

from components.app_component import AppComponent
from components.data_series import DataSeries
from data_controllers.iliad_data_controller import IliadDataController
from grapher.numerical_data_view import NumericalDataView

# variables for plotting over time
nsamples = 100


# This class doesn't have support for dynamically adding axes and series.
# If you need to, feel free to refactor it so it does!
class Plot:
    class Fit(Enum):
        MANUAL = 0,
        AUTO = 1,
        SLIDING_WINDOW = 2

    def __init__(self, label_text, x_axis_label, y_axis_label, **series_list: str):
        self.plot = None
        self.fit = Plot.Fit.SLIDING_WINDOW
        self.label_text = label_text
        self.x_axis_tag: Optional[int | str] = None
        self.y_axis_tag: Optional[int | str] = None
        self.x_axis_label = x_axis_label
        self.y_axis_label = y_axis_label
        self.series_list = series_list
        self.series_tags: dict[str, int | str] = {}

    def add(self):
        with gui.group(horizontal=True) as self.buttons:
            def set_fit_callback(sender, app_data, user_data):
                self.fit = user_data

            gui.add_button(label="Manual Fit", callback=set_fit_callback, user_data=Plot.Fit.MANUAL)
            gui.add_button(label="Auto Fit", callback=set_fit_callback, user_data=Plot.Fit.AUTO)
            gui.add_button(label="Sliding Window", callback=set_fit_callback, user_data=Plot.Fit.SLIDING_WINDOW)

        with gui.plot(label=self.label_text, width=-1) as self.plot:
            gui.add_plot_legend()
            self.x_axis_tag = gui.add_plot_axis(gui.mvXAxis, label=self.x_axis_label)
            self.y_axis_tag = gui.add_plot_axis(gui.mvYAxis, label=self.y_axis_label)

            for id, label in self.series_list.items():
                series_tag = gui.add_line_series(x=[0.0] * nsamples, y=[0.0] * nsamples, label=label,
                                                 parent=self.y_axis_tag)
                self.series_tags[id] = series_tag

    def update(self, height: int, **data_series: DataSeries):
        for id, ds in data_series.items():
            match self.fit:
                case Plot.Fit.AUTO:
                    gui.set_value(self.series_tags[id], [ds.x_data, ds.y_data])
                case Plot.Fit.MANUAL:
                    gui.set_value(self.series_tags[id], [ds.x_data, ds.y_data])
                case Plot.Fit.SLIDING_WINDOW:
                    gui.set_value(self.series_tags[id], [ds.x_data[-nsamples:], ds.y_data[-nsamples:]])

        match self.fit:
            case Plot.Fit.SLIDING_WINDOW | Plot.Fit.AUTO:
                gui.fit_axis_data(self.x_axis_tag)
                gui.fit_axis_data(self.y_axis_tag)
            case Plot.Fit.MANUAL:
                gui.set_axis_limits_auto(self.x_axis_tag)
                gui.set_axis_limits_auto(self.y_axis_tag)

        height -= gui.get_item_rect_max(self.buttons)[1]
        gui.set_item_height(item=self.plot, height=height)


altitude_plot = Plot('Altitude', 'Time(s)', 'Altitude (meters)',
                     barometer_altitude='Barometer Altitude',
                     gps_altitude='GPS Altitude')

acceleration_plot = Plot("Acceleration", 'Time(s)', 'Acceleration (m/s^2)',
                         acceleration_z='Acceleration Z',
                         high_g_acceleration_z='High G Acceleration Z')

gps_ground_speed_plot = Plot("GPS Ground Speed", 'Time(s)', 'Velocity (m/s)',
                             gps_ground_speed='GPS Ground Speed')

gyroscope_plot = Plot("Gyroscope", 'Time(s)', '(RPS)',
                      gyroscope_x="Gyroscope X Data",
                      gyroscope_y="Gyroscope Y Data",
                      gyroscope_z="Gyroscope Z Data")


class Grapher(AppComponent):
    def __init__(self, identifier: str) -> None:
        super().__init__(identifier)

        self.right_sidebar = NumericalDataView(2)

    def add(self):
        self.add_tracking()
        self.add_checklist()

    def add_checklist(self):
        with gui.tab(label="Checklist"):
            gui.add_text("SAC Avionics Checklist 2024 Test Launch")

            with gui.group(horizontal=False):
                # add checklist table
                with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                               borders_innerH=False, borders_outerH=True, borders_innerV=True,
                               borders_outerV=True, context_menu_in_body=True, row_background=True):
                    # create table column to hold checklist
                    gui.add_table_column(label="tasks")

                    # demo change

                    # Rows for Checklist Left Side
                    items = [
                        "Inspect for damages from travel",
                        "Check TeleMetrum battery voltage",
                        "Check StratoLogger battery voltage",
                        "Check Stratologger settings",
                        "Check TeleGPS battery voltage",
                        "Check that TeleMentrum battery is secure",
                        "Check TeleMetrum to bulkhead connections",
                        "Check that StratoLogger battery is secure",
                        "Check that 9V is plugged in",
                        "Check that all cables are inside bay and will not interfere with ISB rails",
                        "Check StratoLogger to cable connection",
                        "slide avionics bay into ISB",
                        "Ensure cables are not snagged",
                        "Let Payload Integrate",
                        "Connect TeleMetrum to recovery bulkhead",
                        "Inspect TeleMetrum connection on recovery bulkhead",
                        "Connect StratoLogger to recovery bulkhead",
                        "Inspect Stratologger connection on recovery bulkhead",
                        "Slide ISB partially into coupler",
                        "Feed arming switches down through coupler",
                        "Slide ISB fully into coupler",
                        "Adhere arming switches to coupler",
                        "Let Structures and Recovery Integrate",
                        "Connect charges",
                        "Turn on TeleGPS and confirm connection",
                        "Turn on camera",
                        "Arm ejection charges",
                        "Listen for continuity beeps"
                    ]

                    for idx, item in enumerate(items):
                        with gui.table_row():
                            with gui.table_cell():
                                gui.add_checkbox(label=item)

    # add the 'tracking' tab of the main GUI
    def add_tracking(self):
        with gui.tab(label="Tracking") as self.tracking_tab:
            with gui.table(header_row=False):
                gui.add_table_column()
                gui.add_table_column(init_width_or_weight=180, width_fixed=True)

                with gui.table_row():
                    with gui.table_cell():
                        with gui.table(header_row=False):
                            gui.add_table_column()
                            gui.add_table_column()

                            with gui.table_row():
                                with gui.table_cell():
                                    altitude_plot.add()
                                    gps_ground_speed_plot.add()

                                with gui.table_cell():
                                    acceleration_plot.add()
                                    gyroscope_plot.add()

                    # TODO: Latitude/Longitude in one group like it was before Brian's refactor
                    self.right_sidebar.add()
                    self.right_sidebar.add_data_group(latitude="Latitude")
                    self.right_sidebar.add_data_group(longitude="Longitude")
                    self.right_sidebar.add_data_group(telemetrum_voltage="Telemetrum Voltage")
                    self.right_sidebar.add_data_group(stratologger_voltage="Stratologger Voltage")
                    self.right_sidebar.add_data_group(camera_voltage="Camera Voltage")
                    self.right_sidebar.add_data_group(battery_voltage="Battery Voltage")
                    self.right_sidebar.add_data_group(telemetrum_current="Telemetrum Current")
                    self.right_sidebar.add_data_group(stratologger_current="Stratologger Current")
                    self.right_sidebar.add_data_group(camera_current="Camera Current")
                    self.right_sidebar.add_data_group(battery_temperature="Battery Temperature")

    # Returns a dictionary with different config options.
    def get_config(self) -> dict[str, str]:
        return dict()

    # Sets config options from the dictionary passed in.
    def set_config(self, config: dict[str]) -> None:
        pass

    def add_config_menu(self) -> None:
        gui.add_text('No options available.')

    def apply_config(self) -> None:
        pass

    def update(self, iliad: IliadDataController) -> None:
        # LEFT SIDE BAR #

        self.right_sidebar.update_data(
            latitude=iliad.gps_latitude,
            longitude=iliad.gps_longitude,
            telemetrum_voltage=iliad.telemetrum_voltage,
            stratologger_voltage=iliad.stratologger_voltage,
            camera_voltage=iliad.camera_voltage,
            battery_voltage=iliad.battery_voltage,
            telemetrum_current=iliad.telemetrum_current,
            stratologger_current=iliad.stratologger_current,
            camera_current=iliad.camera_current,
            battery_temperature=iliad.battery_temperature,
        )

        plot_height = int(gui.get_available_content_region(self.tracking_tab)[1] / 2)

        altitude_plot.update(plot_height,
                             barometer_altitude=iliad.barometer_altitude,
                             gps_altitude=iliad.gps_altitude)
        acceleration_plot.update(plot_height,
                                 acceleration_z=iliad.accelerometer_z,
                                 high_g_acceleration_z=iliad.high_g_accelerometer_z)
        gps_ground_speed_plot.update(plot_height,
                                     gps_ground_speed=iliad.gps_ground_speed)
        gyroscope_plot.update(plot_height,
                              gyroscope_x=iliad.gyroscope_x,
                              gyroscope_y=iliad.gyroscope_y,
                              gyroscope_z=iliad.gyroscope_z)
