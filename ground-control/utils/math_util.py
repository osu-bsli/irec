import math

def is_list_close(list1: list[float], list2: list[float]) -> bool:
    """
    Compares two lists of floats.
    Returns true if they are close enough.
    Returns false otherwise.
    """

    if len(list1) != len(list2):
        return False

    for idx in range(len(list1)):
        if not math.isclose(list1[idx], list2[idx], rel_tol=1e-6):
            return False

    return True