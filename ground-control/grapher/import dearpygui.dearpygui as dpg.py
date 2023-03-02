import dearpygui.dearpygui as dpg

def load_image(sender, data):
    dpg.set_value("Image", data["image_path"])

with dpg.window(width=500, height=500):
    dpg.add_text("Image Viewer")
    dpg.add_image("MapOfTripoli.jpg", tag="Image")
    image_data = {"image_path": "MapOfTripoli.png"}
    dpg.add_button("Load Image", callback=load_image, callback_data=image_data)

dpg.setup_dearpygui()
dpg.start_dearpygui()
