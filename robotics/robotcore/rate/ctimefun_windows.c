/* Copyright 2015-2018 The MathWorks, Inc. */
#include "ctimefun.h"

#include <time.h>
#include <windows.h>

double ctimefun()
{
    double t = 0.0;
    __int64 counter, freq;
    
    /* Use the high-performance counter to get a monotonic time reading. */           
    QueryPerformanceCounter((LARGE_INTEGER *)&counter);
    QueryPerformanceFrequency((LARGE_INTEGER *)&freq);
    
    /* The CPU counter is converted to seconds by dividing by the frequency. */
    t = (double) (counter * 1.0 / freq);
    
    return t;
}
