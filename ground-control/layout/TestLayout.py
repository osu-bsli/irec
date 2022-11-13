import dearpygui.dearpygui as dpg
import constants as C

dpg.create_context()

with dpg.window(label="OSUGC", width=C.WINDOW_WIDTH, height=C.WINDOW_HEIGHT):
    with dpg.menu_bar():
        with dpg.menu(label="Menu Item 1"): 
            # with dpg.child_window(width=C.WINDOW_WIDTH-20, height=C.WINDOW_HEIGHT-200, x_pos=0, y_pos=200):
            with dpg.child_window(autosize_x=True):
                with dpg.group(horizontal=False):
                    dpg.add_button(label="Header 1", width=90, height=30)
                    dpg.add_button(label="Header 2", width=75, height=30)
                    dpg.add_button(label="Header 3", width=75, height=30)




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

dpg.create_viewport(title='OSUGC GUI', width=C.WINDOW_WIDTH+16, height=C.WINDOW_HEIGHT+36, x_pos=C.VIEWPORT_XPOS, y_pos=C.VIEWPORT_YPOS, small_icon=C.ICON_FILE, large_icon=C.ICON_FILE)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()