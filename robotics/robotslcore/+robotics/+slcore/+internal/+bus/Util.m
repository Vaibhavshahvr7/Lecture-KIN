classdef Util
%This class is for internal use only. It may be removed in the future.

%BUS.UTIL - Utility functions for working with Simulink buses

%   Copyright 2019 The MathWorks, Inc.

    properties

        %BusNamePrefix Select bus prefix name
        BusNamePrefix
        %MsgPackageName Name of message package
        MsgPackageName
    end

    %%  General Bus-related utilities
    methods

        function [busExists,busName] = checkForBus(obj,msgType, model)
            busName = obj.messageTypeToBusName(msgType, model, obj.BusNamePrefix);
            busExists = robotics.slcore.internal.util.existsInGlobalScope(bdroot(model), busName);
        end

        function busName = createBusIfNeeded(obj,msgType, model)
            validateattributes(msgType, {'char'}, {'nonempty'});
            validateattributes(model, {'char'}, {});

            [busExists,busName] = obj.checkForBus(msgType, model);
            if busExists
                return;
            end

            emptyStructMsg = obj.newMessageFromSimulinkMsgType(msgType);

            robotics.slcore.internal.util.getBusDefnForStruct(emptyStructMsg, model, obj.BusNamePrefix);
        end

        function messageDefn = newMessageFromSimulinkMsgType(obj,msgType)
        %newMessageFromSimulinkMsgType Create a new Gazebo message from message type
        %Currently we are using a class for each message type

        % convert to the correct class that has the message type. This
        % is a temporary solution. Once the correct message struct is
        % defined this will be updated.
        %!!!!TO DO !!!!!!!!!
            splitMsgType = split(msgType,'/');
            upperFirstLetter = upper(splitMsgType{1}(1));

            msgClass = [obj.MsgPackageName upperFirstLetter splitMsgType{1}(2:end) '_' splitMsgType{2}];
            messageDefn = eval(msgClass);
        end
    end


    methods (Static)
        function [datatype,busName] = messageTypeToDataTypeStr(messageType, model, busNamePrefix)

        %retain original bus prefix
            if nargin < 3
                busNamePrefix = 'SL_Bus_';
            end
            % This is used wherever a Simulink DataTypeStr is required
            % (e.g., for specifying the output datatype of a Constant block)
            % ** DOES NOT CREATE A BUS **
            busName = robotics.slcore.internal.bus.Util.messageTypeToBusName(messageType, model,busNamePrefix);
            datatype = ['Bus: ' busName];
        end

        function busName = messageTypeToBusName(messageType, model,busNamePrefix)
        %
        % messageTypeToBusName(MSGTYPE,MODEL) returns the bus name
        % corresponding to a message type MSGTYPE (e.g.,
        % 'std_msgs/Int32') and a Simulink model MODEL. The function
        % uses the following rules:
        %
        % Rule 1 - Generate a name using the format:
        %    SL_Bus_<modelname>_<msgtype>
        %
        % Rule 2 - If the result of Rule 1 is longer than 60
        % characters, use the following general format:
        %    SL_Bus_<modelname(1:25)>_<msgtype(end-25:end)>_<hash>
        % where <hash> is a base 36 hash of the full name (output of
        % rule #1).
        %
        % ** THIS FUNCTION DOES NOT CREATE A BUS OBJECT **

        %Keep original bus prefix name
            if nargin < 3
                busNamePrefix = 'SL_Bus_';
            end

            validateattributes(messageType, {'char'}, {'nonempty'});
            assert(ischar(model));

            maxlen = 60; choplen=50;
            assert(maxlen <= namelengthmax);

            busName = [busNamePrefix messageType];
            if length(busName) < maxlen
                busName = matlab.lang.makeValidName(busName, 'ReplacementStyle', 'underscore');
            else
                % add a trailing hash string (5-6 chars) to make the busname unique
                hashStr = robotics.slcore.internal.bus.Util.hashString(busName);

                idx = strfind(messageType, '/');
                if isempty(idx)
                    idx = 0;
                else
                    idx = idx(1);
                end
                messageType = messageType(idx+1:min(idx+choplen,end));  % get first 50 chars
                busName = matlab.lang.makeValidName(...
                    [busNamePrefix ...
                     messageType '_' hashStr], ...
                    'ReplacementStyle', 'underscore');
            end
        end
    end

    methods(Static, Access=private)

        function hashStr = hashString(str)
            javaStr = java.lang.String(str);
            hashStr = lower(dec2base(uint64(abs(javaStr.hashCode)), 36)); % usually 5-6 chars
        end

    end

end
