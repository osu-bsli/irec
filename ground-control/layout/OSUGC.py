import dearpygui.dearpygui as dpg
import constants as c

dpg.create_context()

with dpg.window(label="OSUGC", width=c.WINDOW_WIDTH, height=c.WINDOW_HEIGHT):      # One window to rule them all
    with dpg.menu_bar():                                    # menu bar inside window
        with dpg.menu(label="Menu Item 1"): 
            dpg.add_menu_item(label="Option 1")
            dpg.add_menu_item(label="Option 2")
            dpg.add_menu_item(label="Option 3")
        with dpg.menu(label="Menu Item 2"):
            dpg.add_menu_item(label="Option 1")
            dpg.add_menu_item(label="Option 2")
            dpg.add_menu_item(label="Option 3")
        with dpg.menu(label="Menu Item 3"):
            dpg.add_menu_item(label="Option 1")
            dpg.add_menu_item(label="Option 2")
            dpg.add_menu_item(label="Option 3")
        with dpg.menu(label="Menu Item 4"):
            dpg.add_menu_item(label="Option 1")
            dpg.add_menu_item(label="Option 2")
            dpg.add_menu_item(label="Option 3")
       
       
       
        # with dpg.tab_bar() as tb:

        #     with dpg.tab(label="tab 1"):
        #         dpg.add_text("This is the tab 1!")

        #     with dpg.tab(label="tab 2"):
        #         dpg.add_text("This is the tab 2!")

        #     with dpg.tab(label="tab 3"):
        #         dpg.add_text("This is the tab 3!")

        #     with dpg.tab(label="tab 4"):
        #         dpg.add_text("This is the tab 4!")

dpg.create_viewport(title='OSUGC GUI', width=c.WINDOW_WIDTH+16, height=c.WINDOW_HEIGHT+36, x_pos=c.VIEWPORT_XPOS, y_pos=c.VIEWPORT_YPOS, small_icon=c.ICON_FILE, large_icon=c.ICON_FILE)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()