
#include "File.h"
#include "error.h"

bool g_sdcard_is_open = false;

FSError sdcard_init(fs::File *fileOut)
{
    g_sdcard_is_open = true;
    return SUCCESS;
}

void sdcard_deinit()
{
    g_sdcard_is_open = false;
}

