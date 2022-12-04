# code from https://dearpygui.readthedocs.io/en/latest/documentation/plots.html#querying
# modified
# from dearpygui.dearpygui import *
import dearpygui.dearpygui as dpg
from math import sin

dpg.create_context()

sindatax = []
sindatay = []
for i in range(0, 10000):
    sindatax.append(i / 10000)
    sindatay.append(0.5 + 0.5 * sin(50 * i / 10000))

with dpg.window(label="Tutorial", width=1200, height=900):
    dpg.add_text("Click and drag the middle mouse button over the top plot to set window & zoom")
    
    def query(sender, app_data, user_data):
        dpg.set_axis_limits("xaxis_tag2", app_data[0], app_data[1])
        dpg.set_axis_limits("yaxis_tag2", app_data[2], app_data[3])


    # plot 1
    with dpg.plot(no_title=True, height=400, callback=query, query=True, width=-1):
        dpg.add_plot_legend()
        dpg.add_plot_axis(dpg.mvXAxis, label="x")
        dpg.add_plot_axis(dpg.mvYAxis, label="y")
        dpg.add_line_series(sindatax, sindatay, parent=dpg.last_item())

    # plot 2
    with dpg.plot(no_title=True, height=400, width=-1):
        dpg.add_plot_legend()
        dpg.add_plot_axis(dpg.mvXAxis, label="x1", tag="xaxis_tag2")
        dpg.add_plot_axis(dpg.mvYAxis, label="y1", tag="yaxis_tag2")
        dpg.add_line_series(sindatax, sindatay, parent="yaxis_tag2")

dpg.create_viewport(title='Middle Click to Create Pane', width=1200, height=800)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()