import dearpygui.dearpygui as dpg

dpg.create_context()

width, height, channels, data = dpg.load_image('rocket.png') # 0: width, 1: height, 2: channels, 3: data

with dpg.texture_registry():
    dpg.add_static_texture(width, height, data, tag="image_id")

with dpg.window(label="Tutorial"):

    with dpg.drawlist(width=700, height=700):

        dpg.draw_image("image_id", (400, 800), (500, 0), uv_min=(0, 0), uv_max=(1, 1))

dpg.create_viewport(title='Custom Title', width=800, height=600)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()