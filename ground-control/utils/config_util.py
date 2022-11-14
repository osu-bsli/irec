import tomli
import tomli_w

def get_config(path: str) -> dict[str]:
    """
    Attempts to load a toml config file at the given path.

    - `path` is the path of the file to load.
    
    Returns a parsed dictionary mapping string keys to any value.
    If the file fails to open or parse, returns an empty dictionary.
    """
    config_data: dict[str] = {}
    try:
        with open(path, "rt") as f:
            text = f.read()
            config_data = tomli.loads(text)
    except OSError as e:
        config_data = {}
    except tomli.TOMLDecodeError as e:
        config_data = {}
    return config_data

def set_config(path: str, data: dict[str]) -> None:
    """
    Attemps to save a toml config file at the given path.

    - `path` is the path that the file should be saved to.
    - `data` is a dictionary of data to be converted to toml.
    """
    try:
        with open(path, "wt") as f:
            text = tomli_w.dumps(data)
            f.write(text)
    except OSError as e:
        print(f'[ERROR] Could not write config file {path}')
