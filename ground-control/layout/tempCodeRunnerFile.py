with dpg.child_window(width=500, height=320):
            with dpg.menu_bar():
                dpg.add_menu(label="Menu Options")
            with dpg.child_window(autosize_x=True, height=95):
                with dpg.group(horizontal=True):
                    dpg.add_button(label="Header 1", width=75, height=75)
                    dpg.add_button(label="Header 2", width=75, height=75)
                    dpg.add_button(label="Header 3", width=75, height=75)
            with dpg.child_window(autosize_x=True, height=175):
                with dpg.group(horizontal=True, width=0):
                    with dpg.child_window(width=102, height=150):
                        with dpg.tree_node(label="Nav 1"):
                            dpg.add_button(label="Button 1")
                        with dpg.tree_node(label="Nav 2"):
                            dpg.add_button(label="Button 2")
                        with dpg.tree_node(label="Nav 3"):
                            dpg.add_button(label="Button 3")
                    with dpg.child_window(width=300, height=150):
                        dpg.add_button(label="Button 1")
                        dpg.add_button(label="Button 2")
                        dpg.add_button(label="Button 3")
                    with dpg.child_window(width=50, height=150):
                        dpg.add_button(label="B1", width=25, height=25)
                        dpg.add_button(label="B2", width=25, height=25)
                        dpg.add_button(label="B3", width=25, height=25)
            with dpg.group(horizontal=True):
                dpg.add_button(label="Footer 1", width=175)
                dpg.add_text("Footer 2")
                dpg.add_button(label="Footer 3", width=175)




