class SerialClass {
public:
    void begin(int baud) {}

    int printf(const char *fmt, ...)
    {
        va_list args;
        va_start(args, fmt);
        int ret = vprintf(fmt, args);
        va_end(args);
        return ret;
    }

    int println(int val)
    {
        return printf("%d\n", val);
    }

    int println(const char* str)
    {
        int ret = printf(str);
        ret += printf("\n");
        return ret;
    }

    int read()
    {
        return 0;
    }
};

static SerialClass Serial;