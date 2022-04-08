classdef PolyTrajSys < matlab.System & matlab.system.mixin.CustomIcon & matlab.system.mixin.Propagates
% Generate trajectories through multiple via points

% Copyright 2018 The MathWorks, Inc.

%#codegen

    properties (Nontunable)
        %Method
        %   Select the method to specify the noise level as one of 'Signal to
        %   noise ratio (Eb/No)' | 'Signal to noise ratio (Es/No)' | 'Signal to
        %   noise ratio (SNR)' | 'Variance'. The default is 'Signal to noise
        %   ratio (Eb/No)'.
        Method = 'Cubic Polynomial'

        %Waypoint Source
        %   Waypoint Source
        WaypointSource = 'Internal'

        %Parameter Source
        ParameterSource = 'Internal'
    end

    properties (Constant, Hidden)
        % String set for NoiseMethod
        MethodSet = matlab.system.StringSet({...
            'Cubic Polynomial', ...
            'Quintic Polynomial', ...
            'B-Spline'})

        % String set for Source
        WaypointSourceSet = matlab.system.StringSet({...
            'Internal', ...
            'External'})

        % String set for ParameterSource
        ParameterSourceSet = matlab.system.StringSet({...
            'Internal', ...
            'External'})
    end

    % Public, tunable properties
    properties
        %Waypoints
        Waypoints = [ 0 2 1 5 0; -1 3 1 4 4]

        %Time Points
        TimePoints = [0 1 2 3 4];

        %Time Interval
        TimeInterval = [1 4];

        %Velocity Boundary Conditions
        VelocityBoundaryCondition = zeros(2,5);

        %Acceleration Boundary Conditions
        AccelerationBoundaryCondition = zeros(2,5);

    end

    properties(DiscreteState)

    end

    methods(Access = protected)
        function propArray = getMethodProps(obj)
        %getMethodProps method to get list of properties associated with each trajectory Method

            switch obj.Method
              case 'B-Spline'
                propArray = {};
              case 'Cubic Polynomial'
                propArray = {'VelocityBoundaryCondition'};
              case 'Quintic Polynomial'
                propArray = {'VelocityBoundaryCondition' 'AccelerationBoundaryCondition'};
            end
        end

        function inputNameArray = getMethodInputs(obj)
        %getMethodInputs method to get list of inputs associated with each trajectory Method

            switch obj.Method
              case 'B-Spline'
                inputNameArray = {};
              case 'Cubic Polynomial'
                inputNameArray = {'VelBC'};
              case 'Quintic Polynomial'
                inputNameArray = {'VelBC' 'AccelBC'};
            end
        end

        function setupImpl(~)
        % Perform one-time calculations, such as computing constants
        end

        function [q, qd, qdd] = stepImpl(obj, time, varargin)
        %stepImpl Implement algorithm.
        %   Compute outputs as a function of waypoints, timepoints,
        %   time, and the boundary conditions.

        % Get waypoints and time representation (time points or time interval)
            [qMat, Tpoints, inputOffsetNum] = obj.getSharedInputs(varargin);

            % Compute the terms using a minimal time vector since the
            % coefficients are all we actually want
            switch obj.Method
              case 'Cubic Polynomial'
                velBounds = obj.getPolynomialBC(varargin, inputOffsetNum);
                [ ~, ~, ~, pp] = cubicpolytraj(qMat, Tpoints, Tpoints, ...
                                               'VelocityBoundaryCondition', velBounds);
              case 'Quintic Polynomial'
                [velBounds, accBounds] = obj.getPolynomialBC(varargin, inputOffsetNum);
                [ ~, ~, ~, pp] = quinticpolytraj(qMat, Tpoints, Tpoints, ...
                                                 'VelocityBoundaryCondition', velBounds, 'AccelerationBoundaryCondition', accBounds);
              case 'B-Spline'
                [ ~, ~, ~, pp] = bsplinepolytraj(qMat, Tpoints, time);
            end

            % Compute the derivatives
            [ppd, ppdd] = obj.computePPDerivatives(pp, time);

            % Compute outputs at the times specified by the "time" input,
            % which may be either a vector or a scalar instant in time.
            q = ppval(pp, time);
            qd = ppval(ppd, time);
            qdd = ppval(ppdd, time);
        end

        function resetImpl(~)
        %resetImpl Initialize / reset discrete-state properties
        end

        function validatePropertiesImpl(obj)
        % Validate related or interdependent property values
            if strcmp(obj.WaypointSource, 'Internal')
                validateattributes(obj.Waypoints, {'numeric'}, {'2d','nonempty','real','finite'}, 'PolyTrajSys','wayPoints');
                if strcmp(obj.Method, 'B-Spline')
                    validateattributes(obj.TimeInterval, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'PolyTrajSys','timePoints');
                    coder.internal.errorIf((size(obj.Waypoints,2) < 4), 'shared_robotics:robotcore:utils:TooFewControlPoints');
                    coder.internal.errorIf((numel(obj.TimeInterval) < 2), 'shared_robotics:robotcore:utils:TimePointsSizeError');
                else
                    validateattributes(obj.TimePoints, {'numeric'}, {'nonempty','vector','real','finite','increasing','nonnegative'}, 'PolyTrajSys','timePoints');
                    coder.internal.errorIf((numel(obj.TimePoints) < 2), 'shared_robotics:robotcore:utils:TimePointsSizeError');
                    coder.internal.errorIf((numel(obj.TimePoints) ~= size(obj.Waypoints,2)), 'shared_robotics:robotcore:utils:WayPointMismatch');
                end
            end

            % Validate parameter dimensions against waypoint dimensions.
            % This can only be checked if both are internal, since external
            % dimensions are unknown at the time this method is called (in
            % the block mask).
            if (strcmp(obj.WaypointSource, 'Internal') && strcmp(obj.ParameterSource, 'Internal') && ~strcmp(obj.Method, 'B-Spline'))
                coder.internal.errorIf(size(obj.VelocityBoundaryCondition,1) ~= size(obj.Waypoints,1) || size(obj.VelocityBoundaryCondition,2) ~= size(obj.Waypoints,2), 'shared_robotics:robotcore:utils:WaypointVelocityBCDimensionMismatch');
                if strcmp(obj.Method, 'Quintic Polynomial')
                    coder.internal.errorIf(size(obj.AccelerationBoundaryCondition,1) ~= size(obj.Waypoints,1) || ...
                                           size(obj.AccelerationBoundaryCondition,2) ~= size(obj.Waypoints,2), ...
                                           'shared_robotics:robotcore:utils:WaypointAccelerationBCDimensionMismatch');
                end
            end
        end

        function flag = isInactivePropertyImpl(obj,prop)
        %isInactivePropertyImpl Identify inactive properties
        %   Return false if property is visible based on object
        %   configuration, for the command line and System block dialog

            if strcmp(obj.ParameterSource, 'Internal')
                methodProps = obj.getMethodProps;
            else
                methodProps = {};
            end

            if ~strcmp(obj.Method, 'B-Spline')
                methodProps = [methodProps {'ParameterSource'}];
            end

            if strcmp(obj.WaypointSource, "Internal")
                props = [{'Method', 'WaypointSource', 'Waypoints'} obj.getTimeProp methodProps];
            else
                props = [{'Method', 'WaypointSource'} methodProps];
            end

            flag = ~ismember(prop, props);
        end

        function validateInputsImpl(obj,time,varargin)
        % Validate inputs to the step method at initialization
        %   Since the inputs at initialization do not have value, these
        %   checks simply establish size matching

            validateattributes(time, {'numeric'}, {'nonempty', 'vector'}, 'PolyTrajSys', 'Time');

            [waypoints, timePoints, inputOffsetNum] = getSharedInputs(obj, varargin);
            validateattributes(waypoints, {'numeric'}, {'2d','nonempty'}, 'PolyTrajSys','wayPoints');
            coder.internal.errorIf((numel(timePoints) < 2), 'shared_robotics:robotcore:utils:TimePointsSizeError');

            if strcmp(obj.Method, 'B-Spline')
                validateattributes(timePoints, {'numeric'}, {'nonempty','vector'}, 'PolyTrajSys','timePoints');
                coder.internal.errorIf((size(waypoints,2) < 4), 'shared_robotics:robotcore:utils:TooFewControlPoints');
            else
                validateattributes(timePoints, {'numeric'}, {'nonempty','vector'}, 'PolyTrajSys','timePoints');
                coder.internal.errorIf((numel(timePoints) ~= size(waypoints,2)), 'shared_robotics:robotcore:utils:WayPointMismatch');

                % Boundary conditions
                [velBounds] = obj.getPolynomialBC(varargin, inputOffsetNum);
                coder.internal.errorIf(size(velBounds,1) ~= size(waypoints,1) || size(velBounds,2) ~= size(waypoints,2), 'shared_robotics:robotcore:utils:WaypointVelocityBCDimensionMismatch');
                if strcmp(obj.Method, 'Quintic Polynomial')
                    [~, accBounds] = obj.getPolynomialBC(varargin, inputOffsetNum);
                    coder.internal.errorIf(size(accBounds,1) ~= size(waypoints,1) || size(accBounds,2) ~= size(waypoints,2), 'shared_robotics:robotcore:utils:WaypointAccelerationBCDimensionMismatch');
                end
            end


        end

        function num = getNumInputsImpl(obj)
        %getNumInputsImpl Define total number of inputs for system with optional inputs

            num = 1;
            if strcmp(obj.WaypointSource, "External")
                num = num + 2;
            end

            if strcmp(obj.ParameterSource, "External")
                num = num + length(obj.getMethodInputs);
            end
        end

        function num = getNumOutputsImpl(~)
        %getNumOutputsImpl Define total number of outputs for system with optional outputs
            num = 3;
        end

        function icon = getIconImpl(obj)
        %getIconImpl Define icon for System block
            if strcmp(obj.Method, 'B-Spline')
                filepath = fullfile(matlabroot, 'toolbox', 'shared', 'robotics', 'robotslcore', 'blockicons', 'BSplineIcon.dvg');
            else
                filepath = fullfile(matlabroot, 'toolbox', 'shared', 'robotics', 'robotslcore', 'blockicons', 'CubicPolynomialIcon.dvg');
            end
            icon = matlab.system.display.Icon(filepath);
        end

        function varargout = getInputNamesImpl(obj)
        %getInputNamesImpl Return input port names for System block

            varargout = {'Time'};
            if strcmp(obj.WaypointSource, "External")
                varargout = [varargout {'Waypoints',obj.getTimeProp}];
            end

            if strcmp(obj.ParameterSource, "External")
                varargout = [varargout obj.getMethodInputs];
            end
        end

        function [out,out2,out3] = getOutputSizeImpl(obj)
        %getOutputSizeImpl Return size for each output port

        % Dimension of the output is propagated from waypoints
            if strcmp(obj.WaypointSource, "Internal")
                n = size(obj.Waypoints,1);
            else
                sz = propagatedInputSize(obj,2);
                if any(sz == 1)
                    % Row and column vectors are both propagated as 1x6, so
                    % it is necessary to force the edge case where the user
                    % passes a row vector. The opposite case, where they
                    % provide a column, is technically unsupported.
                    n = 1;
                else
                    n = sz(1);
                end
            end

            timeSize = max(propagatedInputSize(obj,1));
            out = [n timeSize];
            out2 = [n timeSize];
            out3 = [n timeSize];
        end

        function [out,out2,out3] = getOutputDataTypeImpl(obj)
        %getOutputDataTypeImpl Return data type for each output port

        % Propagate data type from the waypoints, which may be
        % specified internally or externally
            if strcmp(obj.WaypointSource, "Internal")
                out = class(obj.Waypoints);
                out2 = class(obj.Waypoints);
                out3 = class(obj.Waypoints);
            else
                out = propagatedInputDataType(obj,2);
                out2 = propagatedInputDataType(obj,2);
                out3 = propagatedInputDataType(obj,2);
            end
        end

        function [out,out2,out3] = isOutputComplexImpl(~)
        % Return true for each output port with complex data
            out = false;
            out2 = false;
            out3 = false;
        end

        function [out,out2,out3] = isOutputFixedSizeImpl(~)
        %isOutputFixedSizeImpl Return true for each output port with fixed size
            out = true;
            out2 = true;
            out3 = true;
        end

        function [velBounds, accBounds] = getPolynomialBC(obj, argsIn, inputOffsetNum)
        %getPolynomialBC Get boundary conditions

        % Parameters may be internal or external
            if strcmp(obj.ParameterSource, "External")
                velBounds = argsIn{inputOffsetNum + 1};
                if strcmp(obj.Method, 'Quintic Polynomial')
                    accBounds = argsIn{inputOffsetNum + 2};
                end
            else
                velBounds = obj.VelocityBoundaryCondition;
                accBounds = obj.AccelerationBoundaryCondition;
            end
        end

        function timeProperty = getTimeProp(obj)
        %getTimeProp Get the property used to represent time intervals

            if strcmp(obj.Method, 'B-Spline')
                timeProperty = 'TimeInterval';
            else
                timeProperty = 'TimePoints';
            end
        end

        function [formattedWaypoints, timePoints, inputOffsetNum] = getSharedInputs(obj, argsIn)
        %getSharedInputs Get waypoints and timePoints OR timeInterval

        % Waypoints and timepoints may be internal or external
            if strcmp(obj.WaypointSource, "Internal")
                waypoints = obj.Waypoints;
                if strcmp(obj.Method, 'B-Spline')
                    timePoints = obj.TimeInterval;
                else
                    timePoints = obj.TimePoints;
                end
                inputOffsetNum = 0;
            else
                waypoints = argsIn{1};
                timePoints = argsIn{2};
                inputOffsetNum = 2;
            end

            if isvector(waypoints)
                %Since some Simulink blocks convert row vectors to column
                %vector inputs, convert all vector inputs to rows
                formattedWaypoints = waypoints(:)';
            else
                formattedWaypoints = waypoints;
            end
        end

        function [ppd, ppdd] = computePPDerivatives(obj, pp, t)
        %computeDerivatives Compute pp-forms to represent first and second derivatives

        % Get breaks, coefficients, and dimensions of the original pp-form
            [oldBreaks, oldCoeffs, ~, ~, dim] = unmkpp(pp);

            % Modify the breaks to make sure the piecewise polynomial has
            % the correct velocity and accelerations when evaluated at the
            % final time. Note the derivatives before and after final time
            % are not continuous.
            if ~strcmp(obj.Method, 'B-Spline')
                newBreaks = robotics.core.internal.changeEndSegBreaks(oldBreaks, t);
            else
                newBreaks = oldBreaks;
            end

            % Initialize new coefficient matrix
            dCoefs = robotics.core.internal.polyCoeffsDerivative(oldCoeffs);
            ddCoefs = robotics.core.internal.polyCoeffsDerivative(dCoefs);

            % Construct new polynomial forms
            ppd = mkpp(newBreaks, dCoefs, dim);
            ppdd = mkpp(newBreaks, ddCoefs, dim);
        end
    end

    methods(Access = protected, Static)
        function header = getHeaderImpl
        %getHeaderImpl Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"),...
                                                  'Title',message('shared_robotics:robotslcore:trajectorygeneration:PolynomialTitle').getString, ...
                                                  'Text', message('shared_robotics:robotslcore:trajectorygeneration:PolynomialDescription').getString, ...
                                                  'ShowSourceLink', false);
        end

        function groups = getPropertyGroupsImpl
        %getPropertyGroupsImpl Define property groups in mask

        % Section titles and descriptions
            WaypointInputSectionName = message('shared_robotics:robotslcore:trajectorygeneration:WaypointsSectionTitle').getString;
            ParameterInputSectionName = message('shared_robotics:robotslcore:trajectorygeneration:ParametersSectionTitle').getString;

            % Properties associated with waypoints section
            propWaypointSource = matlab.system.display.internal.Property('WaypointSource','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:WaypointSourcePrompt')));
            propWaypoints = matlab.system.display.internal.Property('Waypoints','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:WaypointsPrompt')));
            propTimePoints = matlab.system.display.internal.Property('TimePoints','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:TimePointsPrompt')));
            propTimeInterval = matlab.system.display.internal.Property('TimeInterval','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:TimeIntervalPrompt')));

            % Properties associated with time scaling
            propParameterSource = matlab.system.display.internal.Property('ParameterSource','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:ParameterSourcePrompt')));
            propMethod = matlab.system.display.internal.Property('Method','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:PolynomialMethodPrompt')));
            propVelocityBoundaryCondition = matlab.system.display.internal.Property('VelocityBoundaryCondition','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:PolynomialVelocityBCPrompt')));
            propAccelerationBoundaryCondition = matlab.system.display.internal.Property('AccelerationBoundaryCondition','Description',getString(message('shared_robotics:robotslcore:trajectorygeneration:PolynomialAccelerationBCPrompt')));

            waypointProps = matlab.system.display.Section( ...
                'Title', WaypointInputSectionName, ...
                'PropertyList', {propWaypointSource, propWaypoints, propTimePoints, propTimeInterval});

            inputProps = matlab.system.display.Section( ...
                'Title', ParameterInputSectionName, ...
                'PropertyList', {propMethod, propParameterSource, propVelocityBoundaryCondition, propAccelerationBoundaryCondition});

            groups = [waypointProps inputProps];
        end
    end
end
