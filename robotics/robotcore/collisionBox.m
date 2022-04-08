classdef collisionBox < robotics.core.internal.CollisionGeometryBase
%COLLISIONBOX Create a collision geometry as a box primitive
%   A box primitive is specified by its three side lengths. The box is
%   axis-aligned with its own body-fixed frame, whose origin is at the
%   box's center.
%
%   BOX = collisionBox(X, Y, Z) creates a box primitive with X, Y, Z as
%   its side lengths along the corresponding axes in the geometry-fixed
%   frame that is ready for collision checking. By default the
%   geometry-fixed frame collocates with the world frame.
%
%
%   collisionBox properties:
%       X           - Side length of the box along x-axis
%       Y           - Side length of the box along y-axis
%       Z           - Side length of the box along z-axis
%       Pose        - Pose of the box relative to the world frame
%
%
%   collisionBox method:
%       show                - plot box in MATLAB figure
%
%   See also checkCollision, collisionCylinder, collisionSphere, collisionMesh.

%   Copyright 2018-2019 The MathWorks, Inc.

%#codegen

    properties (Dependent)
        %X Side length of the box along x-axis of the geometry-fixed frame
        X
        
        %Y Side length of the box along y-axis of the geometry-fixed frame
        Y
        
        %Z Side length of the box along z-axis of the geometry-fixed frame
        Z
    end
    
    properties (Access = {?robotics.core.internal.InternalAccess})
        %XInternal
        XInternal
        
        %YInternal
        YInternal
        
        %ZInternal
        ZInternal
    end
    
    methods
        function obj = collisionBox(x, y, z)
            %COLLISIONBOX Constructor
            narginchk(3,3);
            
            validateattributes(x, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'X');
            validateattributes(y, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'Y');
            validateattributes(z, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'Z');
            obj.XInternal = x;
            obj.YInternal = y;
            obj.ZInternal = z;
            obj.updateGeometry(x, y, z);

        end

    end
    
    methods
        function set.X(obj, x)
            %set.X
            validateattributes(x, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'X');
            obj.XInternal = x;
            obj.updateGeometry(x, obj.YInternal, obj.ZInternal);
        end

        function set.Y(obj, y)
            %set.Y
            validateattributes(y, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'Y');
            obj.YInternal = y;
            obj.updateGeometry(obj.XInternal, y, obj.ZInternal);
        end

        function set.Z(obj, z)
            %set.Z
            validateattributes(z, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                'finite', 'nonnegative'}, 'collisionBox', 'Z');
            obj.ZInternal = z;
            obj.updateGeometry(obj.XInternal, obj.YInternal, z);
        end
        
        function x = get.X(obj)
            %get.X
            x = obj.XInternal;
        end
        
        function y = get.Y(obj)
            %get.Y
            y = obj.YInternal;
        end
        
        function z = get.Z(obj)
            %get.Z
            z = obj.ZInternal;
        end
        
        function newObj = copy(obj)
            %copy Creates a deep copy of the collision box object
            newObj = collisionBox(obj.XInternal, obj.YInternal, obj.ZInternal);
            newObj.Pose = obj.Pose;
        end

        
    end
    
    methods (Access = {?robotics.core.internal.InternalAccess})
        function updateGeometry(obj, x, y, z)
            %updateGeometry
            if(~coder.target('MATLAB'))
                obj.GeometryInternal = ...
                robotics.core.internal.coder.CollisionGeometryBuildable.makeBox(x, y, z);
            else
                obj.GeometryInternal = robotics.core.internal.CollisionGeometry(x, y, z);
            end
            [F, V] = robotics.core.internal.PrimitiveMeshGenerator.boxMesh([x,y,z]);
            obj.VisualMeshVertices = V;
            obj.VisualMeshFaces = F;
            obj.EstimatedMaxReach = max([x, y, z]);            
        end
    end
    
    methods(Static, Access = protected)
        function obj = loadobj(objFromMAT)
            %loadobj
            obj = collisionBox(objFromMAT.X, objFromMAT.Y, objFromMAT.Z);
            obj.Pose = objFromMAT.Pose;
            
        end
    end    
end

