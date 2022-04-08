function [R, omega, alpha] = rottraj(R0, RF, timeInterval, t, varargin)
%ROTTRAJ Generate trajectory between two orientations
%   This function interpolates between two orientations R0 and RF,
%   specified as quaternion objects, 1x4 quaternion vectors, or 3x3
%   rotation matrices. The function outputs the series of interpolated
%   orientations in time returned as an Mx1 quaternion object, a 4xM vector
%   of quaternions, or a 3x3xM matrix of rotation matrices. The format is
%   determined by the type of the first input. The function also outputs a
%   3xM vector of angular velocities, OMEGA, and a 3xM vector of angular
%   accelerations, ALPHA.
%
%   [R, omega, alpha] = rottraj( R0, RF, timeInterval, t)
%
%      R0 -             The initial orientation, specified as a quaternion
%                       object, a 1x4 quaternion vector, or a 3x3 rotation
%                       matrix.
%
%      RF -             The final orientation, specified as a quaternion
%                       object, a 1x4 quaternion vector, or a 3x3 rotation
%                       matrix.
%
%      TIMEINTERVAL -   A two element vector indicating the start and end
%                       time of the trajectory. The initial and final
%                       position are held constant outside this interval.
%
%      T -              An M-element time vector or instant in time at
%                       which the trajectory is evaluated
%
%   [R, omega, alpha] = rottraj(___, Name, Value) provides additional
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
%      % Define two quaternion waypoints
%      q0 = quaternion([0 pi/4 -pi/8],'euler','ZYX','point');
%      qF = quaternion([3*pi/2 0 -3*pi/4],'euler','ZYX','point');
%
%      % Interpolate between the points
%      [qInterp1, w1, a1] = rottraj(q0, qF, tpts, tvec);
%
%      % Interpolate between the points using a cubic time scaling
%      [s, sd, sdd] = cubicpolytraj([0 1], tpts, tvec);
%      [qInterp2, w2, a2] = rottraj(q0, qF, tpts, tvec, 'TimeScaling', [s; sd; sdd]);
%
%      % Compare outputs
%      figure
%      plot(tvec, compact(qInterp1))
%      title('Quaternion Interpolation Time Scaling Comparison: Linear (Solid) vs. Cubic (Dashed)')
%      hold all
%      plot(tvec, compact(qInterp2), '--')
%      hold off
%
%   SEE ALSO: TRANSFORMTRAJ

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
    q0 = validateRotationInput(R0, 'R0');
    qF = validateRotationInput(RF, 'RF');
    inputType = determineInputType(R0);
    validateattributes(timeInterval, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'rottraj','timeInterval');
    validateattributes(t, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'rottraj','t');

    % Setup dimensions
    m = length(t);

    % Parse inputs
    names = {'TimeScaling'};
    defaults = {robotics.core.internal.constructLinearTimeScaling(timeInterval, t)};
    parser = robotics.core.internal.NameValueParser(names, defaults);
    parse(parser, charInputs{:});
    timeScaling = parameterValue(parser, names{1});

    % Input checks
    validateattributes(timeScaling, {'numeric'}, {'nonempty','nrows',3,'real','finite'}, 'rottraj','TimeScaling');
    validateattributes(timeScaling(1,:), {'numeric'}, {'>=', 0, '<=', 1}, 'rottraj','TimeScaling(1,:)');
    coder.internal.errorIf(size(timeScaling,2) ~= m, 'shared_robotics:robotcore:utils:RotTrajTimeScalingLength');

    % Process time scaling
    s = timeScaling(1,:);
    sd = timeScaling(2,:);
    sdd = timeScaling(3,:);

    % Initialize outputs
    omega = zeros(3,m);
    alpha = zeros(3,m);
    qCalc = ones(m,1,'like',quaternion);

    % Prep inputs
    pn = q0.normalize;
    qn = qF.normalize;

    % Get corrected start and end values from quaternion slerp method
    pnCorrected = slerp(pn,qn,0);
    qnCorrected = slerp(pn,qn,1);
    for i = 1:m
        qCalc(i) = slerp(pn,qn,s(i));

        % Compute angular velocity and acceleration from the quaternion
        % derivatives: omega = 2(dq/dt)(q*), alpha = 2(d^2q/dt^2)(q*)
        qdCalc = computeFirstQuatDerivative(pnCorrected, qnCorrected, sd(i), qCalc(i));
        W = compact(2*qdCalc*conj(qCalc(i)));
        omega(:,i) = W(2:4);

        qddCalc = computeSecondQuatDerivative(pnCorrected, qnCorrected, sdd(i), qCalc(i));
        A = compact(2*qddCalc*conj(qCalc(i)));
        alpha(:,i) = A(2:4);
    end

    switch inputType
      case 'quat'
        % Quaternion object
        R = qCalc;
      case 'quatv'
        % Quaternion vector (numeric)
        R = compact(qCalc)';
      case 'rotm'
        % Rotation matrix (numeric)
        R = rotmat(qCalc,'point');
    end

end

%% Helper functions

function inputType = determineInputType(rotInput)
%determineInputType Determine input type for code generation
%   In order for coder to work with varying input-dependent output types,
%   the input type must be set via a method that is constant at
%   compile-time.

    switch size(rotInput,2)
      case 1
        % Quaternion object
        inputType = 'quat';
      case 3
        % Rotation matrix
        inputType = 'rotm';
      case 4
        % Quaternion vector
        inputType = 'quatv';
    end

end

function q = validateRotationInput(rotInput, inputName)
%validateRotationInput Verify that rotation input is valid and convert to quaternion

    if isa(rotInput, 'quaternion')
        %Quaternion
        q = rotInput;
    elseif all(size(rotInput) == [1 4])
        %Vector representing a quaternion
        rotInput = robotics.internal.validation.validateQuaternion(rotInput, 'rottraj', inputName);
        q = quaternion(rotInput);
    elseif all(size(rotInput) == [3 3])
        %Verify that this is a valid rotation matrix and convert to quaternion
        robotics.internal.validation.validateRotationMatrix(rotInput, 'rottraj', inputName);
        q = quaternion(rotInput, 'rotmat', 'point');
    else
        coder.internal.errorIf(true, 'shared_robotics:robotcore:utils:RotTrajInvalidInput', inputName);
    end

end

function qdot = computeFirstQuatDerivative(pn, qn, sd, qinterp)
%computeFirstQuatDerivative Compute the instantaneous first derivative
%   This helper uses the analytical representation of the interpolation
%   method to compute the first derivative of the interpolation method at
%   an instant specified by the time derivative of the time scaling.

    qdot = (qinterp*log((conj(pn)*qn)))*sd;

end

function qddot = computeSecondQuatDerivative(pn, qn, sdd, qinterp)
%computeSecondQuatDerivative Compute the instantaneous second derivative
%   This helper uses the analytical representation of the interpolation
%   method to compute the second derivative of the interpolation method at
%   an instant specified by the second time derivative of the time scaling.

% Multiply twice since there is no power operator for quaternions
    qddot = (qinterp*log((conj(pn)*qn))*log((conj(pn)*qn)))*sdd;

end
