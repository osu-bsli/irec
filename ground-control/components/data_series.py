class DataSeries():
    def __init__(self, x_axis_name: str, y_axis_name: str) -> None:
        self.x_axis_name = x_axis_name
        self.y_axis_name = y_axis_name
        self.x_data = []
        self.y_data = []
    
    def add_point(self, x_value, y_value) -> None:
        self.x_data.append(x_value)
        self.y_data.append(y_value)
    
    def add_point(self, xy_tuple: tuple[float, any]) -> None:
        self.x_data.append(xy_tuple[0])
        self.y_data.append(xy_tuple[1])
    
    def latest(self) -> any:
        if self.x_data == []:
            return None
        return self.x_data[-1]
