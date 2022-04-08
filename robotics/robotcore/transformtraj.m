function [tform, vel, acc] = transformtraj(T0, TF, timeInterval, t, varargin)
%TRANSFORMTRAJ Generate trajectory between two homogeneous transforms
%   This function generates trajectories between two 4x4 homogeneous
%   transformation matrices T0 and TF, given a 1xM time vector T from zero
%   to one. The function outputs a 4x4xM matrix of transformations TFORM,
%   as well as a 6xM matrix VEL of the angular velocities and velocities in
%   time, and a 6xM matrix ACC of the angular accelerations and
%   accelerations in time.
%
%   [T, V, A] = transformtraj(T0, TF, timeInterval, t)
%
%      T0 -             A 4x4 homogeneous transformation matrix specifying
%                       the initial position and orientation
%
%      TF -             A 4x4 homogeneous transformation matrix specifying
%                       the final position and orientation
%
%      TIMEINTERVAL -   A two element vector indicating the start and end
%                       time of the trajectory. The initial and final
%                       position are held constant outside this interval.
%
%      T -              An M-element vector or instant in time at which the
%                       trajectory is evaluated
%
%   [TFORM, VEL, ACC] = transformtraj(___, Name, Value) provides additional
%   options specified by the Name-Value pair arguments.
%
%      TIMESCALING -   The time scaling vector s(t) and its first two
%                      derivatives, ds/dt and d^2s/dt^2 defined as a 3xM
%                      vector [s; ds/dt; d^2s/dt^2]. In the default case, a
%                      linear time scaling is used:
%                      s(t) = C*t, sd(t) = C, sdd(t) = 0
%                      where C = 1/(timeInterval(2) - timeInterval(1)).
%
%   Example:
%      % Define time vector
%      tvec = 0:0.01:5;
%
%      % Define time over which rotation will occur
%      tpts = [1 4];
%
%      % Build transforms from two orientations and positions
%      T0 = axang2tform([0 1 1 pi/4]);
%      TF = axang2tform([1 0 1 6*pi/5]);
%      TF(1:3,4) = [1 -5 23]';
%
%      % Interpolate between the points
%      [tfInterp1, v1, a1] = transformtraj(T0, TF, tpts, tvec);
%
%      % Interpolate between the points using a cubic time scaling
%      [s, sd, sdd] = cubicpolytraj([0 1], tpts, tvec);
%      [tfInterp2, v2, a2] = transformtraj(T0, TF, tpts, tvec, 'TimeScaling', [s; sd; sdd]);
%
%      % Compare the position interpolation
%      figure
%      plot(tvec, reshape(tfInterp1(1:3,4,:),3,size(tfInterp1,3)))
%      title('Position Interpolation Time Scaling Comparison: Linear (Solid) vs. Cubic (Dashed)')
%      hold all
%      plot(tvec, reshape(tfInterp2(1:3,4,:),3,size(tfInterp1,3)), '--')
%      hold off
%
%   SEE ALSO: ROTTRAJ

%   Copyright 2018 The MathWorks, Inc.

%#codegen

% Ensure the correct number of inputs
    narginchk(4,6);

    % Convert strings to chars case by case for codegen support
    if nargin > 4
        charInputs = cell(1,2);
        [charInputs{:}] = convertStringsToChars(varargin{:});
    else
        charInputs = {};
    end

    % Default input checks
    robotics.internal.validation.validateHomogeneousTransform(T0, 'transformtraj', 'T0');
    robotics.internal.validation.validateHomogeneousTransform(TF, 'transformtraj', 'TF');
    validateattributes(timeInterval, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'transformtraj','timeInterval');
    validateattributes(t, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'transformtraj','t');

    % Setup dimensions
    m = length(t);

    % Parse inputs
    names = {'TimeScaling'};
    defaults = {robotics.core.internal.constructLinearTimeScaling(timeInterval, t)};
    parser = robotics.core.internal.NameValueParser(names, defaults);
    parse(parser, charInputs{:});
    timeScaling = parameterValue(parser, names{1});

    % Input checks
    validateattributes(timeScaling, {'numeric'}, {'nonempty','nrows', 3, 'real','finite'}, 'transformtraj','TimeScaling');
    validateattributes(timeScaling(1,:), {'numeric'}, {'>=', 0, '<=', 1}, 'transformtraj','TimeScaling(1,:)');
    coder.internal.errorIf(size(timeScaling,2) ~= m, 'shared_robotics:robotcore:utils:RotTrajTimeScalingLength');

    % Compute rotation transform
    r1 = T0(1:3,1:3);
    r2 = TF(1:3,1:3);

    % Process time scaling
    s = timeScaling(1,:);
    sd = timeScaling(2,:);
    sdd = timeScaling(3,:);

    % Compute rotation trajectory
    [r,w,a] = rottraj(r1,r2,timeInterval,t,'TimeScaling', timeScaling);

    % Initialize outputs
    tform = zeros(4,4,m);
    tform(4,4,:) = 1;
    vel = zeros(6,m);
    acc = zeros(6,m);

    % Compute translation transform
    p0 = T0(1:3,4);
    pF = TF(1:3,4);
    p = repmat(p0, 1, m) + (pF - p0)*s;
    pd = (pF - p0)*sd;
    pdd = (pF - p0)*sdd;

    % Concatenate outputs
    tform(1:3,1:3,:) = r;
    tform(1:3,4,:) = p;
    vel(1:3,:) = w;
    vel(4:6,:) = pd;
    acc(1:3,:) = a;
    acc(4:6,:) = pdd;

end
