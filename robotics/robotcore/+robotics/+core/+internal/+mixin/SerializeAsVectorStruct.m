classdef (HandleCompatible) SerializeAsVectorStruct
    %This class is for internal use only. It may be removed in the future.
    
    %SerializeAsVectorStruct allows value/handle classes to be serialized as structure or vector
    %
    %   This mixin is designed to provide a code generation compatible
    %   interface for serializing the public numeric properties of given
    %   class in vectors and structs format.
    %
    %   The classes must be value classes containing only numerical fields.
    %   Only public fields are serialized into vector/struct format.
    %
    %   Example:
    %
    %   Class Definition:
    %
    %   classdef dummy < robotics.core.internal.mixin.SerializeAsVectorStruct
    %
    %       properties
    %           a
    %       end
    %
    %       methods
    %           function out = dummy(dataType)
    %               obj@robotics.core.internal.mixin.SerializeAsVectorStruct(dataType);
    %               out.a = cast(0, dataType);
    %           end
    %
    %           function out = getStructName(~)
    %               out = "dummy";
    %           end
    %       end
    %
    %       methods (Static)
    %           function out = constructObject(dataType)
    %               out = dummy(dataType);
    %           end
    %       end
    %   end
    %
    %   Usage
    %
    %   >> a = dummy('single')
    %       a =
    %
    %     dummy with properties:
    %
    %       a: 0
    %
    %   v = a.toVector('double')
    %
    %   v =
    %
    %        0
    %
    %   v = 1;
    %
    %   a = a.fromVector(v, 'double')
    %
    %   a =
    %
    %     dummy with properties:
    %
    %       a: 1
    %
    %   >> s = a.toStruct('double')
    %
    %   s =
    %
    %     struct with fields:
    %
    %       a: 1
    %
    %   s.a = 2;
    %
    %   a = a.fromStruct(s, 'single')
    %
    %   a =
    %
    %     dummy with properties:
    %
    %       a: 2
    %
    %   a.a
    %
    %   ans =
    %
    %     single
    %
    %        2
    
    
    %   Copyright 2018 The MathWorks, Inc.
    
    %#codegen
    
    methods (Abstract, Static)
        %constructObject - dispatch to the input object's constructor with dataType
        out = constructObject(dataType);
        
        %getStructName - returns a string representing the object's name in generated code
        %   This string is associated with the generated struct in generated
        %   code This method cannot be replaced by an Abstract property, as
        %   it should not be serialized into struct or vector.
        structName = getStructName()
    end
    
    methods
        function obj = SerializeAsVectorStruct(dataType) %#ok<*INUSD> due to removed validation
            %SerializeAsVectorStruct constructor 
            %   Enforce subclass to create constructor that accepts
            %   |dataType| as input. |dataType| must be 'double' or
            %   'single'
            %   validatestring(dataType, {'double', 'single'}, 'SerializeAsVectorStruct', 'dataType');
        end
    end
    
    methods
        function out = cast(in, dataType)
            %cast returns a copy of |inObj| casted to |dataType|.
            %   The returned object has same field values as |in| casted to
            %   |dataType|. |dataType| must be 'double' or 'single'
            out = in.constructObject(dataType);
            [fieldNames, numFields] = extractFields(in);
            for i = 1:numFields
                out.(fieldNames{i})(:) = in.(fieldNames{i});
            end
        end
        
        function out = fromVector(in, v, dataType)
            %fromVector assign the values in |v| to |in| casted to |dataType| and return it as out
            %   The size of |v| must be the same as the total number of
            %   numerical elements contained in all the public fields of |in|
            %   |v| is a 1-D column vector
            
            out = cast(in, dataType);
            [fieldNames, numFields] = extractFields(in);
            
            % serialize the values from vector to target object field
            % by field
            k = 1;
            for i = 1:numFields
                kend = k+numel(out.(fieldNames{i}))-1;
                out.(fieldNames{i})(:) = v(k:kend);
                k = kend + 1;
            end
        end
        
        function out = fromStruct(in, s, dataType)
            %fromStruct assign the values in |s| to |in| casted to |dataType| and return it as out
            %   The fields of |s| must be the same as the public fields of
            %   |in|. The dimensions of the field values of |s| must also be
            %   the same as that of |in|.
            
            out = cast(in, dataType);
            [fieldNames, numFields] = extractFields(in);
            
            % serialize the values from struct to target object field
            % by field
            for i = 1:numFields
                out.(fieldNames{i})(:) = s.(fieldNames{i});
            end
        end
        
        function s = toStruct(in, dataType)
            %toStruct returns a struct |s| based on |in| using given |dataType|. 
            %   |s| is associated with the struct name specified by |in|
            %   object, when it is used in generated code.
            
            coder.extrinsic('robotics.core.internal.mixin.SerializeAsVectorStruct.class2struct');
            coder.extrinsic('strcat');
            
            % the struct should be constructed base on compile time
            % constant, which is |dataType| and the static method
            % in.constructObject
            s = coder.const(...
                robotics.core.internal.mixin.SerializeAsVectorStruct.class2struct(...
                in.constructObject(dataType)));
            [fieldNames, numFields] = in.extractFields();
            
            % deserialize values from struct to class field by field
            for i = 1:numFields
                s.(fieldNames{i})(:) = in.(fieldNames{i});
            end
            
            % assign a codegen struct name for the generated struct
            % This feature is currently disabled due to g1811684
            
            % coder.const(dataType);
            % typedStructName = coder.const(in.getStructName);
            % dataTypeStr = coder.const(struct('double', "Flt64", 'single', "Flt32"));
            % coder.cstructname(s, coder.const(strcat(typedStructName, dataTypeStr.(dataType))));
        end
        
        function v = toVector(in, dataType)
            %toVector returns a vector |v| based on |in| using given |dataType|. 
            %  |v| concatenate all the values of |in|'s public field as a
            %  1-D column vector
            
            % calculate the end position of each field value
            % in the serialized vector
            % Fields that includes [a1, a2, a3, ...] elements
            % corresponds to the following ending positions
            % [a1, a1 + a2, a1 + a2 + a3, ...]
            [fieldNames, numFields] = extractFields(in);
            
            nElem = zeros(1, numFields);
            nElem(1) = numel(in.(fieldNames{1}));
            
            for i = 2:numFields
                nElem(i) = numel(in.(fieldNames{i})) + nElem(i-1);
            end
            
            % deserialize values from struct to class field by field
            v = coder.nullcopy(zeros(nElem(numFields),1, dataType));
            
            v(1:nElem(1)) = in.(fieldNames{1});
            for i = 2:numFields
                v(nElem(i-1)+1:nElem(i)) = in.(fieldNames{i});
            end
        end
    end
    
    methods (Access = private)
        function [fieldNames, numFields] = extractFields(in)
            %extractFields extracts the static information of the class
            %that utilized this mixin
            coder.extrinsic('fields');
            
            % the fieldNames should be extracted base on compile time
            % constant, which is the static method |in.constructObject|
            fieldNames = coder.const(fields(in.constructObject('double')));
            numFields = coder.const(numel(fields(in.constructObject('double'))));
        end
    end
    
    methods (Static)
        function s = class2struct(obj)
            %class2struct converts a class into a struct with same public
            %fields and field values
            s = struct();
            f = fields(obj);
            for i = 1:numel(f)
                s.(f{i}) = obj.(f{i});
            end
        end
    end
end

