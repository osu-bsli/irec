import dearpygui.dearpygui as dpg
from math import sin

step=10
count=1/step
def initialize(t='Dear PyGui', w=800, h=800):
 
    dpg.create_context()    
    dpg.create_viewport(title=t, width=w, height=h)
    dpg.setup_dearpygui()
    dpg.show_viewport()

def start():
    dpg.start_dearpygui()

def teardown():
    dpg.destroy_context()


def createCursorPlot(data, lab="Plot", w=500, h=500):
    with dpg.window(label=lab, width=w, height=h):
        dpg.add_simple_plot(label="Sin Wave Coordinates", min_scale=-1.0, max_scale=1.0, height=300, tag="plot")
        # dpg.add_plot_legend()



def update_plot_data(sender, app_data, plot_data):
    mouse_y = app_data[1]
    if len(plot_data) > 100:
        plot_data.pop(0)
    plot_data.append(sin(mouse_y / 30))
    dpg.set_value("plot", plot_data)


def update_plot_sin(sender, app_data, plot_data):
    if len(plot_data) > 100:
        plot_data.pop(0)
    global count
    count=count+ 1/step
    plot_data.append(sin(count))
    dpg.set_value("plot", plot_data)

# ________________________________________

initialize('GUI time', 800, 800)

data = []

createCursorPlot(data, 'testplot', 500, 500)
# createCursorPlot(data, 'testplot2', 500, 500)

with dpg.handler_registry():
    dpg.add_mouse_move_handler(callback=update_plot_sin, user_data=data)

start()
teardown()
