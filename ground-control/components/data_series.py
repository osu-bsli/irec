from typing import Optional


class DataSeries[X, Y]:
    def __init__(self, x_axis_name: str, y_axis_name: str) -> None:
        self.x_axis_name = x_axis_name
        self.y_axis_name = y_axis_name
        self.x_data: list[X] = []
        self.y_data: list[Y] = []

    def add_point(self, x, y):
        self.x_data.append(x)
        self.y_data.append(y)
    
    def latest(self) -> Optional[Y]:
        if not self.y_data:
            return None
        return self.y_data[-1]
