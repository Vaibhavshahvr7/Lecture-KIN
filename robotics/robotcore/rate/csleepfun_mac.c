/* Copyright 2015-2018 The MathWorks, Inc. */
#include "csleepfun.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

static mach_timebase_info_data_t sTimebaseInfo;

/**
 * Convert the counts returned by mach_absolute_time into real time.
 */
static uint64_t nanosToAbs(uint64_t nanos) {
    return nanos * sTimebaseInfo.denom / sTimebaseInfo.numer;
}

void csleepfun(double seconds)
{   
    /* This code was inspired by Technical Note TN2169 about high precision
       timers in Mac OSX: 
       https://developer.apple.com/library/ios/technotes/tn2169/_index.html */
    
    mach_timebase_info(&sTimebaseInfo);
    uint64_t timeToWait = nanosToAbs((uint64_t)(seconds * 1e9));
    uint64_t now = mach_absolute_time();
    mach_wait_until(now + timeToWait);

    return;
}

