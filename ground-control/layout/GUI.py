import dearpygui.dearpygui as dpg       # the one and only
from math import *    # math for sin plot
import constants as C   # global constants
import time     # delayed plotting
# import tkinter as tk    # screen dimensions
import dearpygui.dearpygui as dpg
import time
import threading

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


#update data function
def update_data():
    sample = 1
    t0 = time.time()
    frequency=1.0
    while True:

        # Get new data sample. Note we need both x and y values
        # if we want a meaningful axis unit.
        t = time.time() - t0
        y = sin(2.0 * pi * frequency * t)
        y2= cos(4.0 * pi * frequency * t)
        y3=tan(4.0 * pi * frequency * t)
        AY_axis.append(y)
        Altitude.append(t)
        BY_axis.append(y2)
        Acceleration.append(t)
        CY_axis.append(y3)
        Velocity.append(t)

        
        #set the series x and y to the last nsamples
        dpg.set_value('Altitude_tag', [list(Altitude[-nsamples:]), list(AY_axis[-nsamples:])])
        dpg.fit_axis_data('x_axis')
        dpg.fit_axis_data('y_axis')
        dpg.set_value('Acceleration_tag', [list(Acceleration[-nsamples:]), list(BY_axis[-nsamples:])])
        dpg.fit_axis_data('x_axis2')
        dpg.fit_axis_data('y_axis2') 
        dpg.set_value('Velocity_tag', [list(Velocity[-nsamples:]), list(CY_axis[-nsamples:])])
        dpg.fit_axis_data('x_axis3')
        dpg.fit_axis_data('y_axis3')          

        
        time.sleep(0.01)
        sample=sample+1

# TODO plot data from serial in
# placeholder: sin plots
# arrays to hold data to plot
sindatax = []
sindatay = []
sindatay2 = []
# populate plot data arrays
for i in range(0,1000):
    sindatax.append(i/100)
    sindatay.append(.5+.5*sin(50*i/1000))
    sindatay2.append(1/2*(.5+.5*sin(50*i/1000)))

# store current time
currentTime = time.mktime(time.gmtime())

# create plot in the current section
def create_plot(labelText, tagy, tagx):
    dpg.window(label=labelText)
    pass
    with dpg.plot(label=labelText, height=C.PLOT_HEIGHT, width=C.PLOT_WIDTH):
        dpg.add_plot_legend()
        dpg.add_plot_axis(dpg.mvXAxis, label="x", tag=tagx)
        dpg.add_plot_axis(dpg.mvYAxis, label="y", tag=tagy)

def add_line_series_custom(x_data, y_data,  series_tag, label_text,  tagy):
        dpg.add_line_series(x=list(x_data),y=list(y_data), 
                            label=label_text, parent=tagy, 
                            tag=series_tag)


def displaySidebar():
    # bind buttons to an initial named theme.
    # modify the theme and re-bind button to change appearance.
    # TODO button click redirects to relevant diagnostics

    # Button for Telemetry status
    with dpg.theme(tag="telemetry_button_theme"):
        with dpg.theme_component(dpg.mvButton):
            dpg.add_theme_color(dpg.mvThemeCol_Button, (0, 150, 100))
    dpg.add_button(label="Telemetry", width=C.SIDEBAR_BUTTON_WIDTH, height=C.SIDEBAR_BUTTON_HEIGHT)    
    dpg.bind_item_theme(dpg.last_item(), "telemetry_button_theme")

    # Button for flight computer 1 status
    with dpg.theme(tag="fc1_button_theme"):
        with dpg.theme_component(dpg.mvButton):
            dpg.add_theme_color(dpg.mvThemeCol_Button, C.BUTTON_ACTIVE_COLOR)
    dpg.add_button(label="FC1", width=C.SIDEBAR_BUTTON_WIDTH, height=C.SIDEBAR_BUTTON_HEIGHT)
    dpg.bind_item_theme(dpg.last_item(), "fc1_button_theme")

    # Button for Flight Computer 2 status
    with dpg.theme(tag="fc2_button_theme"):
        with dpg.theme_component(dpg.mvButton):
            dpg.add_theme_color(dpg.mvThemeCol_Button, C.BUTTON_ACTIVE_COLOR)
    dpg.add_button(label="FC2", width=C.SIDEBAR_BUTTON_WIDTH, height=C.SIDEBAR_BUTTON_HEIGHT)
    dpg.bind_item_theme(dpg.last_item(), "fc2_button_theme")

    # Button for Camera status
    with dpg.theme(tag="camera_button_theme"):
        with dpg.theme_component(dpg.mvButton):
            dpg.add_theme_color(dpg.mvThemeCol_Button, C.BUTTON_INACTIVE_COLOR)
    dpg.add_button(label="Camera", width=C.SIDEBAR_BUTTON_WIDTH, height=C.SIDEBAR_BUTTON_HEIGHT)
    dpg.bind_item_theme(dpg.last_item(), "camera_button_theme")
            


# display the 'tracking' tab of the main GUI
def displayTracking():
    with dpg.tab(label="Tracking"):
        # tracking tab
        # a table of four plots displaying tracking information    
        with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
        borders_innerH=False, borders_outerH=True, borders_innerV=True,
        borders_outerV=True, context_menu_in_body=True, row_background=True,
    height=C.VIEWPORT_HEIGHT, width=C.VIEWPORT_WIDTH):

            # create table column to hold plot rows
            dpg.add_table_column(label="primary_column")
            
            # Row for Plots A and B
            with dpg.table_row():
                with dpg.group(horizontal=True):
                    # Plot A
                    with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=C.PLOT_HEIGHT, width=C.PLOT_WIDTH):
                        dpg.add_table_column(label="altitude_column")
                        with dpg.table_row():
                            create_plot('Acceleration', 'y_axis', 'x_axis')
                            add_line_series_custom(sindatax, sindatay, 'tag', 'text', 'y_axis')
                            add_line_series_custom(sindatax, sindatay2, 'tag2', 'text', 'y_axis')
                            add_line_series_custom(sindatax, sindatay, 'tag3', 'text', 'y_axis')
                            add_line_series_custom(sindatax, sindatay, 'tag4', 'text', 'y_axis')
                    # Plot B
                    with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=C.PLOT_HEIGHT, width=C.PLOT_WIDTH):
                        dpg.add_table_column(label="acceleration_column")
                        with dpg.table_row():
                            create_plot("Acceleration", 'y_axis2', 'x_axis2')
            
            
            # Row for Plots C and D
            with dpg.table_row():
                with dpg.group(horizontal=True):
                    # Plot C
                    with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=C.PLOT_HEIGHT, width=C.PLOT_WIDTH):
                        dpg.add_table_column(label="acceleration_column")
                        with dpg.table_row():
                            create_plot("Velocity",'y_axis3', 'x_axis3')
                    # Plot D
                    with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                        borders_innerH=False, borders_outerH=True, borders_innerV=True,
                        borders_outerV=True, context_menu_in_body=True, row_background=True,
                        height=C.PLOT_HEIGHT, width=C.PLOT_WIDTH):
                        dpg.add_table_column(label="acceleration_column")
                        #with dpg.table_row():
                            #plot("Orientation", "Orientation", "DY axis")
            # with dpg.table_row():
                # with dpg.group(horizontal=True):
                #     with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                #         borders_innerH=False, borders_outerH=True, borders_innerV=True,
                #         borders_outerV=True, context_menu_in_body=True, row_background=True,
                # height=0, width=250):
                #         #
                #         dpg.add_table_column(label="One")
                #         with dpg.table_row():
                #             dpg.add_text("Altitude")
                #     #
                #     with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                #         borders_innerH=False, borders_outerH=True, borders_innerV=True,
                #         borders_outerV=True, context_menu_in_body=True, row_background=True,
                # height=50, width=250):
                #         #
                #         dpg.add_table_column(label="One")
                #         with dpg.table_row():
                #             dpg.add_text("Velocity")
                #     #
                #     with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                #         borders_innerH=False, borders_outerH=True, borders_innerV=True,
                #         borders_outerV=True, context_menu_in_body=True, row_background=True,
                # height=0, width=250):
                #         #
                #         dpg.add_table_column(label="One")
                #         with dpg.table_row():
                #             dpg.add_text("Acceleration")
                #     #
                #     with dpg.table(header_row=False, no_host_extendX=True, delay_search=True,
                #         borders_innerH=False, borders_outerH=True, borders_innerV=True,
                #         borders_outerV=True, context_menu_in_body=True, row_background=True,
                # height=0, width=450):
                #         #
                #         dpg.add_table_column(label="One")
                #         with dpg.table_row():
                #             dpg.add_text("Coordinates")


# info relevant to rocket recovery goes here
def displayRecovery():
    with dpg.tab(label="Recovery") as t2:
        with dpg.theme(tag="landed_button_theme"):
            with dpg.theme_component(dpg.mvButton):
                dpg.add_theme_color(dpg.mvThemeCol_Button, (0, 150, 100))
        dpg.add_button(label="Landed", width=300, height=75)
        dpg.bind_item_theme(dpg.last_item(), "Theme Landed")
        dpg.add_text(currentTime)

# diagnostic info goes here
def displayHealth():
    with dpg.tab(label="Health"):
        dpg.add_text("General system diagnostic info goes here")

# raw packet/signal data
def displayPackets():
    with dpg.tab(label="Packets"):
        dpg.add_text("tabulated packet data and packet health info go here")

# send and recieve commands here
def displayArming():
    with dpg.tab(label="Arming"):
        dpg.add_text("Send commands and change arming status here")





def displayGUI():
    # primary window
    with dpg.window(label="Iliad Ground Control", width=C.VIEWPORT_WIDTH, height=C.VIEWPORT_HEIGHT, pos=(10, 10)):
        # horizontal group parent
        with dpg.group(horizontal=True):
            
            # Persistent Sidebar below:
            # these status indicators stay on screen regardless of
            # which tab is currently being viewed.
            with dpg.group(horizontal=False):
                # call function to display sidebar
                displaySidebar()

            # Tab Groups below:
            # each of these tabs displays a different 'primary window' at the center of the GUI.
            with dpg.group(horizontal=False):
                with dpg.tab_bar() as tb:
                # with dpg.tab_bar(pos=(100, 100)) as tb:
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
        
        # TODO: Persistent bottom bar
        # with dpg.group(horizontal=True):
        #     dpg.add_text("                             ")
        #     with dpg.theme(tag="Theme Drogue Deployed"):
        #         with dpg.theme_component(dpg.mvButton):
        #                 dpg.add_theme_color(dpg.mvThemeCol_Button, (0, 150, 100))
        #     dpg.add_button(label="Drogue Deployed", width=600, height=75)
        #     dpg.bind_item_theme(dpg.last_item(), "Theme Drogue Deployed")
        #     with dpg.theme(tag="Theme Main Deployed"):
        #         with dpg.theme_component(dpg.mvButton):
        #             dpg.add_theme_color(dpg.mvThemeCol_Button, (250, 0, 0))
        #     dpg.add_button(label="Main Not Deployed", width=600, height=75)
        #     dpg.bind_item_theme(dpg.last_item(), "Theme Main Deployed")
                    


dpg.create_context()
displayGUI()
# TODO change global font size (not using font_scale).
dpg.create_viewport(title='Iliad Ground Control GUI', width=C.VIEWPORT_WIDTH, height=C.VIEWPORT_HEIGHT,x_pos=C.VIEWPORT_XPOS,y_pos=C.VIEWPORT_YPOS,small_icon=C.ICON_FILE, large_icon=C.ICON_FILE)
dpg.setup_dearpygui()
dpg.show_viewport()
thread = threading.Thread(target=update_data)
thread.start()
dpg.start_dearpygui()
dpg.create_context()
dpg.destroy_context() #comment