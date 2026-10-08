Requirements:
* cmake
* Visual Studio 2026 with Microsoft Visual C++

Build native airbrakes library:
```shell
cmake --preset=default
cmake --build cmake-build --config Release
```

To run OpenRocket with the airbrakes plugin:
```shell
./gradlew run
```