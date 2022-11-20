import dearpygui.dearpygui as dpg
from math import sin

dpg.create_context()

sindatax = []
sindatay = []
for i in range(0, 100):
    sindatax.append(i / 100)
    sindatay.append(0.5 + 0.5 * sin(50 * i / 100))

with dpg.window(label="Tutorial", width=400, height=400):
    # create plot
    dpg.add_text("Right click a series in the legend!")
    with dpg.plot(label="Line Series", height=-1, width=-1):
        dpg.add_plot_legend()

        dpg.add_plot_axis(dpg.mvXAxis, label="x")
        dpg.add_plot_axis(dpg.mvYAxis, label="y", tag="yaxis")

        # series 1
        dpg.add_line_series(sindatax, sindatay, label="series 1", parent="yaxis", tag="series_1")
        dpg.add_button(label="Delete Series 1", parent=dpg.last_item(), callback=lambda: dpg.delete_item("series_1"))

        # series 2
        dpg.add_line_series(sindatax, sindatay, label="series 2", parent="yaxis", tag="series_2")
        dpg.add_button(label="Delete Series 2", parent=dpg.last_item(), callback=lambda: dpg.delete_item("series_2"))

dpg.create_viewport(title='Custom Title', width=800, height=600)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()