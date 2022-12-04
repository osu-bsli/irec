import dearpygui.dearpygui as dpg

dpg.create_context()

with dpg.window(label="OSUGC", width=800, height=1200):      # One window to rule them all
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

dpg.create_viewport(title='Custom Title', width=800, height=600)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()