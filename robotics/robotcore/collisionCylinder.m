classdef collisionCylinder < robotics.core.internal.CollisionGeometryBase
    %COLLISIONCYLINDER Create a collision geometry as a cylinder primitive
    %   A cylinder primitive is specified by the radius and the length. The 
    %   cylinder is axis-aligned with its own body-fixed frame (the side of
    %   the cylinder lies along the z axis). The origin of the body-fixed
    %   frame is at the cylinder's center.
    %
    %   CYL = collisionCylinder(RADIUS, LENGTH) creates a cylinder primitive
    %   with radius RADIUS and length LENGTH that is ready for collision 
    %   checking. By default the geometry-fixed frame collocates with the 
    %   world frame.
    %
    %
    %   collisionCylinder properties:
    %       Radius      - Radius of the cylinder
    %       Length      - Length of the cylinder
    %       Pose        - Pose of the cylinder relative to the world frame
    %
    %   collisionCylinder method:
    %       show                - plot cylinder in MATLAB figure
    %
    %   See also checkCollision, collisionBox, collisionSphere, collisionMesh.

    %   Copyright 2019 The MathWorks, Inc.

    %#codegen
    
    properties (Dependent)
        %Radius The radius of the cylinder
        Radius
        
        %Length The length of the cylinder
        Length
        
    end
    
    properties (Access = {?robotics.core.internal.InternalAccess})
        %RadiusInternal
        RadiusInternal
        
        %Length
        LengthInternal      
    end
    
    methods
        function obj = collisionCylinder(radius, length)
            %COLLISIONCYLINDER Constructor
            narginchk(2,2);
            
            validateattributes(radius, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'positive'}, 'collisionCylinder', 'Radius');
                                                
            validateattributes(length, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'nonnegative'}, 'collisionCylinder', 'Length'); % can be zero
            obj.RadiusInternal = radius;
            obj.LengthInternal = length;
            obj.updateGeometry(radius, length);
        end
        
        function set.Radius(obj, radius)
            %set.Radius
            validateattributes(radius, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'positive'}, 'collisionCylinder', 'Radius');
                                                
            obj.RadiusInternal = radius;
            obj.updateGeometry(radius, obj.LengthInternal);
        end
        
        function set.Length(obj, length)
            %set.Length
            validateattributes(length, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'nonnegative'}, 'collisionCylinder', 'Length');
                                                
            obj.LengthInternal = length;
            obj.updateGeometry(obj.RadiusInternal, length);
        end
        
        function radius = get.Radius(obj)
            %get.Radius
            radius = obj.RadiusInternal;
        end

        function length = get.Length(obj)
            %get.Length
            length = obj.LengthInternal;
        end
        
        function newObj = copy(obj)
            %copy Creates a deep copy of the collision cylinder object
            newObj = collisionCylinder(obj.RadiusInternal, obj.LengthInternal);
            newObj.Pose = obj.Pose;
        end
        
    end
    
    methods (Access = {?robotics.core.internal.InternalAccess})
        function updateGeometry(obj, radius, length)
            %updateGeometry
            if(~coder.target('MATLAB'))
                obj.GeometryInternal = ...
                robotics.core.internal.coder.CollisionGeometryBuildable.makeCylinder(radius, length);
            else
                obj.GeometryInternal = robotics.core.internal.CollisionGeometry(radius, length);
            end
            [F, V] = robotics.core.internal.PrimitiveMeshGenerator.cylinderMesh([radius, length]);
            obj.VisualMeshVertices = V;
            obj.VisualMeshFaces = F;
            obj.EstimatedMaxReach = 2*max([radius, 0.5*length]);            
        end
    end

    methods(Static, Access = protected)
        function obj = loadobj(objFromMAT)
            %loadobj
            
            obj = collisionCylinder(objFromMAT.RadiusInternal, ...
                                    objFromMAT.LengthInternal);
            obj.Pose = objFromMAT.Pose;
        end
    end
end

