classdef PrimitiveMeshGenerator  < robotics.core.internal.InternalAccess
%This class is for internal use only. It may be removed in the future.

%PRIMITIVEMESHGENERATOR Utilities to generate meshes for common geometric primitives
%   such as cube, sphere or cylinder

%   Copyright 2018-2019 The MathWorks, Inc.

%#codegen

    methods (Static)
        function [F, V] = boxMesh(sz)
            %boxMesh Create mesh for a box shape. The origin is at the
            %   center of the box. The input arguments are the three side
            %   lengths of the box, given as a 3-by-1 vector
            xl = sz(1); yl = sz(2); zl = sz(3);
            
            V = [xl/2, -yl/2, -zl/2; 
                 xl/2,  yl/2, -zl/2;
                -xl/2,  yl/2, -zl/2;
                -xl/2, -yl/2, -zl/2;
                 xl/2, -yl/2,  zl/2; 
                 xl/2,  yl/2,  zl/2;
                -xl/2,  yl/2,  zl/2;
                -xl/2, -yl/2,  zl/2];
            F = [1 2 6;
                 1 6 5;
                 2 3 7;
                 2 7 6;
                 3 4 8;
                 3 8 7;
                 4 1 5;
                 4 5 8;
                 5 6 7;
                 5 7 8;
                 1 4 2;
                 2 4 3];
             
             F = robotics.core.internal.PrimitiveMeshGenerator.flipFace(F);
        end
        
        function [Fz, Vz] = cylinderMesh(rl)
            %cylinderMesh Create mesh for a cylinder shape. The origin is 
            %   at the center of the cylinder, and the cylinder is pointing
            %   along the z axis. The input arguments are the radius and
            %   the length of the cylinder, given as a 1-by-2 vector
            
            r = rl(1); l = rl(2);
            N = 32;
            theta = linspace(0, 2*pi,N);
            theta = theta(1:end-1)';
    
            m = length(theta);
    
            % z-axis cylinder
            Vz = [r*cos(theta), r*sin(theta), -(l/2)*ones(m, 1)];
            Vz = [Vz;Vz];
            Vz(m+1:2*m,3) = (l/2)*ones(m, 1);
            Vz = [Vz; [ 0, 0, -l/2]; [ 0, 0, l/2] ]; 
    
            Fz = [];% CCW
            %side
            for i = 1:m
                f = [i, i+1, m+i;        % side
                     m+i, i+1, m+i+1;    % side
                     m+i, m+i+1, 2*m+2;  % cap
                     i, 2*m+1, i+1];     % bottom
                if i==m
                    f= [m, 1, m+m;
                        m+m, 1, m+1;
                        m+m, m+1, 2*m+2;
                        m, 2*m+1, 1];
                end
                Fz = [Fz; f ]; %#ok<AGROW>
            end
            
            Fz = robotics.core.internal.PrimitiveMeshGenerator.flipFace(Fz);

        end
        
        function [F, V] = sphereMesh(r)
            %sphereMesh Create mesh for a sphere shape. The origin is 
            %   at the center of the sphere. The input is the radius of the
            %   sphere.
            
            % using "normalized cube" approach
            % first, generating cube mesh
            
            n = 10;
            k = 0;
            V = [];
            F = [];
            % top
            for i = 1:n
                for j = 1:n
                    v = [-1+2*(i-1)/n,     -1+2*(j-1)/n,   1;
                         -1+2*(i-1)/n,     -1+2*(j)/n,     1;
                         -1+2*(i)/n,       -1+2*(j-1)/n,   1;
                         -1+2*(i)/n,       -1+2*(j)/n,     1];
                    f = [k+1, k+2, k+3;
                         k+3, k+2, k+4];
                    k = k+4;
                    V = [V;v];
                    F = [F; f];
                end
            end
            % bottom
            V2 = (axang2rotm([0 1 0 pi])* V')';
            % front
            V3 = (axang2rotm([0 1 0 pi/2])* V')';
            % back
            V4 = (axang2rotm([0 1 0 -pi/2])* V')';
            % left
            V5 = (axang2rotm([1 0 0 pi/2])* V')';
            % right
            V6 = (axang2rotm([1 0 0 -pi/2])* V')';
            
            % assemble cube
            V = [V;V2;V3;V4;V5;V6];
            F = [F; F+k; F+2*k; F+3*k; F+4*k; F+5*k];
            
            % combine vertices
            [V, ~, Ic]= unique(V, 'rows', 'stable');
            for i = 1:size(F, 1)
                F(i,:) = [Ic(F(i,1)), Ic(F(i,2)), Ic(F(i,3))];
            end
            
            % normalize to make sphere
            V = normalize(V, 2, 'norm') *r;
            
            F = robotics.core.internal.PrimitiveMeshGenerator.flipFace(F);
        end
        
        function Fo = flipFace(F) 
            %flipFace Flip between CW and CCW ordering
            Fo = [F(:,1), F(:,3), F(:,2)];
        end        
    end
end

