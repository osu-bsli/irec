import dearpygui.dearpygui as gui
import tomli
from data_controllers.iliad_data_controller import IliadDataController
from grapher.grapher import *
from grapher.grapher import Grapher
from iliad.arm_control import ArmControl
from grapher import grapher
from typing import List, Any, Callable, Union, Tuple

class App:

    # Widget tags
    TAG_MAIN_WINDOW = 'app.main_window'
    TAG_MAIN_MENU = 'app.main_menu'
    TAG_MAIN_TAB_BAR = 'app.main_tab_bar'
    TAG_CONFIG_WINDOW = 'app.config_window'



    def __init__(self) -> None:

        def create_theme_imgui_light() -> Union[str, int]:

            with gui.theme() as theme_id:
                with gui.theme_component(0):
                    gui.add_theme_color(gui.mvThemeCol_Text                   , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TextDisabled           , (0.60 * 255, 0.60 * 255, 0.60 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_WindowBg               , (0.94 * 255, 0.94 * 255, 0.94 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ChildBg                , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_PopupBg                , (1.00 * 255, 1.00 * 255, 1.00 * 255, 0.98 * 255))
                    gui.add_theme_color(gui.mvThemeCol_Border                 , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.30 * 255))
                    gui.add_theme_color(gui.mvThemeCol_BorderShadow           , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_FrameBg                , (1.00 * 255, 1.00 * 255, 1.00 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_FrameBgHovered         , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.40 * 255))
                    gui.add_theme_color(gui.mvThemeCol_FrameBgActive          , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.67 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TitleBg                , (0.96 * 255, 0.96 * 255, 0.96 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TitleBgActive          , (0.82 * 255, 0.82 * 255, 0.82 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TitleBgCollapsed       , (1.00 * 255, 1.00 * 255, 1.00 * 255, 0.51 * 255))
                    gui.add_theme_color(gui.mvThemeCol_MenuBarBg              , (0.86 * 255, 0.86 * 255, 0.86 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ScrollbarBg            , (0.98 * 255, 0.98 * 255, 0.98 * 255, 0.53 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ScrollbarGrab          , (0.69 * 255, 0.69 * 255, 0.69 * 255, 0.80 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ScrollbarGrabHovered   , (0.49 * 255, 0.49 * 255, 0.49 * 255, 0.80 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ScrollbarGrabActive    , (0.49 * 255, 0.49 * 255, 0.49 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_CheckMark              , (0.26 * 255, 0.59 * 255, 0.98 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_SliderGrab             , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.78 * 255))
                    gui.add_theme_color(gui.mvThemeCol_SliderGrabActive       , (0.46 * 255, 0.54 * 255, 0.80 * 255, 0.60 * 255))
                    gui.add_theme_color(gui.mvThemeCol_Button                 , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.40 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ButtonHovered          , (0.26 * 255, 0.59 * 255, 0.98 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ButtonActive           , (0.06 * 255, 0.53 * 255, 0.98 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_Header                 , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.31 * 255))
                    gui.add_theme_color(gui.mvThemeCol_HeaderHovered          , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.80 * 255))
                    gui.add_theme_color(gui.mvThemeCol_HeaderActive           , (0.26 * 255, 0.59 * 255, 0.98 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_Separator              , (0.39 * 255, 0.39 * 255, 0.39 * 255, 0.62 * 255))
                    gui.add_theme_color(gui.mvThemeCol_SeparatorHovered       , (0.14 * 255, 0.44 * 255, 0.80 * 255, 0.78 * 255))
                    gui.add_theme_color(gui.mvThemeCol_SeparatorActive        , (0.14 * 255, 0.44 * 255, 0.80 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ResizeGrip             , (0.35 * 255, 0.35 * 255, 0.35 * 255, 0.17 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ResizeGripHovered      , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.67 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ResizeGripActive       , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.95 * 255))
                    gui.add_theme_color(gui.mvThemeCol_Tab                    , (0.76 * 255, 0.80 * 255, 0.84 * 255, 0.93 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TabHovered             , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.80 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TabActive              , (0.60 * 255, 0.73 * 255, 0.88 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TabUnfocused           , (0.92 * 255, 0.93 * 255, 0.94 * 255, 0.99 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TabUnfocusedActive     , (0.74 * 255, 0.82 * 255, 0.91 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_DockingPreview         , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.22 * 255))
                    gui.add_theme_color(gui.mvThemeCol_DockingEmptyBg         , (0.20 * 255, 0.20 * 255, 0.20 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_PlotLines              , (0.39 * 255, 0.39 * 255, 0.39 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_PlotLinesHovered       , (1.00 * 255, 0.43 * 255, 0.35 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_PlotHistogram          , (0.90 * 255, 0.70 * 255, 0.00 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_PlotHistogramHovered   , (1.00 * 255, 0.45 * 255, 0.00 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TableHeaderBg          , (0.78 * 255, 0.87 * 255, 0.98 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TableBorderStrong      , (0.57 * 255, 0.57 * 255, 0.64 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TableBorderLight       , (0.68 * 255, 0.68 * 255, 0.74 * 255, 1.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TableRowBg             , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.00 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TableRowBgAlt          , (0.30 * 255, 0.30 * 255, 0.30 * 255, 0.09 * 255))
                    gui.add_theme_color(gui.mvThemeCol_TextSelectedBg         , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.35 * 255))
                    gui.add_theme_color(gui.mvThemeCol_DragDropTarget         , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.95 * 255))
                    gui.add_theme_color(gui.mvThemeCol_NavHighlight           , (0.26 * 255, 0.59 * 255, 0.98 * 255, 0.80 * 255))
                    gui.add_theme_color(gui.mvThemeCol_NavWindowingHighlight  , (0.70 * 255, 0.70 * 255, 0.70 * 255, 0.70 * 255))
                    gui.add_theme_color(gui.mvThemeCol_NavWindowingDimBg      , (0.20 * 255, 0.20 * 255, 0.20 * 255, 0.20 * 255))
                    gui.add_theme_color(gui.mvThemeCol_ModalWindowDimBg       , (0.20 * 255, 0.20 * 255, 0.20 * 255, 0.35 * 255))
                    gui.add_theme_color(gui.mvPlotCol_FrameBg       , (1.00 * 255, 1.00 * 255, 1.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_PlotBg        , (0.42 * 255, 0.57 * 255, 1.00 * 255, 0.13 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_PlotBorder    , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_LegendBg      , (1.00 * 255, 1.00 * 255, 1.00 * 255, 0.98 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_LegendBorder  , (0.82 * 255, 0.82 * 255, 0.82 * 255, 0.80 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_LegendText    , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_TitleText     , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_InlayText     , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_XAxis         , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_XAxisGrid     , (1.00 * 255, 1.00 * 255, 1.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxis         , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxisGrid     , (1.00 * 255, 1.00 * 255, 1.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxis2        , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxisGrid2    , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.50 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxis3        , (0.00 * 255, 0.00 * 255, 0.00 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_YAxisGrid3    , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.50 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_Selection     , (0.82 * 255, 0.64 * 255, 0.03 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_Query         , (0.00 * 255, 0.84 * 255, 0.37 * 255, 1.00 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvPlotCol_Crosshairs    , (0.00 * 255, 0.00 * 255, 0.00 * 255, 0.50 * 255), category=gui.mvThemeCat_Plots)
                    gui.add_theme_color(gui.mvNodeCol_NodeBackground, (240, 240, 240, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_NodeBackgroundHovered, (240, 240, 240, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_NodeBackgroundSelected, (240, 240, 240, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_NodeOutline, (100, 100, 100, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_TitleBar, (248, 248, 248, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_TitleBarHovered, (209, 209, 209, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_TitleBarSelected, (209, 209, 209, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_Link, (66, 150, 250, 100), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_LinkHovered, (66, 150, 250, 242), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_LinkSelected, (66, 150, 250, 242), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_Pin, (66, 150, 250, 160), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_PinHovered, (66, 150, 250, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_BoxSelector, (90, 170, 250, 30), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_BoxSelectorOutline, (90, 170, 250, 150), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_GridBackground, (225, 225, 225, 255), category=gui.mvThemeCat_Nodes)
                    gui.add_theme_color(gui.mvNodeCol_GridLine, (180, 180, 180, 100), category=gui.mvThemeCat_Nodes)

            return theme_id

        # Start GUI:
        gui.create_context()
        gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
        gui.setup_dearpygui()

        with gui.font_registry():
            primary_font = gui.add_font('assets/fonts/open_sans/OpenSans-VariableFont_wdth,wght.ttf', 16)
            gui.bind_font(primary_font)


        with gui.window(tag=App.TAG_MAIN_WINDOW):
            gui.bind_theme(create_theme_imgui_light())
            with gui.menu_bar(tag=App.TAG_MAIN_MENU):
                with gui.menu(label='Options'):
                    gui.add_menu_item(label='Config', callback=lambda: gui.show_item(App.TAG_CONFIG_WINDOW))
                with gui.menu(label='Tools'):
                    gui.add_menu_item(label='Packet Inspector', callback=None)
                    gui.add_menu_item(label='GUI Demo', callback=gui.show_imgui_demo)
                    gui.add_menu_item(label='Graphs Demo', callback=gui.show_implot_demo)
                    gui.add_menu_item(label='Font Manager', callback=gui.show_font_manager)
                    gui.add_menu_item(label='Style Editor', callback=gui.show_style_editor)
                with gui.menu(label='View'):
                    gui.add_menu_item(label='Save layout', callback=None)
                    gui.add_menu_item(label='Load layout', callback=None)
                with gui.menu(label='Help'):
                    gui.add_menu_item(label='Docs', callback=None)
                    gui.add_menu_item(label='About', callback=None)
            with gui.group(horizontal=True):
                Grapher.displaySidebar()
                gui.add_tab_bar(tag=App.TAG_MAIN_TAB_BAR, pos=(200, 200))

            gui.set_primary_window(App.TAG_MAIN_WINDOW, True)

            self.iliad = IliadDataController('iliad_data_controller')
            self.grapher = Grapher('grapher', self.iliad)
            self.arm_control = ArmControl('armctl', self.iliad)

        # Init config menu:
        with gui.window(label='Config', tag=App.TAG_CONFIG_WINDOW, min_size=(512, 512)):
            # Add categories and corresponding child windows:
            with gui.tree_node(label='General'):
                with gui.tree_node(label='Controls'):
                    gui.add_text('No options available.')
                with gui.tree_node(label='Visuals'):
                    gui.add_text('No options available.')
                with gui.tree_node(label='Misc'):
                    gui.add_text('No options available.')
            with gui.tree_node(label='Grapher'):
                gui.add_text('No options available.')
            with gui.tree_node(label='Iliad Data Controller'):
                self.iliad.add_config_menu()
            
            with gui.group(horizontal=True):

                def on_apply_config():
                    # self.grapher.apply_config()
                    self.iliad.apply_config()

                gui.add_button(label='Cancel', callback=lambda: gui.hide_item(App.TAG_CONFIG_WINDOW))
                gui.add_button(label='Apply', callback=on_apply_config)
        gui.hide_item(App.TAG_CONFIG_WINDOW)

        gui.show_viewport()
        gui.maximize_viewport()

    def update(self) -> None:
        """
        Called every frame.

        Calls `update()` on all components.
        """
        self.iliad.update()
        self.grapher.update()
        self.arm_control.update()

    def run(self) -> None:
        """
        Starts the main event loop.
        """
        while gui.is_dearpygui_running():
            self.update()
            gui.render_dearpygui_frame()

        self.iliad.close()
        
        gui.destroy_context()