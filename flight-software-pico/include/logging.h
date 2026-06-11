#pragma once

#include "error.h"

namespace fs
{
    class File;
}

FSError sdcard_init(fs::File *fileOut);
void sdcard_deinit();