/* Copyright 2015-2018 The MathWorks, Inc. */
#include "ctimefun.h"

#include <mach/mach_time.h>

static double sTimeBase = 0.0;
static uint64_t sTimeStart = 0;

double ctimefun()
{    
    if (sTimeStart == 0) {
        /* Only get the baseline time sTimeStart and time base sTimeBase once */
        mach_timebase_info_data_t tb = { 0 };
        mach_timebase_info(&tb);
        sTimeBase = tb.numer;
        sTimeBase /= tb.denom;
        sTimeStart = mach_absolute_time();
    }
    
    /* Calculate the difference between the current time and the baseline time 
       sTimeStart. Convert to real nanoseconds */
    double diff = (mach_absolute_time() - sTimeStart) * sTimeBase;    
    
    /* Convert from nanoseconds to seconds */
    return diff * 1e-9;
}
