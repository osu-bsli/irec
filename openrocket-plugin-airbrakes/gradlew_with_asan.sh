export LD_PRELOAD=/usr/lib/gcc/x86_64-linux-gnu/15/libasan.so
export ASAN_OPTIONS=handle_segv=0:allow_user_segv_handler=1:detect_leaks=0

./gradlew "$@" 