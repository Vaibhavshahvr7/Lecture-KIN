classdef TrustRegionIndefiniteDogLegSE3 < robotics.core.internal.TrustRegionIndefiniteDogLegInterface
    %This class is for internal use only. It may be removed in the future.
    
    %TRUSTREGIONINDEFINITEDOGLEGSE3
    
    %   Copyright 2017-2018 The MathWorks, Inc.
    
    %#codegen
    
    properties (Constant)
        TformBlockSize = [4 4]
        EpsilonBlockSize = [6 1]
    end
 
    properties (Dependent, SetAccess = protected)
        
        %Name Solver name
        Name
        
    end
    
    methods
        function obj = TrustRegionIndefiniteDogLegSE3()
            %TrustRegionIndefiniteDogLegSE3 Constructor
            obj.MaxTime = 500;
            obj.InitialTrustRegionRadius = 100;
            obj.FunctionTolerance = 1e-8;
            if coder.target('MATLAB')
                obj.SkipPDCheck = false;
            else
                obj.SkipPDCheck = true;
            end
        end
        
        function nm = get.Name(~)
            %get.Name
            nm = 'Trust-Region-Dogleg-SE3';
        end
        
    end
                   
    
    methods (Access = protected)
        function [x, xSol] = initializeInternal(obj)
           %initializeInternal
           
           x = obj.SeedInternal; % internal state
           xSol = robotics.core.internal.BlockMatrix(x, obj.TformBlockSize); % initialize solution
            
        end
        
        function xSol = updateSolution(obj, x)
            %updateSolution
            xSol = robotics.core.internal.BlockMatrix(x, obj.TformBlockSize);
        end
        
        function xNew = incrementX(obj, x, epsilons)
            %incrementX Update optimization variable x with incremental
            %   change epsilons
            %
            %   x - internal state with size 4n x 4
            %   epsilons - local step with size 6n x 1
            %   where n is the number of poses in x

            xBlk = robotics.core.internal.BlockMatrix(x, obj.TformBlockSize);
            n = xBlk.NumRowBlocks;
            m = xBlk.NumColBlocks;
            epsilonsBlk = robotics.core.internal.BlockMatrix(epsilons, obj.EpsilonBlockSize);
            xBlkNew = robotics.core.internal.BlockMatrix(n, m, obj.TformBlockSize);

            % Defining epsilonHat as variable sized matrix to fix
            % codegen issue with expm function on windows platform. expm
            % mexed execution outputput is very different from interpreted
            % execution when epsilonHat is expected to be 4x4 fixed size
            % matrix at compile time.
            coder.varsize('epsilonHat',[inf,inf],[1,1]);
            for i = 1:n
                pose = xBlk.extractBlock(i, 1);
                epsilon = epsilonsBlk.extractBlock(i,1);
                
                % here pose is an SE3 pose. 
                % epsilon is the increment in the Lie algebra of the SE3 
                % pose, represented as a vector
                epsilonHat = robotics.core.internal.SEHelpers.hatse3(epsilon(1:6,1));
                xBlkNew.replaceBlock(i, 1, pose*robotics.core.internal.SEHelpers.tforminvSE3(expm(epsilonHat)));
            end
            
            xNew = xBlkNew.Matrix(:,1:obj.TformBlockSize(1));
        end
        
        
        function defaultObj = getDefaultObject(~)
            %getDefaultObject
            defaultObj = robotics.core.internal.TrustRegionIndefiniteDogLegSE3;
        end        
        
        function [lambda, v] = eigSmallest(~, B)
            %eigSmallest Compute the smallest eigenvalue and the corresponding eigenvector for the Hessian matrix
            
            % eig can only calculate the eigenvalues of sparse matrices
            % that are real and symmetric, but not the eigenvectors.
             
            [v, lambda] = eigs(B, 1, 'sm');
        end       
    end
    

end
