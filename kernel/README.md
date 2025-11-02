This is a CMake project that builds a custom Raspberry Pi kernel, customized for BSLI.

The config options are set by `src/bsli-kernel.config`.

It produces a Debian package (`.deb`) that can be directly installed on a Raspberry Pi.

# Building:

To produce `raspberrypi-linux-bsli.deb` in `build/`:

```
cmake -Bbuild
cmake --build build -- package
```

