classdef collisionMesh < robotics.core.internal.CollisionGeometryBase
    %COLLISIONMESH Create a collision geometry as a convex mesh
    %   A collision mesh is specified by a list of 3D vertices. The vertices
    %   are specified in a geometry-fixed frame of the user's choice.
    %
    %   MSH = collisionMesh(VERTICES) creates a convex collision mesh MSH 
    %   from the list of VERTICES. By default the geometry-fixed frame 
    %   collocates with the world frame. 
    %
    %
    %   collisionMesh properties:
    %       Vertices    - An N-by-3 matrix where N is the number 
    %                     of vertices. Each row in Vertices represents 
    %                     the coordinates of a point in the 3D space.
    %                     Note that some of the points might be
    %                     inside the constructed convex mesh.
    %       Pose        - Pose of the mesh relative to the world frame
    %
    %
    %   collisionMesh method:
    %       show                - plot the mesh in MATLAB figure
    %
    %   See also checkCollision, collisionBox, collisionCylinder, collisionSphere.
    
    %   Copyright 2019 The MathWorks, Inc.
    %#codegen
    
    properties (Dependent)
        %Vertices Vertices of the mesh
        Vertices
    end
    
    properties (Access = {?robotics.core.internal.InternalAccess})
        
        %VerticesInternal
        VerticesInternal
    end
    
    methods
        function obj = collisionMesh(vertices)
            %COLLISIONMESH Constructor
            narginchk(1,1);
            
            validateattributes(vertices, {'double'}, {'real', 'nonempty', 'ncols', 3, ...
                                                     'finite'}, 'collisionMesh', 'Vertices');
            obj.VerticesInternal = vertices;
            obj.updateGeometry(vertices);

        end
        
        function set.Vertices(obj, vertices)
            %set.Vertices
            validateattributes(vertices, {'double'}, {'real', 'nonempty', 'ncols', 3, ...
                                                    'finite'}, 'collisionMesh', 'Vertices');
            
            obj.VerticesInternal = vertices;
            obj.updateGeometry(vertices);
        end
        
        function vertices = get.Vertices(obj)
            %get.Vertices
            vertices = obj.VerticesInternal;
        end
        
        function newObj = copy(obj)
            %copy Creates a deep copy of the collision mesh object
            newObj = collisionMesh(obj.VerticesInternal);
            newObj.Pose = obj.Pose;
        end

    end
    
    methods (Access = {?robotics.core.internal.InternalAccess})
        function updateGeometry(obj, vertices)
            %updateGeometry
            if(~coder.target('MATLAB'))
                obj.GeometryInternal = ...
                robotics.core.internal.coder.CollisionGeometryBuildable.makeMesh(vertices, size(vertices, 1));
            else
                obj.GeometryInternal = robotics.core.internal.CollisionGeometry(vertices, size(vertices,1));
                try
                    F = convhull(vertices);
                    obj.VisualMeshVertices = vertices;
                    obj.VisualMeshFaces = F;
                catch
                    % only needed when fewer than 3 vertices are provided
                    if size(vertices, 1) == 1
                        obj.VisualMeshVertices = repmat(vertices, 3, 1);
                    elseif size(vertices, 1) == 2
                        obj.VisualMeshVertices = [vertices; vertices(2,:)];
                    else
                        obj.VisualMeshVertices = vertices;
                    end
                end
            end
            obj.EstimatedMaxReach = 2*max(max(vertices));       
            
        end
    end

    methods(Static, Access = protected)
        function obj = loadobj(objFromMAT)
            %loadobj
            
            obj = collisionMesh(objFromMAT.VerticesInternal);
            obj.Pose = objFromMAT.Pose;
        end
    end
end

