# layout constants

import tkinter as tk    # screen dimensions

SCREEN_HEIGHT=tk.Tk().winfo_screenheight()
SCREEN_WIDTH=tk.Tk().winfo_screenwidth()

# dpg viewport is smaller than screen resolution
VIEWPORT_HEIGHT=(int)(SCREEN_HEIGHT/1.25)
VIEWPORT_WIDTH=(int)(SCREEN_WIDTH/1.25)

# window offset from top left corner
VIEWPORT_XPOS=10
VIEWPORT_YPOS=10

# plot dimensions
PLOT_WIDTH=VIEWPORT_WIDTH/2
PLOT_HEIGHT=VIEWPORT_HEIGHT/2

# (r, g, b, alpha)
BUTTON_ACTIVE_COLOR=(0, 150, 100, 255)  # green
BUTTON_INACTIVE_COLOR=(150, 30, 30)     # red

# persistent sidebar

SIDEBAR_BUTTON_HEIGHT=VIEWPORT_HEIGHT/8     # 1/6 of total height
SIDEBAR_BUTTON_WIDTH=VIEWPORT_WIDTH/10       # 1/10 of total width



ICON_FILE='resources/BSLI_logo.ico'