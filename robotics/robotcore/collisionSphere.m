classdef collisionSphere < robotics.core.internal.CollisionGeometryBase
    %COLLISIONSPHERE Create a collision geometry as a sphere primitive
    %   A sphere primitive is specified by its radius. The origin
    %   of the geometry-fixed frame is at the sphere's center.
    %
    %   SPH = collisionSphere(RADIUS) creates a sphere primitive with radius
    %   RADIUS that is ready for collision checking. By default the 
    %   geometry-fixed frame collocates with the world frame. 
    %
    %
    %   collisionSphere properties:
    %       Radius      - Radius of the sphere
    %       Pose        - Pose of the sphere relative to the world frame
    %
    %
    %   collisionSphere method:
    %       show                - plot sphere in MATLAB figure
    %
    %   See also checkCollision, collisionBox, collisionCylinder, collisionMesh.
    
    %   Copyright 2019 The MathWorks, Inc.

    %#codegen
    
    properties (Dependent)
        %Radius Radius of the Sphere
        Radius
    end
    
    properties (Access = {?robotics.core.internal.InternalAccess})
        
        %RadiusInternal
        RadiusInternal
    end
    
    methods
        function obj = collisionSphere(radius)
            %COLLISIONSPHERE Constructor
            narginchk(1,1);
            
            validateattributes(radius, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'positive'}, 'collisionSphere', 'radius');
            obj.RadiusInternal = radius;
            obj.updateGeometry(radius);

        end
        
        function set.Radius(obj, radius)
            %set.Radius
            validateattributes(radius, {'double'}, {'scalar', 'real', 'nonempty', ...
                                                    'finite', 'positive'}, 'collisionSphere', 'radius');
            obj.RadiusInternal = radius;
            obj.updateGeometry(radius);
        end
        
        function radius = get.Radius(obj)
            %get.Radius
            radius = obj.RadiusInternal;
        end
        
        function newObj = copy(obj)
            %copy Creates a deep copy of the collision sphere object
            newObj = collisionSphere(obj.RadiusInternal);
            newObj.Pose = obj.Pose;
        end        

    end
    
    methods (Access = {?robotics.core.internal.InternalAccess})
        function updateGeometry(obj, radius)
            %updateGeometry
            if(~coder.target('MATLAB'))
                obj.GeometryInternal = ...
                robotics.core.internal.coder.CollisionGeometryBuildable.makeSphere(radius);
            else
                obj.GeometryInternal = robotics.core.internal.CollisionGeometry(radius);
            end
            [F, V] = robotics.core.internal.PrimitiveMeshGenerator.sphereMesh(radius);
            obj.VisualMeshVertices = V;
            obj.VisualMeshFaces = F;
            obj.EstimatedMaxReach = 2*radius;      
        end
    end

    methods(Static, Access = protected)
        function obj = loadobj(objFromMAT)
            %loadobj
            
            obj = collisionSphere(objFromMAT.RadiusInternal);
            obj.Pose = objFromMAT.Pose;
        end
    end
end

