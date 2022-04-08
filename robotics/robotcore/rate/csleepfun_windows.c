/* Copyright 2015-2018 The MathWorks, Inc. */
#include "roundtolong.h"
#include "csleepfun.h"

#include <windows.h>

void csleepfun(double seconds)
{
    /* Could call timeBeginPeriod and timeEndPeriod to increase the possible Sleep
       resolution to 1 ms (instead of the standard 10 - 15 ms).
       In tests, the current resolution was adequate. */
    
    /* timeBeginPeriod(1); */
    Sleep(roundToLong(seconds*1000));
    /* timeEndPeriod(1); */
    
    return;
}

