import utils.math_util as math_util
import pytest

@pytest.mark.parametrize(
    "test_list",
    [
        ([]),
        ([0.0]),
        ([0.5]),
        ([1.23456789, 98765432.1]),
        ([123.456, 789.012, 345,678, 901.234]),
    ]
)
def test_is_list_close(test_list: list[float]) -> None:
    assert math_util.is_list_close(test_list, test_list)

@pytest.mark.parametrize(
    "list1, list2",
    [
        ([], [0.0]),
        ([0.0], [0.1]),
        ([0.5], [-0.5]),
        ([1.23456789, 98765432.1], [1.23457, 98765432.2]),
        ([123.456, 789.012, 345,678, 901.234], [123.456, 789.012, 0.0, 901.234]),
    ]
)
def test_is_list_close_false(list1: list[float], list2: list[float]) -> None:
    assert not math_util.is_list_close(list1, list2)