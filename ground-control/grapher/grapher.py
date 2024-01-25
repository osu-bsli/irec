import time
import tkinter as tk  # screen dimensions
from enum import Enum
from math import sin
from typing import Optional

import dearpygui.dearpygui as gui

from components.app_component import AppComponent
from components.data_series import DataSeries
from data_controllers.iliad_data_controller import IliadDataController

# layout constants

rowList = []

SCREEN_HEIGHT = tk.Tk().winfo_screenheight()
SCREEN_WIDTH = tk.Tk().winfo_screenwidth()

# dpg viewport is smaller than screen resolution
VIEWPORT_HEIGHT = int(SCREEN_HEIGHT // 1.25)
VIEWPORT_WIDTH = int(SCREEN_WIDTH // 1.25)

# window offset from top left corner
VIEWPORT_XPOS = 10
VIEWPORT_YPOS = 10

# plot dimensions
PLOT_WIDTH = int(VIEWPORT_WIDTH // 2.05)
PLOT_HEIGHT = int(VIEWPORT_HEIGHT // 2)

# (r, g, b, alpha)
# orng_btn_theme = (150, 30, 30)
BUTTON_ACTIVE_COLOR = (0, 150, 100, 255)  # green
BUTTON_INACTIVE_COLOR = (150, 30, 30)  # red

# persistent sidebar

SIDEBAR_BUTTON_HEIGHT = VIEWPORT_HEIGHT // 8  # 1/6 of total height
SIDEBAR_BUTTON_WIDTH = VIEWPORT_WIDTH // 10  # 1/10 of total width

ICON_FILE = 'resources/BSLI_logo.ico'

POPUP_POSITIONX = 625
POPUP_POSITIONY = 325

# variables for plotting over time
nsamples = 100

packetNumber = 1

global Altitude
global AY_axis
global Acceleration
global BY_axis
global Velocity
global CY_axis

global latitude

latitude = 0
l1 = 50.4321

t0 = time.time()

# TODO plot data from serial in
# placeholder: sin plots
# arrays to hold data to plot
sindatax = []
sindatay = []
# populate plot data arrays
for i in range(0, 1000):
    sindatax.append(i / 100)
    sindatay.append(.5 + .5 * sin(50 * i / 1000))

# store current time
currentTime = time.mktime(time.gmtime())

# This class doesn't have support for dynamically adding axes and series.
# If you need to, feel free to refactor it so it does!
class Plot:
    class Fit(Enum):
        MANUAL = 0,
        AUTO = 1,
        SLIDING_WINDOW = 2

    def __init__(self, label_text, x_axis_label, y_axis_label, **series_list: str):
        self.fit = Plot.Fit.SLIDING_WINDOW
        self.label_text = label_text
        self.x_axis_tag: Optional[int | str] = None
        self.y_axis_tag: Optional[int | str] = None
        self.x_axis_label = x_axis_label
        self.y_axis_label = y_axis_label
        self.series_list = series_list
        self.series_tags: dict[str, int | str] = {}

    def add(self):
        with gui.group(horizontal=False):
            with gui.group(horizontal=True):
                def set_fit_callback(sender, app_data, user_data):
                    self.fit = user_data

                gui.add_button(label="Manual Fit", callback=set_fit_callback, user_data=Plot.Fit.MANUAL)
                gui.add_button(label="Auto Fit", callback=set_fit_callback, user_data=Plot.Fit.AUTO)
                gui.add_button(label="Sliding Window", callback=set_fit_callback, user_data=Plot.Fit.SLIDING_WINDOW)

            with gui.group(horizontal=False):
                gui.window(label=self.label_text)

                with gui.plot(label=self.label_text, height=PLOT_HEIGHT, width=PLOT_WIDTH):
                    gui.add_plot_legend()
                    self.x_axis_tag = gui.add_plot_axis(gui.mvXAxis, label=self.x_axis_label)
                    self.y_axis_tag = gui.add_plot_axis(gui.mvYAxis, label=self.y_axis_label)

                    for id, label in self.series_list.items():
                        series_tag = gui.add_line_series(x=[0.0] * nsamples, y=[0.0] * nsamples, label=label, parent=self.y_axis_tag)
                        self.series_tags[id] = series_tag

    def update(self, **data_series: DataSeries):
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

# diagnostic info goes here
def display_health():
    with gui.tab(label="Health", parent='app.main_tab_bar'):
        gui.add_text("General system diagnostic info goes here")


# raw packet/signal data
# def displayPackets():
# with gui.tab(label="Packets", parent='app.main_tab_bar'):
# startWritingToFile()
# writePacketToFile()
# gui.add_button(label="Click",  callback=writePacketToFile())
# gui.add_button(label="Click",  callback=writePacketToFile())


# info relevant to rocket recovery goes here
def display_recovery():
    """with gui.tab(label="Recovery", parent='app.main_tab_bar') as t2:
        with gui.theme(tag="landed_button_theme"):
            with gui.theme_component(gui.mvButton):
                gui.add_theme_color(gui.mvThemeCol_Button, (0, 150, 100))
        gui.add_button(label="Landed", width=650, height=75)
        gui.bind_item_theme(gui.last_item(), "Theme Landed")
        width, height, channels, data = gui.load_image("MapOfTripoli.jpg")
        with gui.texture_registry():
            texture_id =gui.add_static_texture(width, height, data)

        gui.add_image(texture_id, width = 650, height = 800*.13099/.23483)"""


"""

    

            


"""


class Grapher(AppComponent):
    def __init__(self, identifier: str, iliad: IliadDataController) -> None:
        super().__init__(identifier)

        # Initialize GUI variables
        self.altitude_barometer = None
        self.altitude_gps = None
        self.acceleration_x = None
        self.acceleration_y = None
        self.acceleration_z = None
        self.high_g_acceleration_x = None
        self.high_g_acceleration_y = None
        self.high_g_acceleration_z = None
        self.gps_ground_speed = None
        self.gyroscope_x = None
        self.gyroscope_y = None
        self.gyroscope_z = None

        self.telemetrum_armed = None
        self.telemetrum_disarmed = None
        self.stratologger_armed = None
        self.stratologger_disarmed = None
        self.camera_armed = None
        self.camera_disarmed = None

        self.latitude = None
        self.longitude = None
        self.telemetrum_voltage = None
        self.stratologger_voltage = None
        self.camera_voltage = None
        self.battery_voltage = None
        self.telemetrum_current = None
        self.stratologger_current = None
        self.camera_current = None
        self.battery_temperature = None

        # Store a reference to the IliadDataController so we can get data from it later.
        self.iliad = iliad
        # displaySidebar()
        # with gui.group(horizontal=True):

        self.add_sidebar()

        # with gui.tab_bar(pos=(200, 200)) as tb:
        # tracking tab
        self.add_tracking()
        self.add_checklist()
        # health tab
        # displayHealth()
        # packets tab
        # displayPackets()
        # recovery tab
        # displayRecovery()

        # with gui.tab(label='Telemetry', parent='app.main_tab_bar'):

    def add_checklist(self):
        with gui.tab(label="Checklist", parent='app.main_tab_bar'):
            gui.add_text("SAC Avionics Checklist 2024 Test Launch")

            with gui.group(horizontal=False):
                # add checklist table
                with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                               borders_innerH=False, borders_outerH=True, borders_innerV=True,
                               borders_outerV=True, context_menu_in_body=True, row_background=True):
                    # create table column to hold checklist
                    gui.add_table_column(label="tasks", width=VIEWPORT_WIDTH // 3)

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

    def add_sidebar(self):
        # bind buttons to an initial named theme.
        # modify the theme and re-bind button to change appearance.
        # TODO button click redirects to relevant diagnostics

        with gui.group(horizontal=False, parent='app.sidebar'):
            with gui.theme(tag="theme_armed"):
                with gui.theme_component(gui.mvButton):
                    gui.add_theme_color(gui.mvThemeCol_Button, BUTTON_INACTIVE_COLOR)

            with gui.theme(tag="theme_unarmed"):
                with gui.theme_component(gui.mvButton):
                    gui.add_theme_color(gui.mvThemeCol_Button, BUTTON_ACTIVE_COLOR)

            # Button for Telemetry status
            self.telemetrum_armed = gui.add_button(label='Telemetrum Armed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.disarm_telemetrum_popup:
                gui.add_text("Disarm Telemetrum?")
                gui.add_button(label="Yes", callback=self.disarm_camera)
                gui.configure_item(self.disarm_telemetrum_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.telemetrum_armed, "theme_armed")

            self.stratologger_armed = gui.add_button(label='Stratologger Armed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.disarm_stratologger_popup:
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes", callback=self.disarm_srad_fc)
                gui.configure_item(self.disarm_stratologger_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.stratologger_armed, "theme_armed")

            self.camera_armed = gui.add_button(label='Camera Armed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.disarm_camera_popup:
                gui.add_text("Arm Camera?")
                gui.add_button(label="Yes", callback=self.disarm_cots_fc)
                gui.configure_item(self.disarm_camera_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.camera_armed, "theme_armed")

            # make Unarmed buttons
            self.telemetrum_disarmed = gui.add_button(label='Telemetrum Disarmed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.arm_telemetrum_popup:
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes", callback=self.arm_camera)
                gui.configure_item(self.arm_telemetrum_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.telemetrum_disarmed, "theme_unarmed")

            self.stratologger_disarmed = gui.add_button(label='Stratologger Disarmed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.arm_stratologger_popup:
                gui.add_text("Disarm Stratologger?")
                gui.add_button(label="Yes", callback=self.arm_srad_fc)
                gui.configure_item(self.arm_stratologger_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.stratologger_disarmed, "theme_unarmed")

            self.camera_disarmed = gui.add_button(label='Camera Disarmed', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True) as self.arm_camera_popup:
                gui.add_text("Disarm Camera?")
                gui.add_button(label="Yes", callback=self.arm_cots_fc)
                gui.configure_item(self.arm_camera_popup, pos=(POPUP_POSITIONX, POPUP_POSITIONY))
            gui.bind_item_theme(self.camera_disarmed, "theme_unarmed")

            # start without showing unarmed button
            # gui.configure_item(item="COTS_fc_unarmed_tag", show=False)

            with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                           borders_innerH=False, borders_outerH=True, borders_innerV=True,
                           borders_outerV=True, context_menu_in_body=True, row_background=True,
                           width=VIEWPORT_WIDTH // 10):
                # create table column to hold plot rows
                gui.add_table_column(label="primary_columns", width=VIEWPORT_WIDTH // 100)

                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("Altitude Barometer:")
                        self.altitude_barometer = gui.add_text("0.00")
                        gui.add_text("Altitude GPS:")
                        self.altitude_gps = gui.add_text("0.00")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("Acceleration X:")
                        self.acceleration_x = gui.add_text("0.00")
                        gui.add_text("Acceleration Y:")
                        self.acceleration_y = gui.add_text("0.00")
                        gui.add_text("Acceleration Z:")
                        self.acceleration_z = gui.add_text("0.00")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("High G Acceleration X:")
                        self.high_g_acceleration_x = gui.add_text("0.00")
                        gui.add_text("High G Acceleration Y:")
                        self.high_g_acceleration_y = gui.add_text("0.00")
                        gui.add_text("High G Acceleration Z:")
                        self.high_g_acceleration_z = gui.add_text("0.00")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("GPS Ground Speed:")
                        self.gps_ground_speed = gui.add_text("0.00")
                with gui.table_row(height=VIEWPORT_HEIGHT // 25):
                    with gui.table_cell():
                        gui.add_text("Gyroscope X data:")
                        self.gyroscope_x = gui.add_text("0.00")
                        gui.add_text("Gyroscope Y data:")
                        self.gyroscope_y = gui.add_text("0.00")
                        gui.add_text("Gyroscope Z data:")
                        self.gyroscope_z = gui.add_text("0.00")

    # add the 'tracking' tab of the main GUI
    def add_tracking(self):
        with (gui.tab(label="Tracking", parent='app.main_tab_bar')):
            with gui.group(horizontal=True):
                with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                               borders_innerH=False, borders_outerH=True, borders_innerV=True,
                               borders_outerV=True, context_menu_in_body=True, row_background=True,
                               height=VIEWPORT_HEIGHT, width=VIEWPORT_WIDTH - 20):
                    # create table column to hold plot rows
                    gui.add_table_column(label="primary_column", width=VIEWPORT_WIDTH * 2)

                    # Row for Altitude and Acceleration Plots
                    with gui.table_row(height=VIEWPORT_HEIGHT // 2):
                        with gui.table_cell():
                            # Plot Altitude data
                            with gui.group(horizontal=True):
                                altitude_plot.add()
                                acceleration_plot.add()

                            with gui.group(horizontal=True):
                                gps_ground_speed_plot.add()
                                gyroscope_plot.add()

                with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                               borders_innerH=False, borders_outerH=True, borders_innerV=True,
                               borders_outerV=True, context_menu_in_body=True, row_background=True):
                    # create table column to hold plot rows
                    gui.add_table_column(label="primary_column", width=VIEWPORT_WIDTH * 2)

                    # Row for Right Table
                    with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                        with gui.table_cell():
                            gui.add_text("Latitude/Longitude:")
                            with gui.group(horizontal=True):
                                gui.add_text("(")
                                self.latitude = gui.add_text("0.00")
                                gui.add_text(",")
                                self.longitude = gui.add_text("0.00")
                                gui.add_text(")")
                    with gui.table_row(height=VIEWPORT_HEIGHT // 9):
                        with gui.table_cell():
                            gui.add_text("Telemetrum Voltage:")
                            self.telemetrum_voltage = gui.add_text("0.00")
                            gui.add_text("Stratologger Voltage:")
                            self.stratologger_voltage = gui.add_text("0.00")
                            gui.add_text("Camera Voltage:")
                            self.camera_voltage = gui.add_text("0.00")
                            gui.add_text("Battery Voltage:")
                            self.battery_voltage = gui.add_text("0.00")
                    with gui.table_row(height=VIEWPORT_HEIGHT // 9):
                        with gui.table_cell():
                            gui.add_text("Telemetrum Current:")
                            self.telemetrum_current = gui.add_text("0.00")
                            gui.add_text("Stratologger Current")
                            self.stratologger_current = gui.add_text("0.00")
                            gui.add_text("Camera Current:")
                            self.camera_current = gui.add_text("0.00")
                    with gui.table_row(height=VIEWPORT_HEIGHT // 10):
                        with gui.table_cell():
                            gui.add_text("Battery Temperature:")
                            self.battery_temperature = gui.add_text("0.00")

    def arm_camera(self) -> None:
        self.iliad.arm_telemetrum()
        gui.configure_item(self.arm_telemetrum_popup, show=False)
        return

    def arm_srad_fc(self):
        self.iliad.arm_stratologger()
        gui.configure_item(self.arm_stratologger_popup, show=False)
        return

    def arm_cots_fc(self):
        self.iliad.arm_cots_flight_computer()
        gui.configure_item(self.arm_camera_popup, show=False)
        return

    def disarm_camera(self):
        self.iliad.disarm_telemetrum()
        gui.configure_item(self.disarm_telemetrum_popup, show=False)
        return

    def disarm_srad_fc(self):
        self.iliad.disarm_stratologger()
        gui.configure_item(self.disarm_stratologger_popup, show=False)
        return

    def disarm_cots_fc(self):
        self.iliad.disarm_cots_flight_computer()
        gui.configure_item(self.disarm_camera_popup, show=False)
        return

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

    def update(self) -> None:

        # ARMING STATUS #

        if self.iliad.telemetrum_status.y_data:
            gui.configure_item(self.telemetrum_armed, show=True)
            gui.configure_item(self.telemetrum_disarmed, show=False)
        else:
            gui.configure_item(self.telemetrum_armed, show=False)
            gui.configure_item(self.telemetrum_disarmed, show=True)

        if self.iliad.stratologger_status.y_data:
            gui.configure_item(self.stratologger_armed, show=True)
            gui.configure_item(self.stratologger_disarmed, show=False)
        else:
            gui.configure_item(self.stratologger_armed, show=False)
            gui.configure_item(self.stratologger_disarmed, show=True)

        if self.iliad.camera_status.y_data:
            gui.configure_item(self.camera_armed, show=True)
            gui.configure_item(self.camera_disarmed, show=False)
        else:
            gui.configure_item(self.camera_armed, show=False)
            gui.configure_item(self.camera_disarmed, show=True)

        # LEFT SIDE BAR #

        # set altitude variable value
        if len(self.iliad.barometer_altitude.y_data) >= 1:
            gui.set_value(self.altitude_barometer,
                          round((self.iliad.barometer_altitude.y_data[len(self.iliad.barometer_altitude.y_data) - 1]),
                                2))

        if len(self.iliad.gps_altitude.y_data) >= 1:
            gui.set_value(self.altitude_gps,
                          round((self.iliad.gps_altitude.y_data[len(self.iliad.gps_altitude.y_data) - 1]), 2))

        # set regular acceleration variable values
        if len(self.iliad.accelerometer_x.y_data) >= 1:
            gui.set_value(self.acceleration_x,
                          round((self.iliad.accelerometer_x.y_data[len(self.iliad.accelerometer_x.y_data) - 1]), 2))

        if len(self.iliad.accelerometer_y.y_data) >= 1:
            gui.set_value(self.acceleration_y,
                          round((self.iliad.accelerometer_y.y_data[len(self.iliad.accelerometer_y.y_data) - 1]), 2))

        if len(self.iliad.accelerometer_z.y_data) >= 1:
            gui.set_value(self.acceleration_z,
                          round((self.iliad.accelerometer_z.y_data[len(self.iliad.accelerometer_z.y_data) - 1]), 2))

        # set high g acceleration variable values
        if len(self.iliad.high_g_accelerometer_x.y_data) >= 1:
            gui.set_value(self.high_g_acceleration_x, round(
                (self.iliad.high_g_accelerometer_x.y_data[len(self.iliad.high_g_accelerometer_x.y_data) - 1]), 2))

        if len(self.iliad.high_g_accelerometer_y.y_data) >= 1:
            gui.set_value(self.high_g_acceleration_y, round(
                (self.iliad.high_g_accelerometer_y.y_data[len(self.iliad.high_g_accelerometer_y.y_data) - 1]), 2))

        if len(self.iliad.high_g_accelerometer_z.y_data) >= 1:
            gui.set_value(self.high_g_acceleration_z, round(
                (self.iliad.high_g_accelerometer_z.y_data[len(self.iliad.high_g_accelerometer_z.y_data) - 1]), 2))

        # set ground speed data variable value
        if len(self.iliad.gps_ground_speed.y_data) >= 1:
            gui.set_value(self.gps_ground_speed,
                          round((self.iliad.gps_ground_speed.y_data[len(self.iliad.gps_ground_speed.y_data) - 1]), 2))

        # set gyroscope variable values
        if len(self.iliad.gyroscope_x.y_data) >= 1:
            gui.set_value(self.gyroscope_x,
                          round((self.iliad.gyroscope_x.y_data[len(self.iliad.gyroscope_x.y_data) - 1]), 2))

        if len(self.iliad.gyroscope_y.y_data) >= 1:
            gui.set_value(self.gyroscope_y,
                          round((self.iliad.gyroscope_y.y_data[len(self.iliad.gyroscope_y.y_data) - 1]), 2))

        if len(self.iliad.gyroscope_z.y_data) >= 1:
            gui.set_value(self.gyroscope_z,
                          round((self.iliad.gyroscope_z.y_data[len(self.iliad.gyroscope_z.y_data) - 1]), 2))

            # RIGHT SIDE BAR #
            # set latitude/longitude variable values
            if len(self.iliad.gps_latitude.y_data) >= 1:
                gui.set_value(self.latitude,
                              round((self.iliad.gps_latitude.y_data[len(self.iliad.gps_latitude.y_data) - 1]), 2))

            if len(self.iliad.gps_longitude.y_data) >= 1:
                gui.set_value(self.longitude,
                              round((self.iliad.gps_longitude.y_data[len(self.iliad.gps_longitude.y_data) - 1]), 2))

            # set voltage variable values
            if len(self.iliad.telemetrum_voltage.y_data) >= 1:
                gui.set_value(self.telemetrum_voltage, round(
                    (self.iliad.telemetrum_voltage.y_data[len(self.iliad.telemetrum_voltage.y_data) - 1]), 2))

            if len(self.iliad.stratologger_voltage.y_data) >= 1:
                gui.set_value(self.stratologger_voltage, round(
                    (self.iliad.stratologger_voltage.y_data[len(self.iliad.stratologger_voltage.y_data) - 1]), 2))

            if len(self.iliad.camera_voltage.y_data) >= 1:
                gui.set_value(self.camera_voltage,
                              round((self.iliad.camera_voltage.y_data[len(self.iliad.camera_voltage.y_data) - 1]), 2))

            if len(self.iliad.battery_voltage.y_data) >= 1:
                gui.set_value(self.battery_voltage,
                              round((self.iliad.battery_voltage.y_data[len(self.iliad.battery_voltage.y_data) - 1]), 2))

            # set board current variable values
            if len(self.iliad.telemetrum_current.y_data) >= 1:
                gui.set_value(self.telemetrum_current, round(
                    (self.iliad.telemetrum_current.y_data[len(self.iliad.telemetrum_current.y_data) - 1]), 2))

            if len(self.iliad.stratologger_current.y_data) >= 1:
                gui.set_value(self.stratologger_current, round(
                    (self.iliad.stratologger_current.y_data[len(self.iliad.stratologger_current.y_data) - 1]), 2))

            if len(self.iliad.camera_current.y_data) >= 1:
                gui.set_value(self.camera_current,
                              round((self.iliad.camera_current.y_data[len(self.iliad.camera_current.y_data) - 1]), 2))

            # set board temperature variable values
            if len(self.iliad.battery_temperature.y_data) >= 1:
                gui.set_value(self.battery_temperature, round(
                    (self.iliad.battery_temperature.y_data[len(self.iliad.battery_temperature.y_data) - 1]), 2))

        # GRAPHS #

        altitude_plot.update(barometer_altitude=self.iliad.barometer_altitude, gps_altitude=self.iliad.gps_altitude)
        acceleration_plot.update(acceleration_z=self.iliad.accelerometer_z, high_g_acceleration_z=self.iliad.high_g_accelerometer_z)
        gps_ground_speed_plot.update(gps_ground_speed=self.iliad.gps_ground_speed)
        gyroscope_plot.update(gyroscope_x=self.iliad.gyroscope_x, gyroscope_y=self.iliad.gyroscope_y, gyroscope_z=self.iliad.gyroscope_z)

        time.sleep(0.01)

# Create the gui stuff:
# with gui.group(horizontal=False):
# displaySidebar()
