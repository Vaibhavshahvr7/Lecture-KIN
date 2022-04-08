classdef SystemTimeProvider < robotics.core.internal.TimeProvider & coder.ExternalDependency
%SystemTimeProvider A time object synchronized with system time.
%   Note that during MATLAB execution, the object utilizes PAUSE, TIC,
%   and TOC. All three functions use a monotonic clock to measure elapsed
%   time, so discontinuous changes of the system time
%   (for example during Daylight Savings Time, manual system clock
%   adjustments, or automatic NTP adjustments) have no effects.
%
%   The same monotonic behavior holds true for the corresponding
%   functions in code generation.
%
%   SystemTimeProvider properties:
%       IsInitialized - Indication if the time provider has been initialized
%
%   SystemTimeProvider methods:
%       reset           - Reset the time provider
%       sleep           - Sleep for a number of seconds
%       getElapsedTime  - Returns the elapsed time since the time provider was reset (seconds)
%
%   See also robotics.ros.internal.NodeTimeProvider.

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen

    properties (Dependent, SetAccess = protected)
        %IsInitialized - Indication if the time provider has been initialized
        %   Use the RESET method to initialize the time provider.
        IsInitialized
    end

    properties (Access = {?robotics.core.internal.SystemTimeProvider, ?matlab.unittest.TestCase})
        %StartTime - The time when the clock starts.
        %   A value of -1 implies that the time provider has not been
        %   initialized. Call RESET to initialize the provider.
        %
        %   Default: -1
        StartTime
    end

    methods
        function obj = SystemTimeProvider
        %SystemTimeProvider Constructor for SystemTimeProvider object
        %   Please see the class documentation for more details.
        %   See also robotics.core.internal.SystemTimeProvider.
            obj.StartTime = -1;
        end

        function elapsedTime = getElapsedTime(obj)
        %getElapsedTime Returns the elapsed time since the time provider was reset (seconds)
        %   You need to call RESET to initialize the time provider before
        %   you can call this method.
        %   The returned time is monotonically increasing and is not affected
        %   by discontinuous jumps in the system time, for example on manual time
        %   changes or during Daylight Savings Time.

            coder.internal.errorIf(~obj.isStartTimeValid,'shared_robotics:robotcore:rate:TimeProviderNotInitialized');

            if coder.target('MATLAB')
                elapsedTime = toc(obj.StartTime);
            else
                coder.cinclude('ctimefun.h');
                systemTime = -1;
                systemTime = coder.ceval('ctimefun');
                elapsedTime = systemTime - obj.StartTime;
            end
        end

        function initialized = get.IsInitialized(obj)
        %get.IsInitialized getter for IsInitialized property.
        %   Indicates whether the timer is initialized or not.
            initialized = obj.isStartTimeValid;
        end

        function success = reset(obj)
        %RESET Reset the time provider
        %   This resets the initial state of the time provider. You have to
        %   call RESET before you can call any other methods on the object.
        %   This function returns whether the time provider has been
        %   successfully reset.

            if coder.target('MATLAB')
                obj.StartTime = tic;
            else
                coder.cinclude('ctimefun.h');
                obj.StartTime = coder.ceval('ctimefun');
            end

            success = obj.isStartTimeValid;
        end

        function sleep(obj, seconds)
        %SLEEP Sleep for a number of seconds
        %   This sleep uses the computer's system time. The SECONDS input
        %   specified the sleep time in seconds. A negative number for
        %   SECONDS has no effect and the function will return right
        %   away.
        %   You need to call RESET to initialize the time provider before
        %   you can call this method.

            coder.internal.errorIf(~obj.isStartTimeValid,'shared_robotics:robotcore:rate:TimeProviderNotInitialized');

            if coder.target('MATLAB') || coder.target('Sfun')
                % Use standard pause function in MATLAB or when using in a
                % Simulink S-function context. It is reasonably accurate.
                pause(seconds);
            else
                % Use platform-specific C-code for code generation
                coder.cinclude('csleepfun.h');
                if seconds > 0
                    coder.ceval('csleepfun', seconds);
                end
            end
        end
    end

    methods (Access = private)
        function valid = isStartTimeValid(obj)
        %isStartTimeValid Check if StartTime property contains a valid value
            valid = obj.StartTime ~= -1;
        end
    end

    %% The following functions implement the coder.ExternalDependency interface
    % These functions are used during code generation.
    methods (Static)
        function name = getDescriptiveName(~)
        %getDescriptiveName Returns a descriptive name for the build configuration

            name = 'SystemTimeProvider';
        end

        function canBuild = isSupportedContext(ctx)
        %isSupportedContext Verifies that build configuration is supported

            coder.internal.errorIf(~ctx.isMatlabHostTarget, ...
                                   'shared_robotics:robotcore:rate:InvalidCodegenTarget');

            % This is host-only code generation, so allow build.
            canBuild = true;
        end

        function updateBuildInfo(buildInfo, ~)
        %updateBuildInfo Update the include and source folder path build configuration
        %   Include csleepfun to support sleep functionality in generated C/C++ code.
            buildInfo.addIncludePaths(fullfile(matlabroot, 'toolbox', 'shared', 'robotics','robotcore', 'rate', 'include'));
            buildInfo.addSourcePaths(fullfile(matlabroot, 'toolbox', 'shared', 'robotics','robotcore', 'rate'));

            buildInfo.addSourceFiles('roundtolong.c');
            if ismac
                % Code to run on Mac platform
                buildInfo.addSourceFiles('csleepfun_mac.c');
                buildInfo.addSourceFiles('ctimefun_mac.c');
            elseif isunix
                % Code to run on Linux platform
                buildInfo.addSourceFiles('csleepfun_linux.c');
                buildInfo.addSourceFiles('ctimefun_linux.c');

                % Link rt library, so that clock_gettime is found if glibc version
                % < 2.17 is used.
                buildInfo.addLinkFlags('-lrt');
            elseif ispc
                % Code to run on Windows platform
                buildInfo.addSourceFiles('csleepfun_windows.c');
                buildInfo.addSourceFiles('ctimefun_windows.c');
            end
        end

    end

end
