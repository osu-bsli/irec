# code from my1e5#2631 on the Discord
import dearpygui.dearpygui as dpg
dpg.create_context()

with dpg.window():
    with dpg.plot():
        dpg.add_plot_legend()
        dpg.add_plot_axis(dpg.mvXAxis)
        with dpg.plot_axis(dpg.mvYAxis):
            for i in range(4):
                dpg.add_line_series([0, 1], [0, i+1], label=f"line{i}")
                dpg.add_color_picker(parent=dpg.last_item())

dpg.create_viewport(width=1000, height=1000)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()