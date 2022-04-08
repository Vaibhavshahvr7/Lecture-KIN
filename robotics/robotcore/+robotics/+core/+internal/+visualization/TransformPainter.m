classdef TransformPainter < robotics.core.internal.visualization.Painter3D
    %This class is for internal use only. It may be removed in the future.
    
    %TransformPainter paints transforms in 3D space
    
    %   Copyright 2018 The MathWorks, Inc.
    
    properties (Constant)
        %DefaultColor - Default color of mesh
        DefaultColor = [1 0 0]
        
        %DefaultScale - Default scale of mesh
        DefaultScale = 1
        
        %DefaultZDownward - Default inertial frame Z axis point upwards
        DefaultInertialZDownward = false
        
        %GraphicsObjectTags - Tags for graphic objects
        GraphicsObjectTags = struct(...
            'InertialToPlot', 'InertiaToPlotTransform', ...
            'BodyToInertial', 'BodyToInertialTransform', ...
            'PatchToBody', 'PatchToBodyTransform', ...
            'Patch', 'MeshPatch', ...
            'xAxis', 'xAxis', ...
            'yAxis', 'yAxis', ...
            'zAxis', 'zAxis' ...
            );
    end
    
    properties (Access = {?robotics.core.internal.visualization.TransformPainter, ?matlab.unittest.TestCase})
        %Vertices - vertices of the mesh
        Vertices
        
        %Faces - Faces of the mesh
        Faces
        
        %HGroup - Handle to a hggroup
        %   everything painted with the same TransformPainter belongs to the same
        %   group
        HGroup
    end
    
    properties
        %Color - color of the rendered mesh
        Color = robotics.core.internal.visualization.TransformPainter.DefaultColor
        
        %Scale - scale of the rendered mesh
        Size = robotics.core.internal.visualization.TransformPainter.DefaultScale
        
        %ZDownward - indicates whether inertial frame's Z axis points downwards
        InertialZDownward = robotics.core.internal.visualization.TransformPainter.DefaultInertialZDownward
        
        %HandleXAxis - Handle to the x axis of the frame attached to the mesh
        HandleXAxis
        
        %HandleYAxis - Handle to the y axis of the frame attached to the mesh
        HandleYAxis
        
        %HandleZAxis - Handle to the z axis of the frame attached to the mesh
        HandleZAxis
    end
    
    methods
        function obj = TransformPainter(parentHandle, model, setupPerspective)
            %TransformPainter constructs a TransformPainter
            
            obj@robotics.core.internal.visualization.Painter3D(parentHandle, setupPerspective);
            obj.HGroup = hggroup(parentHandle);
            [obj.Vertices, obj.Faces] = robotics.core.internal.visualization.TransformPainter.parseSTL(model);
        end
        
        function hMeshTransform = paintAt(obj, position, orientation)
            %paintAt paint a mesh at given position and orientation
            
            % Three transforms are involved:
            % 1. from mesh XYZ to body frame
            % 2. from body frame to inertial frame
            % 3. from inertial frame to plot XYZ
            
            import robotics.core.internal.visualization.*
            
            % Transform from inertial frame to plot XYZ
            hMeshTransform = hgtransform('Parent', obj.HGroup);
            hMeshTransform.Tag = TransformPainter.GraphicsObjectTags.InertialToPlot;
            
            % Transform from body frame to inertial frame
            hBodyToInertial = hgtransform('Parent', hMeshTransform);
            hBodyToInertial.Tag = TransformPainter.GraphicsObjectTags.BodyToInertial;
            
            % Transform from mesh XYZ to body frame
            hMeshToBody = hgtransform('Parent', hBodyToInertial);
            hMeshToBody.Tag = TransformPainter.GraphicsObjectTags.PatchToBody;
            
            % Transform according to InertialZ direction
            if obj.InertialZDownward
                tform = eul2tform([0,0,pi]);
                set(hMeshToBody, 'Matrix', tform);
                set(hMeshTransform, 'Matrix', tform);
            end
            
            % Create patch within the mesh transform
            p = patch(hMeshToBody, ...
                'Vertices', obj.Vertices*obj.Size, ...
                'Faces', obj.Faces, ...
                'FaceColor', obj.Color, ...
                'LineStyle','none');
            p.Tag = TransformPainter.GraphicsObjectTags.Patch;
            
            % Create axes within the inertial transform
            obj.HandleXAxis = plot3(hBodyToInertial, [0 obj.Size], [0 0], [0 0], 'r');
            obj.HandleXAxis.Tag = TransformPainter.GraphicsObjectTags.xAxis;
            obj.HandleYAxis = plot3(hBodyToInertial, [0 0], [0 obj.Size], [0 0], 'g');
            obj.HandleYAxis.Tag = TransformPainter.GraphicsObjectTags.yAxis;
            obj.HandleZAxis = plot3(hBodyToInertial, [0 0], [0 0], [0 obj.Size], 'b');
            obj.HandleZAxis.Tag = TransformPainter.GraphicsObjectTags.zAxis;
            
            % Move the whole transform to designated position and
            % orientation
            obj.move(hMeshTransform, position, orientation);
        end
        
        function move(~, hMeshTransform, position, orientation)
            %move a painted mesh to target position and orientation
            
            import robotics.core.internal.visualization.*
            % move the inertial transform
            hBodyToInertial = findobj(hMeshTransform, 'Type', 'hgtransform', ...
                'Tag', TransformPainter.GraphicsObjectTags.BodyToInertial);
            tform = quat2tform(orientation);
            tform(1:3,4) = position;
            set(hBodyToInertial, 'Matrix', tform);
        end
    end
    
    methods (Static, Access = private)
        function [vertices,faces] = parseSTL(filepath)
            %parseSTL parse stl file into vertices and faces, normalize all
            %vertices to be within [-0.5, 0.5];
            import robotics.core.internal.visualization.*
            
            try
                stlTriangulation = stlread(filepath);
                vertices = stlTriangulation.Points;
                faces = stlTriangulation.ConnectivityList;
            catch
                % stl parse failed, don't show any mesh
                vertices = [];
                faces = [];
            end
            
            if ~isempty(vertices)
                vertices = vertices-mean(vertices,1);
                vertices = vertices/max(abs(vertices(:)))/2;
            end
        end

    end
end

