# ground-control

Rocket ground control software for the [Buckeye Space Launch Initiative](https://bsli.space/) at the Ohio State University.

The minimum required Python version is 3.12.

## Contributing

Please do not push directly to this repo. Fork it, push your changes there, and make a pull request (PR).

Ideally PRs should be reviewed by at least one other person before merging.

Please work on a feature branch (create one if one doesn't exist) and only push to that branch. **Please do not directly push to `main` or `dev`!** Once features are stable we can merge them into `dev`. Once `dev` is stable we can merge it into `main` as a release.

## Packet Specification

### Format

Packets consist of a 6-byte header, zero or more variable-length payloads, and a 2-byte footer. The header consists of a 2-byte (`short`) payload type indicator and a 4 byte (`float`) timestamp. The header type indicator signifies which kinds of payloads are present. Each payload type cannot be present more than once. The ordering of payload types is decided beforehand, by convention. Each payload type must have a known length. The footer is a 2-byte (`short`) CRC for error checking purposes.

### Type sizes

We use the sizes specified [here](https://docs.python.org/3/library/struct.html#format-characters).

### Approximate packet sizes

| Type              | Priority | Payload Format | Payload Size (bytes) | Update Frequency                |
|-------------------|----------|----------------|----------------------|---------------------------------|
| ARM_STATUS        | 1        | `bool[3]`      | 3                    | lazy, immediate on change       |
| ALTITUDE          | 1        | `float[2]`     | 8                    | immediate                       |
| ACCELERATION      | 2        | `float[3]`     | 12                   | immediate                       |
| GPS_COORDINATES   | 2        | `float[2]`     | 8                    | lazy, immediate on major change |
| BOARD_TEMPERATURE | 3        | `float[4]`     | 16                   | lazy, immediate on major change |
| BOARD_VOLTAGE     | 3        | `float[4]`     | 16                   | lazy, immediate on major change |
| BOARD_CURRENT     | 3        | `float[4]`     | 16                   | lazy, immediate on major change |
| BATTERY_VOLTAGE   | 3        | `float[3]`     | 12                   | lazy, immediate on major change |
| MAGNETOMETER      | 3        | `float[3]`     | 12                   | lazy, immediate on major change |
| GYROSCOPE         | 3        | `float[3]`     | 12                   | lazy, immediate on major change |
| GPS_SATELLITES    | 3        | `short`        | 2                    | lazy, immediate on major change |
| GPS_GROUND_SPEED  | 3        | `float`        | 4                    | lazy, immediate on major change |
