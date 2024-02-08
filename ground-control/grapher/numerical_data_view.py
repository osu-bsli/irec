import dearpygui.dearpygui as gui
from components.data_series import DataSeries


class NumericalDataView:
    def __init__(self, precision_digits: int):
        self.precision_digits = precision_digits
        self.labels = {}
        self.values = {}

    def update_data(self, **data_list: DataSeries):
        for key, data in data_list.items():
            item = self.values[key]
            if len(data.y_data) > 0:
                    gui.set_value(item, f"{data.y_data[-1]:#.{self.precision_digits}f}")

    def add(self):
        with gui.table(header_row=False, no_host_extendX=True, delay_search=True,
                       borders_innerH=False, borders_outerH=True, borders_innerV=True,
                       borders_outerV=True, context_menu_in_body=True, row_background=True) as self.table:
            # create table column to hold plot rows
            gui.add_table_column()

    def add_data_group(self, **names: str):
        with gui.table_row(parent=self.table):
            with gui.table_cell():
                for key, name in names.items():
                    self.labels[key] = gui.add_text(f"{name}:")
                    self.values[key] = gui.add_text(f"{0:#.{self.precision_digits}f}")

