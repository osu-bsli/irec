import time
import tkinter as tk  # screen dimensions
from math import sin

import dearpygui.dearpygui as gui

from components.app_component import AppComponent
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

variableAltitude = 2
variableAcceleration = 2
variableGPSGroundSpeed = 2
variableGyroscope = 2

latitude = 0
l1 = 50.4321

# Use a list if you need all the data. 
# Empty list of nsamples should exist at the beginning.
# Theres a cleaner way to do this probably.
original_x_axis = [0.0] * nsamples
original_y_axis = [0.0] * nsamples
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


# scrolling functions
def manual_fit_altitude():
    global variableAltitude
    variableAltitude = 0


def auto_fit_altitude():
    global variableAltitude
    variableAltitude = 1


def sliding_window_altitude():
    global variableAltitude
    variableAltitude = 2


def manual_fit_acceleration():
    global variableAcceleration
    variableAcceleration = 0


def auto_fit_acceleration():
    global variableAcceleration
    variableAcceleration = 1


def sliding_window_acceleration():
    global variableAcceleration
    variableAcceleration = 2


def manual_fit_gps_ground_speed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 0


def auto_fit_gps_ground_speed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 1


def sliding_window_gps_ground_speed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 2


def manual_fit_gyroscope():
    global variableGyroscope
    variableGyroscope = 0


def auto_fit_gyroscope():
    global variableGyroscope
    variableGyroscope = 1


def sliding_window_gyroscope():
    global variableGyroscope
    variableGyroscope = 2


# create plot in the current section
def create_plot(labelText, tagy, tagx, xAxisLabel, yAxisLabel):
    gui.window(label=labelText)
    pass

    with gui.plot(label=labelText, height=PLOT_HEIGHT, width=PLOT_WIDTH):
        gui.add_plot_legend()
        gui.add_plot_axis(gui.mvXAxis, label=xAxisLabel, tag=tagx)
        gui.add_plot_axis(gui.mvYAxis, label=yAxisLabel, tag=tagy)


# add line series to plot
def add_line_series_custom(x_data, y_data, series_tag, label_text, tagy):
    gui.add_line_series(x=list(x_data), y=list(y_data),
                        label=label_text, parent=tagy,
                        tag=series_tag)


def display_checklist():
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
                ];

                for idx, item in enumerate(items):
                    with gui.table_row():
                        with gui.table_cell():
                            gui.add_checkbox(label=item, tag=f'ChecklistItem{idx}')

# display the 'tracking' tab of the main GUI
def display_tracking():
    with gui.tab(label="Tracking", parent='app.main_tab_bar'):
        # tracking tab

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
                            with gui.group(horizontal=False):
                                with gui.group(horizontal=True):
                                    gui.add_button(label="Manual Fit", callback=manual_fit_altitude)
                                    gui.add_button(label="Auto Fit", callback=auto_fit_altitude)
                                    gui.add_button(label="Sliding Window", callback=sliding_window_altitude)
                                with gui.group(horizontal=False):
                                    create_plot('Altitude', 'Altitude_y_axis', 'Altitude_x_axis', 'Time(s)',
                                                'Altitude (meters)')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'barometer_altitude_tag',
                                                           'Barometer Altitude', 'Altitude_y_axis')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'gps_altitude_tag',
                                                           'GPS Altitude', 'Altitude_y_axis')

                            # Plot Acceleration data
                            with gui.group(horizontal=False):
                                with gui.group(horizontal=True):
                                    gui.add_button(label="Manual Fit", callback=manual_fit_acceleration)
                                    gui.add_button(label="Auto Fit", callback=auto_fit_acceleration)
                                    gui.add_button(label="Sliding Window", callback=sliding_window_acceleration)
                                with gui.group(horizontal=False):
                                    create_plot("Acceleration", 'Acceleration_y_axis', 'Acceleration_x_axis', 'Time(s)',
                                                'Acceleration (m/s^2)')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'accelerationZ_tag',
                                                           'Acceleration Z ', 'Acceleration_y_axis')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'highGaccelerationZ_tag',
                                                           'High G Acceleration Z', 'Acceleration_y_axis')

                        # New Row
                        # gui.add_table_column(label="secondary_column")
                        # with gui.table_row():
                        # Plot GPS Ground Speed data
                        # with gui.table_row( height=VIEWPORT_HEIGHT/2):\
                        with gui.group(horizontal=True):
                            with gui.group(horizontal=False):
                                with gui.group(horizontal=True):
                                    gui.add_button(label="Manual Fit", callback=manual_fit_gps_ground_speed)
                                    gui.add_button(label="Auto Fit", callback=auto_fit_gps_ground_speed)
                                    gui.add_button(label="Sliding Window", callback=sliding_window_gps_ground_speed)
                                with gui.group(horizontal=False):
                                    create_plot("GPS Ground Speed", 'GPS_Ground_Speed_y_axis',
                                                'GPS_Ground_Speed_x_axis', 'Time(s)', 'Velocity (m/s)')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'GPS_Ground_Speed_tag',
                                                           'GPS Ground Speed', 'GPS_Ground_Speed_y_axis')

                            # Plot gyroscope data
                            with gui.group(horizontal=False):
                                with gui.group(horizontal=True):
                                    gui.add_button(label="Manual Fit", callback=manual_fit_gyroscope)
                                    gui.add_button(label="Auto Fit", callback=auto_fit_gyroscope)
                                    gui.add_button(label="Sliding Window", callback=sliding_window_gyroscope)
                                with gui.group(horizontal=False):
                                    create_plot("Gyroscope", 'Gyroscope_y_axis', 'Gyroscope_x_axis', 'Time(s)', '(RPS)')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_x_tag',
                                                           "Gyroscope X Data", 'Gyroscope_y_axis')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_y_tag',
                                                           "Gyroscope Y Data", 'Gyroscope_y_axis')
                                    add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_z_tag',
                                                           "Gyroscope Z Data", 'Gyroscope_y_axis')

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
                            gui.add_text("0.00", id='latitude')
                            gui.add_text(",")
                            gui.add_text("0.00", id='longitude')
                            gui.add_text(")")
                with gui.table_row(height=VIEWPORT_HEIGHT // 9):
                    with gui.table_cell():
                        gui.add_text("Telemetrum Voltage:")
                        gui.add_text("0.00", id="telemetrumVoltage")
                        gui.add_text("Stratologger Voltage:")
                        gui.add_text("0.00", id="stratologgerVoltage")
                        gui.add_text("Camera Voltage:")
                        gui.add_text("0.00", id="cameraVoltage")
                        gui.add_text("Battery Voltage:")
                        gui.add_text("0.00", id="batteryVoltage")
                with gui.table_row(height=VIEWPORT_HEIGHT // 9):
                    with gui.table_cell():
                        gui.add_text("Telemetrum Current:")
                        gui.add_text("0.00", id="telemetrumCurrent")
                        gui.add_text("Stratologger Current")
                        gui.add_text("0.00", id="stratologgerCurrent")
                        gui.add_text("Camera Current:")
                        gui.add_text("0.00", id="cameraCurrent")
                with gui.table_row(height=VIEWPORT_HEIGHT // 10):
                    with gui.table_cell():
                        gui.add_text("Battery Temperature:")
                        gui.add_text("0.00", id="batteryTemperature")


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

        # Store a reference to the IliadDataController so we can get data from it later.
        self.iliad = iliad
        # displaySidebar()
        # with gui.group(horizontal=True):

        self.display_sidebar()

        # with gui.tab_bar(pos=(200, 200)) as tb:
        # tracking tab
        display_tracking()
        display_checklist()
        # health tab
        # displayHealth()
        # packets tab
        # displayPackets()
        # recovery tab
        # displayRecovery()

        # with gui.tab(label='Telemetry', parent='app.main_tab_bar'):

    # Create the gui stuff:

    def display_sidebar(self):
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
            gui.add_button(label='Telemetrum Armed', tag='telemetrum_armed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True,
                           tag="disarm_telemetrum_popup"):
                gui.add_text("Disarm Telemetrum?")
                gui.add_button(label="Yes", callback=self.disarm_camera)
            gui.bind_item_theme('telemetrum_armed_tag', "theme_armed")
            gui.configure_item("disarm_telemetrum_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Stratologger Armed', tag='stratologger_armed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True,
                           tag="disarm_stratologger_popup"):
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes", callback=self.disarm_srad_fc)
            gui.bind_item_theme('stratologger_armed_tag', "theme_armed")
            gui.configure_item("disarm_stratologger_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Camera Armed', tag='camera_armed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="disarm_camera_popup"):
                gui.add_text("Arm Camera?")
                gui.add_button(label="Yes", callback=self.disarm_cots_fc)
            gui.bind_item_theme('camera_armed_tag', "theme_armed")
            gui.configure_item("disarm_camera_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

            # make Unarmed buttons
            gui.add_button(label='Telemetrum Disarmed', tag='telemetrum_disarmed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="arm_telemetrum_popup"):
                # print("I AM HERE!!!")
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes", callback=self.arm_camera)
            gui.bind_item_theme('telemetrum_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_telemetrum_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Stratologger Disarmed', tag='stratologger_disarmed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True,
                           tag="arm_stratologger_popup"):
                gui.add_text("Disarm Stratologger?")
                gui.add_button(label="Yes", callback=self.arm_srad_fc)
            gui.bind_item_theme('stratologger_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_stratologger_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Camera Disarmed', tag='camera_disarmed_tag', width=SIDEBAR_BUTTON_WIDTH,
                           height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="arm_camera_popup"):
                gui.add_text("Disarm Camera?")
                gui.add_button(label="Yes", callback=self.arm_cots_fc)
            gui.bind_item_theme('camera_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_camera_popup", pos=(POPUP_POSITIONX, POPUP_POSITIONY))

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
                        gui.add_text("0.00", id="altitudeBarometer")
                        gui.add_text("Altitude GPS:")
                        gui.add_text("0.00", id="altitudeGPS")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("Acceleration X:")
                        gui.add_text("0.00", id="accelerationX")
                        gui.add_text("Acceleration Y:")
                        gui.add_text("0.00", id="accelerationY")
                        gui.add_text("Acceleration Z:")
                        gui.add_text("0.00", id="accelerationZ")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("High G Acceleration X:")
                        gui.add_text("0.00", id="highGaccelerationX")
                        gui.add_text("High G Acceleration Y:")
                        gui.add_text("0.00", id="highGaccelerationY")
                        gui.add_text("High G Acceleration Z:")
                        gui.add_text("0.00", id="highGaccelerationZ")
                with gui.table_row(height=VIEWPORT_HEIGHT // 100):
                    with gui.table_cell():
                        gui.add_text("GPS Ground Speed:")
                        gui.add_text("0.00", id="GPSGroundSpeed")
                with gui.table_row(height=VIEWPORT_HEIGHT // 25):
                    with gui.table_cell():
                        gui.add_text("Gyroscope X data:")
                        gui.add_text("0.00", id="gyroscopeX")
                        gui.add_text("Gyroscope Y data:")
                        gui.add_text("0.00", id="gyroscopeY")
                        gui.add_text("Gyroscope Z data:")
                        gui.add_text("0.00", id="gyroscopeZ")

    def arm_camera(self) -> None:
        self.iliad.arm_telemetrum()
        gui.configure_item("arm_telemetrum_popup", show=False)
        return

    def arm_srad_fc(self):
        self.iliad.arm_stratologger()
        gui.configure_item("arm_stratologger_popup", show=False)
        return

    def arm_cots_fc(self):
        self.iliad.arm_cots_flight_computer()
        gui.configure_item("arm_camera_popup", show=False)
        return

    def disarm_camera(self):
        self.iliad.disarm_telemetrum()
        gui.configure_item("disarm_telemetrum_popup", show=False)
        return

    def disarm_srad_fc(self):
        self.iliad.disarm_stratologger()
        gui.configure_item("disarm_stratologger_popup", show=False)
        return

    def disarm_cots_fc(self):
        self.iliad.disarm_cots_flight_computer()
        gui.configure_item("disarm_camera_popup", show=False)
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

        ###Arming Status###

        if self.iliad.telemetrum_status.y_data:
            gui.configure_item(item="telemetrum_armed_tag", show=True)
            gui.configure_item(item="telemetrum_disarmed_tag", show=False)

        else:
            gui.configure_item(item="telemetrum_armed_tag", show=False)
            gui.configure_item(item="telemetrum_disarmed_tag", show=True)

        if self.iliad.stratologger_status.y_data:
            gui.configure_item(item="stratologger_armed_tag", show=True)
            gui.configure_item(item="stratologger_disarmed_tag", show=False)

        else:
            gui.configure_item(item="stratologger_armed_tag", show=False)
            gui.configure_item(item="stratologger_disarmed_tag", show=True)

        if self.iliad.camera_status.y_data:
            gui.configure_item(item="camera_armed_tag", show=True)
            gui.configure_item(item="camera_disarmed_tag", show=False)

        else:
            gui.configure_item(item="camera_armed_tag", show=False)
            gui.configure_item(item="camera_disarmed_tag", show=True)

        ###LEFT SIDE BAR###

        # set altitude variable value
        if len(self.iliad.barometer_altitude.y_data) >= 1:
            gui.set_value('altitudeBarometer',
                          round((self.iliad.barometer_altitude.y_data[len(self.iliad.barometer_altitude.y_data) - 1]),
                                2))

        if len(self.iliad.gps_altitude.y_data) >= 1:
            gui.set_value('altitudeGPS',
                          round((self.iliad.gps_altitude.y_data[len(self.iliad.gps_altitude.y_data) - 1]), 2))

        # set regular acceleration variable values
        if len(self.iliad.accelerometer_x.y_data) >= 1:
            gui.set_value('accelerationX',
                          round((self.iliad.accelerometer_x.y_data[len(self.iliad.accelerometer_x.y_data) - 1]), 2))

        if len(self.iliad.accelerometer_y.y_data) >= 1:
            gui.set_value('accelerationY',
                          round((self.iliad.accelerometer_y.y_data[len(self.iliad.accelerometer_y.y_data) - 1]), 2))

        if len(self.iliad.accelerometer_z.y_data) >= 1:
            gui.set_value('accelerationZ',
                          round((self.iliad.accelerometer_z.y_data[len(self.iliad.accelerometer_z.y_data) - 1]), 2))

        # set high g acceleration variable values
        if len(self.iliad.high_g_accelerometer_x.y_data) >= 1:
            gui.set_value('highGaccelerationX', round(
                (self.iliad.high_g_accelerometer_x.y_data[len(self.iliad.high_g_accelerometer_x.y_data) - 1]), 2))

        if len(self.iliad.high_g_accelerometer_y.y_data) >= 1:
            gui.set_value('highGaccelerationY', round(
                (self.iliad.high_g_accelerometer_y.y_data[len(self.iliad.high_g_accelerometer_y.y_data) - 1]), 2))

        if len(self.iliad.high_g_accelerometer_z.y_data) >= 1:
            gui.set_value('highGaccelerationZ', round(
                (self.iliad.high_g_accelerometer_z.y_data[len(self.iliad.high_g_accelerometer_z.y_data) - 1]), 2))

        # set ground speed data variable value
        if len(self.iliad.gps_ground_speed.y_data) >= 1:
            gui.set_value('GPSGroundSpeed',
                          round((self.iliad.gps_ground_speed.y_data[len(self.iliad.gps_ground_speed.y_data) - 1]), 2))

        # set gyroscope variable values
        if len(self.iliad.gyroscope_x.y_data) >= 1:
            gui.set_value('gyroscopeX',
                          round((self.iliad.gyroscope_x.y_data[len(self.iliad.gyroscope_x.y_data) - 1]), 2))

        if len(self.iliad.gyroscope_y.y_data) >= 1:
            gui.set_value('gyroscopeY',
                          round((self.iliad.gyroscope_y.y_data[len(self.iliad.gyroscope_y.y_data) - 1]), 2))

        if len(self.iliad.gyroscope_z.y_data) >= 1:
            gui.set_value('gyroscopeZ',
                          round((self.iliad.gyroscope_z.y_data[len(self.iliad.gyroscope_z.y_data) - 1]), 2))

            ###RIGHT SIDE BAR###
            # set latitude/longitude variable values
            if len(self.iliad.gps_latitude.y_data) >= 1:
                gui.set_value('latitude',
                              round((self.iliad.gps_latitude.y_data[len(self.iliad.gps_latitude.y_data) - 1]), 2))

            if len(self.iliad.gps_longitude.y_data) >= 1:
                gui.set_value('longitude',
                              round((self.iliad.gps_longitude.y_data[len(self.iliad.gps_longitude.y_data) - 1]), 2))

            # set voltage variable values
            if len(self.iliad.telemetrum_voltage.y_data) >= 1:
                gui.set_value('telemetrumVoltage', round(
                    (self.iliad.telemetrum_voltage.y_data[len(self.iliad.telemetrum_voltage.y_data) - 1]), 2))

            if len(self.iliad.stratologger_voltage.y_data) >= 1:
                gui.set_value('stratologgerVoltage', round(
                    (self.iliad.stratologger_voltage.y_data[len(self.iliad.stratologger_voltage.y_data) - 1]), 2))

            if len(self.iliad.camera_voltage.y_data) >= 1:
                gui.set_value('cameraVoltage',
                              round((self.iliad.camera_voltage.y_data[len(self.iliad.camera_voltage.y_data) - 1]), 2))

            if len(self.iliad.battery_voltage.y_data) >= 1:
                gui.set_value('batteryVoltage',
                              round((self.iliad.battery_voltage.y_data[len(self.iliad.battery_voltage.y_data) - 1]), 2))

            # set board current variable values
            if len(self.iliad.telemetrum_current.y_data) >= 1:
                gui.set_value('telemetrumCurrent', round(
                    (self.iliad.telemetrum_current.y_data[len(self.iliad.telemetrum_current.y_data) - 1]), 2))

            if len(self.iliad.stratologger_current.y_data) >= 1:
                gui.set_value('stratologgerCurrent', round(
                    (self.iliad.stratologger_current.y_data[len(self.iliad.stratologger_current.y_data) - 1]), 2))

            if len(self.iliad.camera_current.y_data) >= 1:
                gui.set_value('cameraCurrent',
                              round((self.iliad.camera_current.y_data[len(self.iliad.camera_current.y_data) - 1]), 2))

            # set board temperature variable values
            if len(self.iliad.battery_temperature.y_data) >= 1:
                gui.set_value('batteryTemperature', round(
                    (self.iliad.battery_temperature.y_data[len(self.iliad.battery_temperature.y_data) - 1]), 2))

        # Get new data sample. Note we need both x and y values
        # if we want a meaningful axis unit.
        # t = time.time() - t0
        # y = (2.0 * frequency * t)
        # y2= (4.0 * sin(frequency) * t)
        # y3=(4.0 * frequency * t)
        # AY_axis.append(y)
        # Altitude.append(t)
        # BY_axis.append(y2)
        # Acceleration.append(t)
        # CY_axis.append(y3)
        # Velocity.append(t)

        # set the series x and y to the last nsamples
        # Set altitude data:
        gui.set_value('barometer_altitude_tag',
                      [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
        # gui.fit_axis_data('Altitude_x_axis')
        # gui.fit_axis_data('Altitude_y_axis')

        gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
        # gui.fit_axis_data('Altitude_x_axis')
        # gui.fit_axis_data('Altitude_y_axis')

        # set acceleration X data:
        # gui.set_value('AccelerationX_tag', [self.iliad.acceleration_x_data.x_data, self.iliad.acceleration_x_data.y_data])
        # gui.fit_axis_data('Acceleration_x_axis')
        # gui.fit_axis_data('Acceleration_y_axis')

        # set acceleration Y data:
        # gui.set_value('AccelerationY_tag', [self.iliad.acceleration_y_data.x_data, self.iliad.acceleration_x_data.y_data])
        # gui.fit_axis_data('Acceleration_x_axis')
        # gui.fit_axis_data('Acceleration_y_axis')

        # set acceleration Z data:
        gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
        # gui.fit_axis_data('Acceleration_x_axis')
        # gui.fit_axis_data('Acceleration_y_axis')

        # set high G acceleration Z data:
        gui.set_value('highGaccelerationZ_tag',
                      [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
        # gui.fit_axis_data('Acceleration_x_axis')
        # gui.fit_axis_data('Acceleration_y_axis')

        # if(len(self.iliad.gps_latitude_data.y_data) >= 1):
        # print(self.iliad.gps_latitude_data.y_data[len(self.iliad.gps_latitude_data.y_data)-1])
        # set gps latitude data:
        # gui.set_value('GPS_Latitude_tag', self.iliad.gps_latitude_data.y_data[len(self.iliad.gps_latitude_data.y_data)])
        # gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')
        # gui.fit_axis_data('GPS_Latitude_and_Longitude_y_axis')

        # set gps longitude data:
        # gui.set_value('GPS_Longitude_tag', [self.iliad.gps_longitude_data.x_data, self.iliad.gps_longitude_data.y_data])
        # gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')
        # gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')

        # set board 1 temperature data:
        # gui.set_value('board_1_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
        # gui.fit_axis_data('board_temperature_data_x_axis')
        # gui.fit_axis_data('board_temperature_data_y_axis')

        # set board 2 temperature data:
        # gui.set_value('board_2_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
        # gui.fit_axis_data('board_temperature_data_x_axis')
        # gui.fit_axis_data('board_temperature_data_y_axis')

        # set board 3 temperature data:
        # gui.set_value('board_3_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
        # gui.fit_axis_data('board_temperature_data_x_axis')
        # gui.fit_axis_data('board_temperature_data_y_axis')

        # set board 4 temperature data:
        # gui.set_value('board_4_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
        # gui.fit_axis_data('board_temperature_data_x_axis')
        # gui.fit_axis_data('board_temperature_data_y_axis')

        # set board 1 voltage data:
        # gui.set_value('board_1_voltage_data_tag', [self.iliad.board_1_voltage_data.x_data, self.iliad.board_1_voltage_data.y_data])
        # gui.fit_axis_data('Board_Voltage_x_axis')
        # gui.fit_axis_data('Board_Voltage_y_axis')

        # set board 2 voltage data:
        # gui.set_value('board_2_voltage_data_tag', [self.iliad.board_2_voltage_data.x_data, self.iliad.board_2_voltage_data.y_data])
        # gui.fit_axis_data('Board_Voltage_x_axis')
        # gui.fit_axis_data('Board_Voltage_y_axis')

        # set board 3 voltage data:
        # gui.set_value('board_3_voltage_data_tag', [self.iliad.board_3_voltage_data.x_data, self.iliad.board_3_voltage_data.y_data])
        # gui.fit_axis_data('Board_Voltage_x_axis')
        # gui.fit_axis_data('Board_Voltage_y_axis')

        # set board 4 voltage data:
        # gui.set_value('board_4_voltage_data_tag', [self.iliad.board_4_voltage_data.x_data, self.iliad.board_4_voltage_data.y_data])
        # gui.fit_axis_data('Board_Voltage_x_axis')
        # gui.fit_axis_data('Board_Voltage_y_axis')

        # set board 1 current data:
        # gui.set_value('board_1_current_data_tag', [self.iliad.board_1_current_data.x_data, self.iliad.board_1_voltage_data.y_data])
        # gui.fit_axis_data('Board_Current_x_axis')
        # gui.fit_axis_data('Board_Current_y_axis')

        # set board 2 current data:
        # gui.set_value('board_2_current_data_tag', [self.iliad.board_2_current_data.x_data, self.iliad.board_2_voltage_data.y_data])
        # gui.fit_axis_data('Board_Current_x_axis')
        # gui.fit_axis_data('Board_Current_y_axis')

        # set board 3 current data:
        # gui.set_value('board_3_current_data_tag', [self.iliad.board_3_current_data.x_data, self.iliad.board_3_voltage_data.y_data])
        # gui.fit_axis_data('Board_Current_x_axis')
        # gui.fit_axis_data('Board_Current_y_axis')

        # set board 4 current data:
        # gui.set_value('board_4_current_data_tag', [self.iliad.board_4_current_data.x_data, self.iliad.board_4_voltage_data.y_data])
        # gui.fit_axis_data('Board_Current_x_axis')
        # gui.fit_axis_data('Board_Current_y_axis')

        # set battery 1 current data:
        # gui.set_value('battery_1_voltage_data_tag', [self.iliad.battery_1_voltage_data.x_data, self.iliad.board_1_voltage_data.y_data])
        # gui.fit_axis_data('Battery_Voltage_x_axis')
        # gui.fit_axis_data('Battery_Voltage_y_axis')

        # set battery 2 current data:
        # gui.set_value('battery_2_voltage_data_tag', [self.iliad.battery_2_voltage_data.x_data, self.iliad.board_2_voltage_data.y_data])
        # gui.fit_axis_data('Battery_Voltage_x_axis')
        # gui.fit_axis_data('Battery_Voltage_y_axis')

        # set battery 3 current data:
        # gui.set_value('battery_3_voltage_data_tag', [self.iliad.battery_3_voltage_data.x_data, self.iliad.board_3_voltage_data.y_data])
        # gui.fit_axis_data('Battery_Voltage_x_axis')
        # gui.fit_axis_data('Battery_Voltage_y_axis')

        # set magnetometer 1 data:
        # gui.set_value('Magnetometer_X_tag', [self.iliad.magnetometer_data_1.x_data, self.iliad.magnetometer_data_1.y_data])
        # gui.fit_axis_data('Magnetometer_x_axis')
        # gui.fit_axis_data('Magnetometer_y_axis')

        # set magnetometer 2 data:
        # gui.set_value('Magnetometer_Y_tag', [self.iliad.magnetometer_data_2.x_data, self.iliad.magnetometer_data_2.y_data])
        # gui.fit_axis_data('Magnetometer_x_axis')
        # gui.fit_axis_data('Magnetometer_y_axis')

        # set magnetometer 3 data:
        # gui.set_value('Magnetometer_Z_tag', [self.iliad.magnetometer_data_3.x_data, self.iliad.magnetometer_data_3.y_data])
        # gui.fit_axis_data('Magnetometer_x_axis')
        # gui.fit_axis_data('Magnetometer_y_axis')

        # set gyroscope X data:
        gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
        # gui.fit_axis_data('Gyroscope_x_axis')
        # gui.fit_axis_data('Gyroscope_y_axis')

        # set gyroscope Y data:
        gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
        # gui.fit_axis_data('Gyroscope_x_axis')
        # gui.fit_axis_data('Gyroscope_y_axis')

        # set gyroscope Z data:
        gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
        # gui.fit_axis_data('Gyroscope_x_axis')
        # gui.fit_axis_data('Gyroscope_y_axis')

        """#set gps satellites data:
            gui.set_value('GPS_Satellites_tag', [self.iliad.gps_satellites_data.x_data, self.iliad.gps_satellites_data.y_data])
            gui.fit_axis_data('GPS_Satellites_x_axis')
            gui.fit_axis_data('GPS_Satellites_y_axis')"""

        # set gps ground speed data:

        gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
        # gui.fit_axis_data('GPS_Ground_Speed_x_axis')
        # gui.fit_axis_data('GPS_Ground_Speed_y_axis')

        ''''#CSV File Stuff
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                #time_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                #camera_arming_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                #time_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                #SRADFC_arming_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                #COTSFC_arming_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                altitude1_last_value = self.iliad.altitude_1_data.y_data[len(self.iliad.altitude_1_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                altitude2_last_value = self.iliad.altitude_2_data.y_data[len(self.iliad.altitude_2_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                accelerationX_last_value = self.iliad.acceleration_x_data.y_data[len(self.iliad.acceleration_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                accelerationY_last_value = self.iliad.acceleration_y_data.y_data[len(self.iliad.acceleration_y_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                accelerationZ_last_value = self.iliad.acceleration_z_data.y_data[len(self.iliad.acceleration_z_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                GPS_ground_speed_last_value = self.iliad.gps_ground_speed_data.y_data[len(self.iliad.gps_ground_speed_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                gyroscope_x_data_last_value = self.iliad.gyroscope_x_data.y_data[len(self.iliad.gyroscope_x_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                gyroscope_y_data_last_value = self.iliad.gyroscope_y_data.y_data[len(self.iliad.gyroscope_y_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                gyroscope_z_data_last_value = self.iliad.gyroscope_z_data.y_data[len(self.iliad.gyroscope_z_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                latitude_last_value = self.iliad.gps_latitude_data.y_data[len(self.iliad.gps_latitude_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                longitude_last_value = self.iliad.gps_longitude_data.y_data[len(self.iliad.gps_longitude_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_1_voltage_last_value = self.iliad.board_1_voltage_data.y_data[len(self.iliad.board_1_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_2_voltage_last_value = self.iliad.board_1_voltage_data.y_data[len(self.iliad.board_1_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_3_voltage_last_value = self.iliad.board_1_voltage_data.y_data[len(self.iliad.board_1_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_4_voltage_last_value = self.iliad.board_1_voltage_data.y_data[len(self.iliad.board_1_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_1_current_last_value = self.iliad.board_1_current_data.y_data[len(self.iliad.board_1_current_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_2_current_last_value = self.iliad.board_2_current_data.y_data[len(self.iliad.board_2_current_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_3_current_last_value = self.iliad.board_3_current_data.y_data[len(self.iliad.board_3_current_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_4_current_last_value = self.iliad.board_4_current_data.y_data[len(self.iliad.board_4_current_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_1_temperature_last_value = self.iliad.board_1_temperature_data.y_data[len(self.iliad.board_1_temperature_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_2_temprature_last_value = self.iliad.board_2_temperature_data.y_data[len(self.iliad.board_2_temperature_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_3_temperature_last_value = self.iliad.board_3_temperature_data.y_data[len(self.iliad.board_3_temperature_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                board_4_temperature_last_value = self.iliad.board_4_temperature_data.y_data[len(self.iliad.board_4_temperature_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                battery_voltage_1_data_last_value = self.iliad.battery_1_voltage_data.y_data[len(self.iliad.battery_1_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                battery_voltage_2_data_last_value = self.iliad.battery_2_voltage_data.y_data[len(self.iliad.battery_2_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):
                battery_voltage_3_data_last_value = self.iliad.battery_3_voltage_data.y_data[len(self.iliad.battery_3_voltage_data.y_data)-1]
            if(len(self.iliad.battery_3_voltage_data.y_data) >= 1):






            rowList.append(self.iliad.gps_ground_speed_data.x_data)
            writePacketToFile()'''

        # update_data()

        # acceleration_1_x_values: list[float] = []
        # acceleration_1_y_values: list[float] = []
        # for point in self.iliad.altitude_1_data:
        #     altitude_1_x_values.append(point[0])
        #     altitude_1_y_values.append(point[1])
        # gui.set_value('Acceleration_tag', [acceleration_1_x_values, acceleration_1_y_values])
        # gui.fit_axis_data('x_axis2')
        # gui.fit_axis_data('y_axis2') 
        # gui.set_value('Velocity_tag', [list(Velocity[-nsamples:]), list(CY_axis[-nsamples:])])
        # gui.fit_axis_data('x_axis3')
        # gui.fit_axis_data('y_axis3')       

        # Altitude
        if variableAltitude == 1:
            gui.fit_axis_data("Altitude_x_axis")
            gui.fit_axis_data("Altitude_y_axis")
            gui.set_value('barometer_altitude_tag',
                          [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
            gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
        if variableAltitude == 0:
            gui.set_axis_limits_auto("Altitude_x_axis")
            gui.set_axis_limits_auto("Altitude_y_axis")
            gui.set_value('barometer_altitude_tag',
                          [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
            gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
        if variableAltitude == 2:
            gui.fit_axis_data("Altitude_x_axis")
            gui.fit_axis_data("Altitude_y_axis")
            gui.set_value('barometer_altitude_tag', [self.iliad.barometer_altitude.x_data[-nsamples:],
                                                     self.iliad.barometer_altitude.y_data[-nsamples:]])
            gui.set_value('gps_altitude_tag',
                          [self.iliad.gps_altitude.x_data[-nsamples:], self.iliad.gps_altitude.y_data[-nsamples:]])

        # Acceleration
        if variableAcceleration == 1:
            gui.fit_axis_data("Acceleration_x_axis")
            gui.fit_axis_data("Acceleration_y_axis")
            gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
            gui.set_value('highGaccelerationZ_tag',
                          [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
        if variableAcceleration == 0:
            gui.set_axis_limits_auto("Acceleration_x_axis")
            gui.set_axis_limits_auto("Acceleration_y_axis")
            gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
            gui.set_value('highGaccelerationZ_tag',
                          [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
        if variableAcceleration == 2:
            gui.fit_axis_data("Acceleration_x_axis")
            gui.fit_axis_data("Acceleration_y_axis")
            gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data[-nsamples:],
                                                self.iliad.accelerometer_z.y_data[-nsamples:]])
            gui.set_value('highGaccelerationZ_tag', [self.iliad.high_g_accelerometer_z.x_data[-nsamples:],
                                                     self.iliad.high_g_accelerometer_z.y_data[-nsamples:]])

        # GPS Ground Speed
        if variableGPSGroundSpeed == 1:
            gui.fit_axis_data("GPS_Ground_Speed_x_axis")
            gui.fit_axis_data("GPS_Ground_Speed_y_axis")
            gui.set_value('GPS_Ground_Speed_tag',
                          [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
        if variableGPSGroundSpeed == 0:
            gui.set_axis_limits_auto("GPS_Ground_Speed_x_axis")
            gui.set_axis_limits_auto("GPS_Ground_Speed_y_axis")
            gui.set_value('GPS_Ground_Speed_tag',
                          [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
        if variableGPSGroundSpeed == 2:
            gui.fit_axis_data("GPS_Ground_Speed_x_axis")
            gui.fit_axis_data("GPS_Ground_Speed_y_axis")
            gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data[-nsamples:],
                                                   self.iliad.gps_ground_speed.y_data[-nsamples:]])

        # Gyroscope
        if variableGyroscope == 1:
            gui.fit_axis_data("Gyroscope_x_axis")
            gui.fit_axis_data("Gyroscope_y_axis")
            gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
            gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
            gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
        if variableGyroscope == 0:
            gui.set_axis_limits_auto("Gyroscope_x_axis")
            gui.set_axis_limits_auto("Gyroscope_y_axis")
            gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
            gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
            gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
        if variableGyroscope == 2:
            gui.fit_axis_data("Gyroscope_x_axis")
            gui.fit_axis_data("Gyroscope_y_axis")
            gui.set_value('Gyroscope_x_tag',
                          [self.iliad.gyroscope_x.x_data[-nsamples:], self.iliad.gyroscope_x.y_data[-nsamples:]])
            gui.set_value('Gyroscope_y_tag',
                          [self.iliad.gyroscope_y.x_data[-nsamples:], self.iliad.gyroscope_y.y_data[-nsamples:]])
            gui.set_value('Gyroscope_z_tag',
                          [self.iliad.gyroscope_z.x_data[-nsamples:], self.iliad.gyroscope_z.y_data[-nsamples:]])

        time.sleep(0.01)

# Create the gui stuff:
# with gui.group(horizontal=False):
# displaySidebar()
