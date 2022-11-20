from components.app_component import AppComponent
from data_controllers.iliad_data_controller import IliadDataController
import dearpygui.dearpygui as gui
import time
from math import sin

# layout constants

import tkinter as tk    # screen dimensions

SCREEN_HEIGHT=tk.Tk().winfo_screenheight()
SCREEN_WIDTH=tk.Tk().winfo_screenwidth()

# dpg viewport is smaller than screen resolution
VIEWPORT_HEIGHT=(int)(SCREEN_HEIGHT/1.25)
VIEWPORT_WIDTH=(int)(SCREEN_WIDTH/1.25)

# window offset from top left corner
VIEWPORT_XPOS=10
VIEWPORT_YPOS=10

# plot dimensions
PLOT_WIDTH=VIEWPORT_WIDTH/2
PLOT_HEIGHT=VIEWPORT_HEIGHT/2

# (r, g, b, alpha)
#orng_btn_theme = (150, 30, 30)
BUTTON_ACTIVE_COLOR=(0, 150, 100, 255)  # green
BUTTON_INACTIVE_COLOR=(150, 30, 30)     # red

# persistent sidebar

SIDEBAR_BUTTON_HEIGHT=VIEWPORT_HEIGHT/8     # 1/6 of total height
SIDEBAR_BUTTON_WIDTH=VIEWPORT_WIDTH/10       # 1/10 of total width

ICON_FILE='resources/BSLI_logo.ico'

#variables for plotting over time
nsamples = 100

global Altitude
global AY_axis
global Acceleration
global BY_axis
global Velocity
global CY_axis


# Use a list if you need all the data. 
# Empty list of nsamples should exist at the beginning.
# Theres a cleaner way to do this probably.
AY_axis = [0.0] * nsamples
Altitude = [0.0] * nsamples
BY_axis = [0.0] * nsamples
Acceleration = [0.0] * nsamples
CY_axis = [0.0] * nsamples
Velocity = [0.0] * nsamples

t0 = time.time()

# TODO plot data from serial in
# placeholder: sin plots
# arrays to hold data to plot
sindatax = []
sindatay = []
# populate plot data arrays
for i in range(0,1000):
    sindatax.append(i/100)
    sindatay.append(.5+.5*sin(50*i/1000))

# store current time
currentTime = time.mktime(time.gmtime())

# create plot in the current section
def plot(labelText, x_data, y_data, tagy, tagx, series_tag, label_text):
    gui.window(label=labelText)
    pass
    with gui.plot(label=labelText, height=PLOT_HEIGHT, width=PLOT_WIDTH):
        gui.add_plot_legend()
        gui.add_plot_axis(gui.mvXAxis, label="x", tag=tagx)
        gui.add_plot_axis(gui.mvYAxis, label="y", tag=tagy)
        gui.add_line_series(x=list(x_data),y=list(y_data), 
                            label=label_text, parent=tagy, 
                            tag=series_tag)

def displaySidebar():
    # bind buttons to an initial named theme.
    # modify the theme and re-bind button to change appearance.
    # TODO button click redirects to relevant diagnostics

    # Button for Telemetry status
    with gui.theme(tag="telemetry_button_theme"):
        with gui.theme_component(gui.mvButton):
            gui.add_theme_color(gui.mvThemeCol_Button, (0, 150, 100))
            #gui.bind_item_theme(f"stats_1", (0, 150, 100, 255))
    gui.add_button(label="Telemetry", width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)    
    gui.bind_item_theme(gui.last_item(), "telemetry_button_theme")

    # Button for flight computer 1 status
    with gui.theme(tag="fc1_button_theme"):
        with gui.theme_component(gui.mvButton):
            gui.add_theme_color(gui.mvThemeCol_Button, BUTTON_ACTIVE_COLOR)
    gui.add_button(label="FC1", width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
    gui.bind_item_theme(gui.last_item(), "fc1_button_theme")

    # Button for Flight Computer 2 status
    with gui.theme(tag="fc2_button_theme"):
        with gui.theme_component(gui.mvButton):
            gui.add_theme_color(gui.mvThemeCol_Button, BUTTON_ACTIVE_COLOR)
    gui.add_button(label="FC2", width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
    gui.bind_item_theme(gui.last_item(), "fc2_button_theme")

    # Button for Camera status
    with gui.theme(tag="camera_button_theme"):
        with gui.theme_component(gui.mvButton):
            gui.add_theme_color(gui.mvThemeCol_Button, BUTTON_INACTIVE_COLOR)
    gui.add_button(label="Camera", width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
    gui.bind_item_theme(gui.last_item(), "camera_button_theme")

# display the 'tracking' tab of the main GUI
def displayTracking():
    with gui.tab(label="Tracking"):
        # tracking tab
        # a table of four plots displaying tracking information    
        with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
        borders_innerH=False, borders_outerH=True, borders_innerV=True,
        borders_outerV=True, context_menu_in_body=True, row_background=True,
    height=VIEWPORT_HEIGHT, width=VIEWPORT_WIDTH):

            # create table column to hold plot rows
            gui.add_table_column(label="primary_column")
            
            # Row for Plots A and B
            with gui.table_row():
                with gui.group(horizontal=True):
                    # Plot A
                    with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=PLOT_HEIGHT, width=PLOT_WIDTH):
                        gui.add_table_column(label="altitude_column")
                        with gui.table_row():
                            plot('Altitude', Altitude, AY_axis, 'y_axis', 'x_axis', 'Altitude_tag', 'Altitude (m)')
                    # Plot B
                    with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=PLOT_HEIGHT, width=PLOT_WIDTH):
                        gui.add_table_column(label="acceleration_column")
                        with gui.table_row():
                            plot("Acceleration", Acceleration, BY_axis, 'y_axis2', 'x_axis2', 'Acceleration_tag',  'Acceleration (m/s^2)')

            # Row for Plots C and D
            with gui.table_row():
                with gui.group(horizontal=True):
                    # Plot C
                    with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=PLOT_HEIGHT, width=PLOT_WIDTH):
                        gui.add_table_column(label="acceleration_column")
                        with gui.table_row():
                            plot("Velocity", Velocity, CY_axis, 'y_axis3', 'x_axis3', 'Velocity_tag',  'Velocity (m/s)')
                    # Plot D
                    with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=PLOT_HEIGHT, width=PLOT_WIDTH):
                        gui.add_table_column(label="acceleration_column")

# sebd abd recieve commands here
def displayArming():
    with gui.tab(label="Arming"):
        gui.add_text("Send commands and change arming status here")

# diagnostic info goes here
def displayHealth():
    with gui.tab(label="Health"):
        gui.add_text("General system diagnostic info goes here")

# raw packet/signal data
def displayPackets():
    with gui.tab(label="Packets"):
        gui.add_text("tabulated packet data and packet health info go here")

# sebd abd recieve commands here
def displayArming():
    with gui.tab(label="Arming"):
        gui.add_text("Send commands and change arming status here")

# info relevant to rocket recovery goes here
def displayRecovery():
    with gui.tab(label="Recovery") as t2:
        with gui.theme(tag="landed_button_theme"):
            with gui.theme_component(gui.mvButton):
                gui.add_theme_color(gui.mvThemeCol_Button, (0, 150, 100))
        gui.add_button(label="Landed", width=300, height=75)
        gui.bind_item_theme(gui.last_item(), "Theme Landed")
        gui.add_text(currentTime)

class Grapher(AppComponent):
    def __init__(self, identifier: str, iliad: IliadDataController) -> None:
        super().__init__(identifier)

        # Store a reference to the IliadDataController so we can get data from it later.
        self.iliad = iliad

        with gui.group(horizontal=True):

            # Create the gui stuff:
            with gui.group(horizontal=False):
                displaySidebar()
            
            with gui.group(horizontal=False):
                with gui.tab_bar() as tb:
                    # with gui.tab_bar(pos=(100, 100)) as tb:
                    #tracking tab
                    displayTracking()
                    #arming tab
                    displayArming()
                    #health tab
                    displayHealth()
                    #packets tab
                    displayPackets()
                    #recovery tab
                    displayRecovery()
        

    
        # Returns a dictionary with different config options.
    def get_config(self) -> dict[str]:
        return {}
    
    # Sets config options from the dictionary passed in.
    def set_config(self, config: dict[str]) -> None:
        pass
    
    def add_config_menu(self) -> None:
        gui.add_text('No options available.')

    def apply_config(self) -> None:
        pass

    def update(self) -> None:

            sample = 1
            frequency=1.0                

            # Get new data sample. Note we need both x and y values
            # if we want a meaningful axis unit.
            t = time.time() - t0
            y = (2.0 * frequency * t)
            y2= (4.0 * sin(frequency) * t)
            y3=(4.0 * frequency * t)
            AY_axis.append(y)
            Altitude.append(t)
            BY_axis.append(y2)
            Acceleration.append(t)
            CY_axis.append(y3)
            Velocity.append(t)

            
            #set the series x and y to the last nsamples
            # Set altitude data:
            altitude_1_x_values: list[float] = []
            altitude_1_y_values: list[float] = []
            for point in self.iliad.altitude_1_data:
                altitude_1_x_values.append(point[0])
                altitude_1_y_values.append(point[1])
            gui.set_value('Altitude_tag', [altitude_1_x_values, altitude_1_y_values])
            gui.fit_axis_data('x_axis')
            gui.fit_axis_data('y_axis')

            acceleration_1_x_values: list[float] = []
            acceleration_1_y_values: list[float] = []
            for point in self.iliad.altitude_1_data:
                altitude_1_x_values.append(point[0])
                altitude_1_y_values.append(point[1])
            gui.set_value('Acceleration_tag', [acceleration_1_x_values, acceleration_1_y_values])
            gui.fit_axis_data('x_axis2')
            gui.fit_axis_data('y_axis2') 
            gui.set_value('Velocity_tag', [list(Velocity[-nsamples:]), list(CY_axis[-nsamples:])])
            gui.fit_axis_data('x_axis3')
            gui.fit_axis_data('y_axis3')          

            
            time.sleep(0.01)
            sample=sample+1