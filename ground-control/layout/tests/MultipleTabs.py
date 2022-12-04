import dearpygui.dearpygui as dpg
from math import sin

dpg.create_context()

# creating data
sindatax = []
sindatay = []
for i in range(0, 5000):
    sindatax.append(i / 10000)
    sindatay.append(0.5 + 0.5 * sin(50 * i / 10000))

def plot(title, tagName):
        dpg.create_context()
        dpg.window(label=title)
        pass
        with dpg.plot(label=title, height=800, width=800):
            # optionally create legend
            dpg.add_plot_legend()

            # REQUIRED: create x and y axes
            dpg.add_plot_axis(dpg.mvXAxis, label="x")
            dpg.add_plot_axis(dpg.mvYAxis, label="y", tag=tagName)

            # series belong to a y axis
            dpg.add_line_series(sindatax, sindatay, label="0.5 + 0.5 * sin(x)", parent=tagName)

def initializeMenuBar():
    dpg.create_viewport(title='Custom Title', width=1200, height=800)
    # with dpg.tab_bar(parent='Custom Title'):
    #     with dpg.tab("tab 1"):
    #         dpg.add_text("This is the tab 1!")

    #     with dpg.tab("tab 2"):
    #         dpg.add_text("This is the tab 2!")

    #     with dpg.tab("tab 3"):
    #         dpg.add_text("This is the tab 3!")

    #     with dpg.tab("tab 4"):
    #         dpg.add_text("This is the tab 4!")
    
    
    
    
    # with dpg.tab_bar():
    #     with dpg.tab(label="Graph 1"):
    #         dpg.add_text("Series 1")
    #         # plot("Series 1", "a")
    #     with dpg.tab(label="Graph 2"):
    #         dpg.add_text("Series 2")
    #         # plot("Series 2", "b") 
    #     with dpg.tab(label="Graph 3"):
    #         dpg.add_text("Series 3")
    #         # plot("Series 3", "c")



    with dpg.viewport_menu_bar():
        with dpg.menu(label="Graph 1"):
                   plot("Series 1", "a")
        with dpg.menu(label="Graph 2"):
                   plot("Series 2", "b") 
        with dpg.menu(label="Graph 3"):
                   plot("Series 3", "c")



initializeMenuBar()
dpg.setup_dearpygui()
dpg.show_viewport()

# add_window('window1',height=200,width=300)
while dpg.is_dearpygui_running():
    dpg.render_dearpygui_frame()

dpg.destroy_context()