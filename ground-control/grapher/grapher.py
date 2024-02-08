from components.app_component import AppComponent
from data_controllers.iliad_data_controller import IliadDataController
from iliad.arm_control import ArmControl
import dearpygui.dearpygui as gui
import time
from typing import List, Any, Callable, Union, Tuple
from math import sin
from tkinter import *
import csv
import data_controllers.serial_data_controller as serial_data_controller
from components.data_series import DataSeries
import struct
import packetlib.packet as packet
import crc



# layout constants

import tkinter as tk    # screen dimensions

rowList = []

SCREEN_HEIGHT=tk.Tk().winfo_screenheight()
SCREEN_WIDTH=tk.Tk().winfo_screenwidth()

# dpg viewport is smaller than screen resolution
VIEWPORT_HEIGHT=(int)(SCREEN_HEIGHT/1.25)
VIEWPORT_WIDTH=(int)(SCREEN_WIDTH/1.25)

# window offset from top left corner
VIEWPORT_XPOS=10
VIEWPORT_YPOS=10

# plot dimensions
PLOT_WIDTH=VIEWPORT_WIDTH/2.05
PLOT_HEIGHT=VIEWPORT_HEIGHT/2

# (r, g, b, alpha)
#orng_btn_theme = (150, 30, 30)
BUTTON_ACTIVE_COLOR=(0, 150, 100, 255)  # green
BUTTON_INACTIVE_COLOR=(150, 30, 30)     # red

# persistent sidebar

SIDEBAR_BUTTON_HEIGHT=VIEWPORT_HEIGHT/8     # 1/6 of total height
SIDEBAR_BUTTON_WIDTH=VIEWPORT_WIDTH/8    # 1/10 of total width

ICON_FILE='resources/BSLI_logo.ico'

POPUP_POSITIONX = 625
POPUP_POSITIONY = 325

#variables for plotting over time
nsamples = 100

packetNumber = 1

TELEMETRUM_VOLTAGE_EXPECTED= 4.14 
TELEMETRUM_CURRENT = 30
STRATOLOGGER_VOLATGE = 8
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



latitude=0
l1=50.4321

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
for i in range(0,1000):
    sindatax.append(i/100)
    sindatay.append(.5+.5*sin(50*i/1000))

# store current time
currentTime = time.mktime(time.gmtime())


   


#scrolling functions
def manualFitAltitude():
    global variableAltitude
    variableAltitude = 0
def autoFitAltitude():
    global variableAltitude
    variableAltitude = 1
def slidingWindowAltitude():
    global variableAltitude
    variableAltitude = 2

def manualFitAcceleration():
    global variableAcceleration
    variableAcceleration = 0
def autoFitAcceleration():
    global variableAcceleration
    variableAcceleration = 1
def slidingWindowAcceleration():
    global variableAcceleration
    variableAcceleration = 2

def manualFitGPSGroundSpeed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 0
def autoFitGPSGroundSpeed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 1
def slidingWindowGPSGroundSpeed():
    global variableGPSGroundSpeed
    variableGPSGroundSpeed = 2

def manualFitGyroscope():
    global variableGyroscope
    variableGyroscope = 0
def autoFitGyroscope():
    global variableGyroscope
    variableGyroscope = 1
def slidingWindowGyroscope():
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
#add line series to plot
def add_line_series_custom(x_data, y_data,  series_tag, label_text,  tagy):
        gui.add_line_series(x=list(x_data),y=list(y_data), 
                            label=label_text, parent=tagy, 
                            tag=series_tag)


def displayChecklist():
    with gui.tab(label="Checklist", parent='app.main_tab_bar'):
        gui.add_text("SAC Avionics Checklist 2024 Test Launch")

        with gui.group(horizontal=False):

            #add checklist table
            with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                borders_innerH=False, borders_outerH=True, borders_innerV=True,
                borders_outerV=True, context_menu_in_body=True, row_background=True):

                    # create table column to hold checklist
                    gui.add_table_column(label="tasks", width = VIEWPORT_WIDTH/3)
                
                        # demo change

                    
                    
                    # Rows for Checklist Left Side
                    with gui.table_row():
                        with gui.table_cell():
                            with gui.group(horizontal=True):
                                gui.add_checkbox(label="", tag="R28")
                                gui.add_text("Inspect for damages from travel")

                                

                    with gui.table_row():
                        
                        with gui.table_cell():
                            with gui.group(horizontal=True):

                                gui.add_checkbox(label="", tag="R27")
                                with gui.group(horizontal=True):
                                    gui.add_text("Check TeleMetrum battery voltage", color=[250,0,0],tag= "telemetrum_battery_voltage")
    
                                    gui.add_text("", color=[250,0,0],id= "Telemetrum_battery_voltage_value")
                                    gui.add_text("", color=[250,0,0],id= "Telemetrum_battery_units")


                    with gui.table_row():
                        
                        with gui.table_cell():
                            with gui.group(horizontal=True):
                                gui.add_checkbox(label="", tag="R29")

                                
                                gui.add_text("Check TeleMetrum current", color=[250,0,0],tag= "telemetrum_current")
                    with gui.table_row():
                        
                        with gui.table_cell():
                            with gui.group(horizontal=True):
                                gui.add_checkbox(label="", tag="R26")
                                gui.add_text("Check StratoLogger battery voltage", color=[250,0,0],tag= "StratoLogger_battery_voltage")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Check Stratologger settings", tag="R25")

                    with gui.table_row():
                      
                        with gui.table_cell():
                            gui.add_checkbox(label="Check TeleGPS battery voltage", tag="R24")

                    with gui.table_row():
                         
                        with gui.table_cell():
                            gui.add_checkbox(label="Check that TeleMentrum battery is secure", tag="R23")

                    with gui.table_row():
                       
                        with gui.table_cell():
                            gui.add_checkbox(label="Check TeleMetrum to bulkhead connections", tag="R22")

                    with gui.table_row():
                       
                        with gui.table_cell():
                            gui.add_checkbox(label="Check that StratoLogger battery is secure", tag="R21")

                    with gui.table_row():
                       
                        with gui.table_cell():
                            gui.add_checkbox(label="Check that 9V is plugged in", tag="R20")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Check that all cables are inside bay and will not interfere with ISB rails", tag="R19")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Check StratoLogger to cable connection", tag="R18")

                    with gui.table_row():
                       
                        with gui.table_cell():
                            gui.add_checkbox(label="slide avionics bay into ISB", tag="R17")

                    with gui.table_row():
                       
                        with gui.table_cell():
                            gui.add_checkbox(label="Ensure cables are not snagged", tag="R16")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Let Payload Integrate", tag="R15")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Connect TeleMetrum to recovery bulkhead", tag="R14")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Inspect TeleMetrum connection on recovery bulkhead", tag="R13")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Connect StratoLogger to recovery bulkhead", tag="R12")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Inspect Stratologger connection on recovery bulkhead", tag="R11")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Slide ISB partially into coupler", tag="R10")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Feed arming switches down through coupler", tag="R9")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Slide ISB fully into coupler", tag="R8")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Adhere arming switches to coupler", tag="R7")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Let Structures and Recovery Integrate", tag="R6")


                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Connect charges", tag="R5")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Turn on TeleGPS and confirm connection", tag="R4")

                    with gui.table_row():
                        
                        with gui.table_cell():
                            gui.add_checkbox(label="Turn on camera", tag="R3")

                    with gui.table_row():
                    
                        with gui.table_cell():
                            gui.add_checkbox(label="Arm ejection charges", tag="R2")

                    with gui.table_row():
                         
                        with gui.table_cell():
                            gui.add_checkbox(label="Listen for continuity beeps", tag="R1")

                    
                        



                    # create table column to hold plot rows
                    
                        
                


                    



# display the 'tracking' tab of the main GUI
def displayTracking():
    mainWidth = SCREEN_WIDTH-SIDEBAR_BUTTON_WIDTH-SIDEBAR_BUTTON_WIDTH-30


    with gui.tab(label="Tracking", parent='app.main_tab_bar'):


        # tracking tab


 
        with gui.group(horizontal=True,pos=[SIDEBAR_BUTTON_WIDTH+20,500]):
            

            # Plot Altitude data
            with gui.group(horizontal=True):
                with gui.group(horizontal=False):
                    with gui.group(horizontal=True):
                        gui.add_button(label = "Manual Fit", callback = manualFitAltitude)
                        gui.add_button(label = "Auto Fit", callback = autoFitAltitude)
                        gui.add_button(label = "Sliding Window", callback = slidingWindowAltitude)
                    with gui.group(horizontal=False,width=(mainWidth/3)-10):
                        create_plot('Altitude', 'Altitude_y_axis', 'Altitude_x_axis', 'Time(s)', 'Altitude (meters)')
                        add_line_series_custom(original_x_axis, original_y_axis, 'barometer_altitude_tag', 'Barometer Altitude', 'Altitude_y_axis')
                        add_line_series_custom(original_x_axis, original_y_axis, 'gps_altitude_tag', 'GPS Altitude', 'Altitude_y_axis')
                with gui.group(horizontal=True):
                    with gui.group(horizontal=False):
                        with gui.group(horizontal=True):
                            width2, height2, channel2, data2 = gui.load_image("resources/3dgridy2.png", )
                        with gui.texture_registry(show=False):
                            gui.add_static_texture(width=width2, height=height2, default_value=data2, tag="texture_tag2")
                        gui.add_image("texture_tag2", height=VIEWPORT_HEIGHT/2, width=(mainWidth/3)-10)                                
                    with gui.group(horizontal=True):
                        with gui.group(horizontal=True):
                            width5, height5, channel5, data5 = gui.load_image("resources/rocketWithoutLabels.png", )
                            with gui.texture_registry(show=False):
                                gui.add_static_texture(width=width5, height=height5, default_value=data5, tag="texture_tag5")
                            gui.add_image("texture_tag5", height=VIEWPORT_HEIGHT/2, width=(mainWidth/3)-10)


                    
                        




        # Plot Acceleration data
        with gui.group(horizontal=True):
            with gui.group(horizontal=False):
                with gui.group(horizontal=True):
                    gui.add_button(label = "Manual Fit", callback = manualFitAcceleration)
                    gui.add_button(label = "Auto Fit", callback = autoFitAcceleration)
                    gui.add_button(label = "Sliding Window", callback = slidingWindowAcceleration)
                with gui.group(horizontal=False, width= (mainWidth/3)-10):
                    create_plot("Acceleration", 'Acceleration_y_axis', 'Acceleration_x_axis', 'Time(s)', 'Acceleration (m/s^2)')
                    add_line_series_custom(original_x_axis, original_y_axis, 'accelerationZ_tag', 'Acceleration Z ', 'Acceleration_y_axis')
                    add_line_series_custom(original_x_axis, original_y_axis, 'highGaccelerationZ_tag', 'High G Acceleration Z', 'Acceleration_y_axis')
                        



            with gui.group(horizontal=True):
                with gui.group(horizontal=False):
                    with gui.group(horizontal=True):
                        gui.add_button(label = "Manual Fit", callback = manualFitGPSGroundSpeed)
                        gui.add_button(label = "Auto Fit", callback = autoFitGPSGroundSpeed)
                        gui.add_button(label = "Sliding Window", callback = slidingWindowGPSGroundSpeed)
                    with gui.group(horizontal=False,width= (mainWidth/3)-10):
                        create_plot("GPS Ground Speed", 'GPS_Ground_Speed_y_axis', 'GPS_Ground_Speed_x_axis', 'Time(s)', 'Velocity (m/s)')
                        add_line_series_custom(original_x_axis, original_y_axis, 'GPS_Ground_Speed_tag', 'GPS Ground Speed', 'GPS_Ground_Speed_y_axis')

            # Plot gyroscope data
                with gui.group(horizontal=False):
                    with gui.group(horizontal=True):
                        gui.add_button(label = "Manual Fit", callback = manualFitGyroscope)
                        gui.add_button(label = "Auto Fit", callback = autoFitGyroscope)
                        gui.add_button(label = "Sliding Window", callback = slidingWindowGyroscope)
                    with gui.group(horizontal=False,width= (mainWidth/3)-10):
                        create_plot("Gyroscope", 'Gyroscope_y_axis', 'Gyroscope_x_axis', 'Time(s)', '(RPS)')
                        add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_x_tag', "Gyroscope X Data", 'Gyroscope_y_axis')
                        add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_y_tag', "Gyroscope Y Data", 'Gyroscope_y_axis')
                        add_line_series_custom(original_x_axis, original_y_axis, 'Gyroscope_z_tag', "Gyroscope Z Data", 'Gyroscope_y_axis')



        with gui.group(horizontal=True,pos=[SCREEN_WIDTH-SIDEBAR_BUTTON_WIDTH,SCREEN_HEIGHT/16]):
            with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
            borders_innerH=False, borders_outerH=True, borders_innerV=True,
            borders_outerV=True, context_menu_in_body=True, row_background=True,pos=[SCREEN_WIDTH-SIDEBAR_BUTTON_WIDTH,200]):
                
            # create table column to hold plot rows
                gui.add_table_column(label="primary_column",width=SIDEBAR_BUTTON_WIDTH)
                
                
                # Row for Right Table
            
                with gui.table_row( height=VIEWPORT_HEIGHT/100):
                    with gui.table_cell():
                        gui.add_text("Latitude/Longitude:",)
                        with gui.group(horizontal=True):
                            gui.add_text("(")
                            gui.add_text("0.00", id='latitude')
                            gui.add_text(",")
                            gui.add_text("0.00", id='longitude')
                            gui.add_text(")")
                with gui.table_row( height=VIEWPORT_HEIGHT/10):
                    with gui.table_cell():
                        gui.add_text("Telemetrum\nVoltage:")
                        gui.add_text("0.00", id="telemetrumVoltage")
                        gui.add_text("Stratologger\nVoltage:")
                        gui.add_text("0.00", id="stratologgerVoltage")
                        gui.add_text("Camera\nVoltage:")
                        gui.add_text("0.00", id="cameraVoltage")
                        gui.add_text("Battery\nVoltage:")
                        gui.add_text("0.00", id="batteryVoltage")
                with gui.table_row( height=VIEWPORT_HEIGHT/10):
                    with gui.table_cell():
                        gui.add_text("Telemetrum\nCurrent:")
                        gui.add_text("0.00", id="telemetrumCurrent")
                        gui.add_text("Stratologger\nCurrent:")
                        gui.add_text("0.00", id="stratologgerCurrent")
                        gui.add_text("Camera\nCurrent:")
                        gui.add_text("0.00", id="cameraCurrent")
                with gui.table_row( height=VIEWPORT_HEIGHT/10):
                    with gui.table_cell():
                        gui.add_text("Battery\nTemperature:")
                        gui.add_text("0.00", id="batteryTemperature")

                    
                    
                

# diagnostic info goes here
def displayHealth():
    with gui.tab(label="Health", parent='app.main_tab_bar'):
        gui.add_text("General system diagnostic info goes here")

# raw packet/signal data
#def displayPackets():
    #with gui.tab(label="Packets", parent='app.main_tab_bar'):
        #startWritingToFile()
        #writePacketToFile()
        #gui.add_button(label="Click",  callback=writePacketToFile())
        #gui.add_button(label="Click",  callback=writePacketToFile())



# info relevant to rocket recovery goes here
def displayRecovery():
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
        #displaySidebar()
        #with gui.group(horizontal=True):

        self.displaySidebar()

        #with gui.tab_bar(pos=(200, 200)) as tb:
        #tracking tab
        displayTracking()
        displayChecklist()
        #health tab
        #displayHealth()
        #packets tab
        #displayPackets()
        #recovery tab
        #displayRecovery()



        #with gui.tab(label='Telemetry', parent='app.main_tab_bar'):
    # Create the gui stuff:
    
    
    def displaySidebar(self):
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
            gui.add_button(label='Telemetrum Armed', tag='telemetrum_armed_tag', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="disarm_telemetrum_popup"):
                gui.add_text("Disarm Telemetrum?")
                gui.add_button(label="Yes",  callback=self.disarmCamera)
            gui.bind_item_theme('telemetrum_armed_tag', "theme_armed")
            gui.configure_item("disarm_telemetrum_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Stratologger Armed', tag='stratologger_armed_tag', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="disarm_stratologger_popup"):
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes",  callback=self.disarmSRADfc)
            gui.bind_item_theme('stratologger_armed_tag', "theme_armed")
            gui.configure_item("disarm_stratologger_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Camera Armed', tag='camera_armed_tag', width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="disarm_camera_popup"):
                gui.add_text("Arm Camera?")
                gui.add_button(label="Yes",  callback=self.disarmCOTSfc)
            gui.bind_item_theme('camera_armed_tag', "theme_armed")
            gui.configure_item("disarm_camera_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))
            
            

            #make Unarmed buttons
            gui.add_button(label='Telemetrum \n Disarmed', tag='telemetrum_disarmed_tag',width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="arm_telemetrum_popup"):
                #print("I AM HERE!!!")
                gui.add_text("Arm Stratologger?")
                gui.add_button(label="Yes",  callback=self.armCamera)
            gui.bind_item_theme('telemetrum_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_telemetrum_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Stratologger\nDisarmed', tag='stratologger_disarmed_tag',width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="arm_stratologger_popup"):
                gui.add_text("Disarm Stratologger?")
                gui.add_button(label="Yes",  callback=self.armSRADfc)
            gui.bind_item_theme('stratologger_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_stratologger_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))

            gui.add_button(label='Camera\nDisarmed', tag='camera_disarmed_tag',width=SIDEBAR_BUTTON_WIDTH, height=SIDEBAR_BUTTON_HEIGHT)
            with gui.popup(gui.last_item(), mousebutton=gui.mvMouseButton_Left, modal=True, tag="arm_camera_popup"):
                gui.add_text("Disarm Camera?")
                gui.add_button(label="Yes",  callback=self.armCOTSfc)
            gui.bind_item_theme('camera_disarmed_tag', "theme_unarmed")
            gui.configure_item("arm_camera_popup", pos = (POPUP_POSITIONX, POPUP_POSITIONY))

            #start without showing unarmed button
            # gui.configure_item(item="COTS_fc_unarmed_tag", show=False)


            with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                    borders_innerH=False, borders_outerH=True, borders_innerV=True,
                    borders_outerV=True, context_menu_in_body=True, row_background=True, width=SIDEBAR_BUTTON_WIDTH):
                        
                    # create table column to hold plot rows
                        gui.add_table_column(label="primary_columns", width=VIEWPORT_WIDTH/100)

                        with gui.table_row(height=VIEWPORT_HEIGHT/100):
                            with gui.table_cell():
                                gui.add_text("Altitude Barometer:")
                                gui.add_text("0.00", id="altitudeBarometer")
                                gui.add_text("Altitude GPS:")
                                gui.add_text("0.00", id="altitudeGPS")
                        with gui.table_row(height=VIEWPORT_HEIGHT/100):
                            with gui.table_cell():
                                gui.add_text("Acceleration X:")
                                gui.add_text("0.00", id="accelerationX")
                                gui.add_text("Acceleration Y:")
                                gui.add_text("0.00", id="accelerationY")
                                gui.add_text("Acceleration Z:")
                                gui.add_text("0.00", id="accelerationZ")
                        with gui.table_row(height=VIEWPORT_HEIGHT/100):
                            with gui.table_cell():
                                gui.add_text("High G Acceleration X:")
                                gui.add_text("0.00", id="highGaccelerationX")
                                gui.add_text("High G Acceleration Y:")
                                gui.add_text("0.00", id="highGaccelerationY")
                                gui.add_text("High G Acceleration Z:")
                                gui.add_text("0.00", id="highGaccelerationZ")
                        with gui.table_row(height=VIEWPORT_HEIGHT/100):
                            with gui.table_cell():
                                gui.add_text("GPS Ground Speed:")
                                gui.add_text("0.00", id="GPSGroundSpeed")
                        with gui.table_row(height=VIEWPORT_HEIGHT/25):
                            with gui.table_cell():
                                gui.add_text("Gyroscope X data:")
                                gui.add_text("0.00", id="gyroscopeX")
                                gui.add_text("Gyroscope Y data:")
                                gui.add_text("0.00", id="gyroscopeY")
                                gui.add_text("Gyroscope Z data:")
                                gui.add_text("0.00", id="gyroscopeZ")


    def armCamera(self) -> None:
        self.iliad.arm_telemetrum()
        gui.configure_item("arm_telemetrum_popup", show=False)
        return

    def armSRADfc(self):
        self.iliad.arm_stratologger()
        gui.configure_item("arm_stratologger_popup", show=False)
        return

    def armCOTSfc(self):
        self.iliad.arm_cots_flight_computer()
        gui.configure_item("arm_camera_popup", show=False)
        return


    def disarmCamera(self):
        self.iliad.disarm_telemetrum()
        gui.configure_item("disarm_telemetrum_popup", show=False)
        return

    def disarmSRADfc(self):
        self.iliad.disarm_stratologger()
        gui.configure_item("disarm_stratologger_popup", show=False)
        return

    def disarmCOTSfc(self):
        self.iliad.disarm_cots_flight_computer()
        gui.configure_item("disarm_camera_popup", show=False)
        return

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
            

            if(len(self.iliad.telemetrum_voltage.y_data)>=1):
                if(self.iliad.telemetrum_voltage.y_data[len(self.iliad.telemetrum_voltage.y_data)-1 ]>= TELEMETRUM_VOLTAGE_EXPECTED ):
                    gui.configure_item(item="telemetrum_battery_voltage", color=[0,250,0])
                    gui.set_value("Telemetrum_battery_voltage_value", "")
                    gui.set_value("Telemetrum_battery_units", "")

                else:
                    gui.configure_item(item="telemetrum_battery_voltage", color=[250,0,0])
                    gui.set_value("Telemetrum_battery_voltage_value", round(self.iliad.telemetrum_voltage.y_data[len(self.iliad.telemetrum_voltage.y_data)-1],2))
                    gui.set_value("Telemetrum_battery_units", "volts")

            if(len(self.iliad.telemetrum_current.y_data)>=1):
                if(self.iliad.telemetrum_current.y_data[len(self.iliad.telemetrum_current.y_data)-1 ]>= TELEMETRUM_CURRENT ):
                    gui.configure_item(item="telemetrum_current", color=[0,250,0])
                else:
                    gui.configure_item(item="telemetrum_current", color=[250,0,0])
            if(len(self.iliad.stratologger_voltage.y_data)>=1):
                if(self.iliad.stratologger_voltage.y_data[len(self.iliad.stratologger_voltage.y_data)-1 ]>= STRATOLOGGER_VOLATGE ):
                    gui.configure_item(item="StratoLogger_battery_voltage", color=[0,250,0])
                else:
                    gui.configure_item(item="StratoLogger_battery_voltage", color=[250,0,0])
            sample = 1
            frequency=1.0   

                    

            ###Arming Status###
            
            if(self.iliad.telemetrum_status.y_data):
                gui.configure_item(item="telemetrum_armed_tag", show=True)
                gui.configure_item(item="telemetrum_disarmed_tag", show=False)

            else:
                gui.configure_item(item="telemetrum_armed_tag", show=False)
                gui.configure_item(item="telemetrum_disarmed_tag", show=True)

            if(self.iliad.stratologger_status.y_data):
                gui.configure_item(item="stratologger_armed_tag", show=True)
                gui.configure_item(item="stratologger_disarmed_tag", show=False)

            else:
                gui.configure_item(item="stratologger_armed_tag", show=False)
                gui.configure_item(item="stratologger_disarmed_tag", show=True)



            if(self.iliad.camera_status.y_data):
                gui.configure_item(item="camera_armed_tag", show=True)
                gui.configure_item(item="camera_disarmed_tag", show=False)

            else:
                gui.configure_item(item="camera_armed_tag", show=False)
                gui.configure_item(item="camera_disarmed_tag", show=True)

            ###LEFT SIDE BAR###

            #set altitude variable value
            if(len(self.iliad.barometer_altitude.y_data) >= 1):
                gui.set_value('altitudeBarometer', round((self.iliad.barometer_altitude.y_data[len(self.iliad.barometer_altitude.y_data)-1]),2))

            if(len(self.iliad.gps_altitude.y_data) >= 1):
                gui.set_value('altitudeGPS', round((self.iliad.gps_altitude.y_data[len(self.iliad.gps_altitude.y_data)-1]),2))

            #set regular acceleration variable values
            if(len(self.iliad.accelerometer_x.y_data) >= 1):
                gui.set_value('accelerationX', round((self.iliad.accelerometer_x.y_data[len(self.iliad.accelerometer_x.y_data)-1]),2))

            if(len(self.iliad.accelerometer_y.y_data) >= 1):
                gui.set_value('accelerationY', round((self.iliad.accelerometer_y.y_data[len(self.iliad.accelerometer_y.y_data)-1]),2))

            if(len(self.iliad.accelerometer_z.y_data) >= 1):
                gui.set_value('accelerationZ', round((self.iliad.accelerometer_z.y_data[len(self.iliad.accelerometer_z.y_data)-1]),2))

            #set high g acceleration variable values
            if(len(self.iliad.high_g_accelerometer_x.y_data) >= 1):
                gui.set_value('highGaccelerationX', round((self.iliad.high_g_accelerometer_x.y_data[len(self.iliad.high_g_accelerometer_x.y_data)-1]),2))

            if(len(self.iliad.high_g_accelerometer_y.y_data) >= 1):
                gui.set_value('highGaccelerationY', round((self.iliad.high_g_accelerometer_y.y_data[len(self.iliad.high_g_accelerometer_y.y_data)-1]),2))

            if(len(self.iliad.high_g_accelerometer_z.y_data) >= 1):
                gui.set_value('highGaccelerationZ', round((self.iliad.high_g_accelerometer_z.y_data[len(self.iliad.high_g_accelerometer_z.y_data)-1]),2))
            

            #set ground speed data variable value
            if(len(self.iliad.gps_ground_speed.y_data) >= 1):
                gui.set_value('GPSGroundSpeed', round((self.iliad.gps_ground_speed.y_data[len(self.iliad.gps_ground_speed.y_data)-1]),2))

            #set gyroscope variable values
            if(len(self.iliad.gyroscope_x.y_data) >= 1):
                gui.set_value('gyroscopeX', round((self.iliad.gyroscope_x.y_data[len(self.iliad.gyroscope_x.y_data)-1]),2))

            if(len(self.iliad.gyroscope_y.y_data) >= 1):
                gui.set_value('gyroscopeY', round((self.iliad.gyroscope_y.y_data[len(self.iliad.gyroscope_y.y_data)-1]),2))

            if(len(self.iliad.gyroscope_z.y_data) >= 1):
                gui.set_value('gyroscopeZ', round((self.iliad.gyroscope_z.y_data[len(self.iliad.gyroscope_z.y_data)-1]),2))

                

            ###RIGHT SIDE BAR###
                #set latitude/longitude variable values
                if(len(self.iliad.gps_latitude.y_data) >= 1):
                    gui.set_value('latitude', round((self.iliad.gps_latitude.y_data[len(self.iliad.gps_latitude.y_data)-1]),2))
                
                if(len(self.iliad.gps_longitude.y_data) >= 1):
                    gui.set_value('longitude', round((self.iliad.gps_longitude.y_data[len(self.iliad.gps_longitude.y_data)-1]),2))

                #set voltage variable values
                if(len(self.iliad.telemetrum_voltage.y_data) >= 1):
                    gui.set_value('telemetrumVoltage', round((self.iliad.telemetrum_voltage.y_data[len(self.iliad.telemetrum_voltage.y_data)-1]),2))

                if(len(self.iliad.stratologger_voltage.y_data) >= 1):
                    gui.set_value('stratologgerVoltage', round((self.iliad.stratologger_voltage.y_data[len(self.iliad.stratologger_voltage.y_data)-1]),2))

                if(len(self.iliad.camera_voltage.y_data) >= 1):
                    gui.set_value('cameraVoltage', round((self.iliad.camera_voltage.y_data[len(self.iliad.camera_voltage.y_data)-1]),2))

                if(len(self.iliad.battery_voltage.y_data) >= 1):
                    gui.set_value('batteryVoltage', round((self.iliad.battery_voltage.y_data[len(self.iliad.battery_voltage.y_data)-1]),2))

                #set board current variable values
                if(len(self.iliad.telemetrum_current.y_data) >= 1):
                    gui.set_value('telemetrumCurrent', round((self.iliad.telemetrum_current.y_data[len(self.iliad.telemetrum_current.y_data)-1]),2))

                if(len(self.iliad.stratologger_current.y_data) >= 1):
                    gui.set_value('stratologgerCurrent', round((self.iliad.stratologger_current.y_data[len(self.iliad.stratologger_current.y_data)-1]),2))

                if(len(self.iliad.camera_current.y_data) >= 1):
                    gui.set_value('cameraCurrent', round((self.iliad.camera_current.y_data[len(self.iliad.camera_current.y_data)-1]),2))

                
                #set board temperature variable values
                if(len(self.iliad.battery_temperature.y_data) >= 1):
                    gui.set_value('batteryTemperature', round((self.iliad.battery_temperature.y_data[len(self.iliad.battery_temperature.y_data)-1]),2))

                
        # Get new data sample. Note we need both x and y values
        # if we want a meaningful axis unit.
        #t = time.time() - t0
        #y = (2.0 * frequency * t)
        #y2= (4.0 * sin(frequency) * t)
        #y3=(4.0 * frequency * t)
        #AY_axis.append(y)
        #Altitude.append(t)
        #BY_axis.append(y2)
        #Acceleration.append(t)
        #CY_axis.append(y3)
        #Velocity.append(t)

            
            #set the series x and y to the last nsamples
            # Set altitude data:
            gui.set_value('barometer_altitude_tag', [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
            #gui.fit_axis_data('Altitude_x_axis')
            #gui.fit_axis_data('Altitude_y_axis')

            gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
            #gui.fit_axis_data('Altitude_x_axis')
            #gui.fit_axis_data('Altitude_y_axis')

        
            #set acceleration X data:
            #gui.set_value('AccelerationX_tag', [self.iliad.acceleration_x_data.x_data, self.iliad.acceleration_x_data.y_data])
            #gui.fit_axis_data('Acceleration_x_axis')
            #gui.fit_axis_data('Acceleration_y_axis')
            
            #set acceleration Y data:
            #gui.set_value('AccelerationY_tag', [self.iliad.acceleration_y_data.x_data, self.iliad.acceleration_x_data.y_data])
            #gui.fit_axis_data('Acceleration_x_axis')
            #gui.fit_axis_data('Acceleration_y_axis')

            #set acceleration Z data:
            gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
            #gui.fit_axis_data('Acceleration_x_axis')
            #gui.fit_axis_data('Acceleration_y_axis')

            #set high G acceleration Z data:
            gui.set_value('highGaccelerationZ_tag', [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
            #gui.fit_axis_data('Acceleration_x_axis')
            #gui.fit_axis_data('Acceleration_y_axis')

            #if(len(self.iliad.gps_latitude_data.y_data) >= 1):
                #print(self.iliad.gps_latitude_data.y_data[len(self.iliad.gps_latitude_data.y_data)-1])
            #set gps latitude data:
            #gui.set_value('GPS_Latitude_tag', self.iliad.gps_latitude_data.y_data[len(self.iliad.gps_latitude_data.y_data)])
            #gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')
            #gui.fit_axis_data('GPS_Latitude_and_Longitude_y_axis')

            #set gps longitude data:
            #gui.set_value('GPS_Longitude_tag', [self.iliad.gps_longitude_data.x_data, self.iliad.gps_longitude_data.y_data])
            #gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')
            #gui.fit_axis_data('GPS_Latitude_and_Longitude_x_axis')

            #set board 1 temperature data:
            #gui.set_value('board_1_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
            #gui.fit_axis_data('board_temperature_data_x_axis')
            #gui.fit_axis_data('board_temperature_data_y_axis')

            #set board 2 temperature data:
            #gui.set_value('board_2_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
            #gui.fit_axis_data('board_temperature_data_x_axis')
            #gui.fit_axis_data('board_temperature_data_y_axis')

            #set board 3 temperature data:
            #gui.set_value('board_3_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
            #gui.fit_axis_data('board_temperature_data_x_axis')
            #gui.fit_axis_data('board_temperature_data_y_axis')

            #set board 4 temperature data:
            #gui.set_value('board_4_temperature_data_tag', [self.iliad.board_1_temperature_data.x_data, self.iliad.board_1_temperature_data.y_data])
            #gui.fit_axis_data('board_temperature_data_x_axis')
            #gui.fit_axis_data('board_temperature_data_y_axis')

            #set board 1 voltage data:
            #gui.set_value('board_1_voltage_data_tag', [self.iliad.board_1_voltage_data.x_data, self.iliad.board_1_voltage_data.y_data])
            #gui.fit_axis_data('Board_Voltage_x_axis')
            #gui.fit_axis_data('Board_Voltage_y_axis')

            #set board 2 voltage data:
            #gui.set_value('board_2_voltage_data_tag', [self.iliad.board_2_voltage_data.x_data, self.iliad.board_2_voltage_data.y_data])
            #gui.fit_axis_data('Board_Voltage_x_axis')
            #gui.fit_axis_data('Board_Voltage_y_axis')

            #set board 3 voltage data:
            #gui.set_value('board_3_voltage_data_tag', [self.iliad.board_3_voltage_data.x_data, self.iliad.board_3_voltage_data.y_data])
            #gui.fit_axis_data('Board_Voltage_x_axis')
            #gui.fit_axis_data('Board_Voltage_y_axis')

            #set board 4 voltage data:
            #gui.set_value('board_4_voltage_data_tag', [self.iliad.board_4_voltage_data.x_data, self.iliad.board_4_voltage_data.y_data])
            #gui.fit_axis_data('Board_Voltage_x_axis')
            #gui.fit_axis_data('Board_Voltage_y_axis')

        #set board 1 current data:
            #gui.set_value('board_1_current_data_tag', [self.iliad.board_1_current_data.x_data, self.iliad.board_1_voltage_data.y_data])
            #gui.fit_axis_data('Board_Current_x_axis')
            #gui.fit_axis_data('Board_Current_y_axis')

            #set board 2 current data:
            #gui.set_value('board_2_current_data_tag', [self.iliad.board_2_current_data.x_data, self.iliad.board_2_voltage_data.y_data])
            #gui.fit_axis_data('Board_Current_x_axis')
            #gui.fit_axis_data('Board_Current_y_axis')

            #set board 3 current data:
            #gui.set_value('board_3_current_data_tag', [self.iliad.board_3_current_data.x_data, self.iliad.board_3_voltage_data.y_data])
            #gui.fit_axis_data('Board_Current_x_axis')
            #gui.fit_axis_data('Board_Current_y_axis')

            #set board 4 current data:
            #gui.set_value('board_4_current_data_tag', [self.iliad.board_4_current_data.x_data, self.iliad.board_4_voltage_data.y_data])
            #gui.fit_axis_data('Board_Current_x_axis')
            #gui.fit_axis_data('Board_Current_y_axis')

            #set battery 1 current data:
            #gui.set_value('battery_1_voltage_data_tag', [self.iliad.battery_1_voltage_data.x_data, self.iliad.board_1_voltage_data.y_data])
            #gui.fit_axis_data('Battery_Voltage_x_axis')
            #gui.fit_axis_data('Battery_Voltage_y_axis')

            #set battery 2 current data:
            #gui.set_value('battery_2_voltage_data_tag', [self.iliad.battery_2_voltage_data.x_data, self.iliad.board_2_voltage_data.y_data])
            #gui.fit_axis_data('Battery_Voltage_x_axis')
            #gui.fit_axis_data('Battery_Voltage_y_axis')

            #set battery 3 current data:
            #gui.set_value('battery_3_voltage_data_tag', [self.iliad.battery_3_voltage_data.x_data, self.iliad.board_3_voltage_data.y_data])
            #gui.fit_axis_data('Battery_Voltage_x_axis')
            #gui.fit_axis_data('Battery_Voltage_y_axis')

            #set magnetometer 1 data:
            #gui.set_value('Magnetometer_X_tag', [self.iliad.magnetometer_data_1.x_data, self.iliad.magnetometer_data_1.y_data])
            #gui.fit_axis_data('Magnetometer_x_axis')
            #gui.fit_axis_data('Magnetometer_y_axis')

            #set magnetometer 2 data:
            #gui.set_value('Magnetometer_Y_tag', [self.iliad.magnetometer_data_2.x_data, self.iliad.magnetometer_data_2.y_data])
            #gui.fit_axis_data('Magnetometer_x_axis')
            #gui.fit_axis_data('Magnetometer_y_axis')

            #set magnetometer 3 data:
            #gui.set_value('Magnetometer_Z_tag', [self.iliad.magnetometer_data_3.x_data, self.iliad.magnetometer_data_3.y_data])
            #gui.fit_axis_data('Magnetometer_x_axis')
            #gui.fit_axis_data('Magnetometer_y_axis')

            #set gyroscope X data:
            gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
            #gui.fit_axis_data('Gyroscope_x_axis')
            #gui.fit_axis_data('Gyroscope_y_axis')

            #set gyroscope Y data:
            gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
            #gui.fit_axis_data('Gyroscope_x_axis')
            #gui.fit_axis_data('Gyroscope_y_axis')

            #set gyroscope Z data:
            gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
            #gui.fit_axis_data('Gyroscope_x_axis')
            #gui.fit_axis_data('Gyroscope_y_axis')

            """#set gps satellites data:
            gui.set_value('GPS_Satellites_tag', [self.iliad.gps_satellites_data.x_data, self.iliad.gps_satellites_data.y_data])
            gui.fit_axis_data('GPS_Satellites_x_axis')
            gui.fit_axis_data('GPS_Satellites_y_axis')"""

            #set gps ground speed data:
            
            gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
            #gui.fit_axis_data('GPS_Ground_Speed_x_axis')
            #gui.fit_axis_data('GPS_Ground_Speed_y_axis')

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

        #update_data()

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
        
           
            #Altitude
            if(variableAltitude == 1):
                gui.fit_axis_data("Altitude_x_axis")
                gui.fit_axis_data("Altitude_y_axis")
                gui.set_value('barometer_altitude_tag', [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
                gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
            if(variableAltitude == 0):
                gui.set_axis_limits_auto("Altitude_x_axis")
                gui.set_axis_limits_auto("Altitude_y_axis")
                gui.set_value('barometer_altitude_tag', [self.iliad.barometer_altitude.x_data, self.iliad.barometer_altitude.y_data])
                gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data, self.iliad.gps_altitude.y_data])
            if(variableAltitude == 2):
                gui.fit_axis_data("Altitude_x_axis")
                gui.fit_axis_data("Altitude_y_axis")
                gui.set_value('barometer_altitude_tag', [self.iliad.barometer_altitude.x_data[-nsamples:], self.iliad.barometer_altitude.y_data[-nsamples:]])
                gui.set_value('gps_altitude_tag', [self.iliad.gps_altitude.x_data[-nsamples:], self.iliad.gps_altitude.y_data[-nsamples:]])

            #Acceleration
            if(variableAcceleration == 1):
                gui.fit_axis_data("Acceleration_x_axis")
                gui.fit_axis_data("Acceleration_y_axis")
                gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
                gui.set_value('highGaccelerationZ_tag', [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
            if(variableAcceleration == 0):
                gui.set_axis_limits_auto("Acceleration_x_axis")
                gui.set_axis_limits_auto("Acceleration_y_axis")
                gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data, self.iliad.accelerometer_z.y_data])
                gui.set_value('highGaccelerationZ_tag', [self.iliad.high_g_accelerometer_z.x_data, self.iliad.high_g_accelerometer_z.y_data])
            if(variableAcceleration == 2):
                gui.fit_axis_data("Acceleration_x_axis")
                gui.fit_axis_data("Acceleration_y_axis")
                gui.set_value('accelerationZ_tag', [self.iliad.accelerometer_z.x_data[2*-nsamples:], self.iliad.accelerometer_z.y_data[2*-nsamples:]])
                gui.set_value('highGaccelerationZ_tag', [self.iliad.high_g_accelerometer_z.x_data[-nsamples:], self.iliad.high_g_accelerometer_z.y_data[-nsamples:]])

            #GPS Ground Speed
            if(variableGPSGroundSpeed == 1):
                gui.fit_axis_data("GPS_Ground_Speed_x_axis")
                gui.fit_axis_data("GPS_Ground_Speed_y_axis")
                gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
            if(variableGPSGroundSpeed == 0):
                gui.set_axis_limits_auto("GPS_Ground_Speed_x_axis")
                gui.set_axis_limits_auto("GPS_Ground_Speed_y_axis")
                gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data, self.iliad.gps_ground_speed.y_data])
            if(variableGPSGroundSpeed == 2):
                gui.fit_axis_data("GPS_Ground_Speed_x_axis")
                gui.fit_axis_data("GPS_Ground_Speed_y_axis")
                gui.set_value('GPS_Ground_Speed_tag', [self.iliad.gps_ground_speed.x_data[-nsamples:], self.iliad.gps_ground_speed.y_data[-nsamples:]])
                

            #Gyroscope
            if(variableGyroscope == 1):
                gui.fit_axis_data("Gyroscope_x_axis")
                gui.fit_axis_data("Gyroscope_y_axis")
                gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
                gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
                gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
            if(variableGyroscope == 0):
                gui.set_axis_limits_auto("Gyroscope_x_axis")
                gui.set_axis_limits_auto("Gyroscope_y_axis")
                gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data, self.iliad.gyroscope_x.y_data])
                gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data, self.iliad.gyroscope_y.y_data])
                gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data, self.iliad.gyroscope_z.y_data])
            if(variableGyroscope == 2):
                gui.fit_axis_data("Gyroscope_x_axis")
                gui.fit_axis_data("Gyroscope_y_axis")
                gui.set_value('Gyroscope_x_tag', [self.iliad.gyroscope_x.x_data[-nsamples:], self.iliad.gyroscope_x.y_data[-nsamples:]])
                gui.set_value('Gyroscope_y_tag', [self.iliad.gyroscope_y.x_data[-nsamples:], self.iliad.gyroscope_y.y_data[-nsamples:]])
                gui.set_value('Gyroscope_z_tag', [self.iliad.gyroscope_z.x_data[-nsamples:], self.iliad.gyroscope_z.y_data[-nsamples:]])
        
            time.sleep(0.01)
            sample=sample+1



# Create the gui stuff:
        #with gui.group(horizontal=False):
            #displaySidebar()