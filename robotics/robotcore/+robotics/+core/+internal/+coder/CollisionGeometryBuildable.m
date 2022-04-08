classdef CollisionGeometryBuildable < coder.ExternalDependency
%This class is for internal use only. It may be removed in the future.

%CollisionGeometryBuildable Class implementing the collision checking and collision geometry methods that are compatible with code generation

% Copyright 2019 The MathWorks, Inc.

%#codegen

% Static methods supporting code generation for CollisionGeometry and checkCollision builtins

    methods(Static)
        function bname = getDescriptiveName(~)
            %getDescriptiveName A descriptive name for the external dependency
            bname = 'CollisionGeometryBuildable';
        end

        function isSupported = isSupportedContext(~)
            %isSupportedContext Determines if code generation is supported for both host and target
            % (portable) code generation.
            isSupported = true;
        end

        function updateBuildInfo(buildInfo, ~)
            %updateBuildInfo Add headers and sources to the build info

            % Workaround to ensure that c99 and c++11 are used as "std"
            % flags for GCC and MinGW compilers.
            % Remove this workaround once the enhancement g1898213 is submitted.

            buildInfo.addBuildArgs('NON_ANSI_TRIG_FCN', '1', 'BUILD_ARG');
            buildInfo.Settings.setCompilerRequirements('supportCPPThread', true);

            % Include directory of published headers
            apiIncludePaths = fullfile(matlabroot, 'extern', 'include',...
                                       'shared_robotics');

            % libccd root directory containing source and headers
            externalSourcePath = fullfile(matlabroot, 'toolbox', 'shared',...
                                          'robotics', 'externalDependency');


            % API source directory of published headers
            apiSourcePath = fullfile(matlabroot, 'toolbox', 'shared', ...
            'robotics', 'robotcore', 'builtins', 'libsrc', 'collisioncodegen');

            % libccd source directory
            ccdSrcPath = fullfile(externalSourcePath, 'libccd', 'src');
            ccdIncludePath = fullfile(ccdSrcPath, 'ccd');
            buildInfo.addIncludePaths({apiIncludePaths, ccdSrcPath, ccdIncludePath});

            buildInfo.addSourcePaths({ccdSrcPath, apiSourcePath});
            %.c files located under src/ccd
            buildInfo.addDefines('ccd_EXPORTS');
            ccdCFiles = dir([ccdSrcPath, '/*.c']);

            %.h files located under src/ccd
            ccdHFiles = dir([ccdSrcPath, '/*.h']);

            %.h files located under src/ccd/include
            ccdIncludeFiles = dir([ccdIncludePath, '/*.h']);

            %.cpp files located under libsrc/collisioncodegen/
            apiCFiles = dir([apiSourcePath, '/*.cpp']);

            %.cpp files located under $MATLABROOT/extern/include
            apiHFiles = dir([apiIncludePaths, '/*.hpp']);

            sourceFiles = [ccdCFiles; apiCFiles];
            includeFiles = [ccdHFiles; ccdIncludeFiles; apiHFiles];

            arrayfun(@(s)buildInfo.addSourceFiles(s.name), sourceFiles, 'UniformOutput', false);
            arrayfun(@(s)buildInfo.addIncludeFiles(s.name), includeFiles, 'UniformOutput', false);

        end

        function geometryInternal = makeBox(x, y, z)
            %makeBox Codegen-compatible version of robotics.core.internal.CollisionGeometryBase with three inputs
            geometryInternal = robotics.core.internal.coder.CollisionGeometryBuildable.initializeGeometry();
            coder.cinclude('collisioncodegen_api.hpp');
            geometryInternal = coder.ceval('collisioncodegen_makeBox', x, y, z);
        end

        function geometryInternal = makeSphere(r)
            %makeSphere Codegen-compatible version of robotics.core.internal.CollisionGeometryBase with one input
            geometryInternal = robotics.core.internal.coder.CollisionGeometryBuildable.initializeGeometry();
            coder.cinclude('collisioncodegen_api.hpp');
            geometryInternal = coder.ceval('collisioncodegen_makeSphere', r);
        end

        function geometryInternal = makeCylinder(r, h)
            %makeCylinder Codegen-compatible version of robotics.core.internal.CollisionGeometryBase with two inputs
            geometryInternal = robotics.core.internal.coder.CollisionGeometryBuildable.initializeGeometry();
            coder.cinclude('collisioncodegen_api.hpp');
            geometryInternal = coder.ceval('collisioncodegen_makeCylinder', r, h);
        end

        function geometryInternal = makeMesh(vertices, numVertices)
            %makeMesh Codegen-compatible version of robotics.core.internal.CollisionGeometryBase with two inputs
            geometryInternal = robotics.core.internal.coder.CollisionGeometryBuildable.initializeGeometry();
            coder.cinclude('collisioncodegen_api.hpp');
            geometryInternal = coder.ceval('collisioncodegen_makeMesh', vertices, numVertices);
        end

        function [collisionStatus, separationDist, witnessPts] = ...
                        checkCollision(geometryInternal1, position1, quaternion1, ...
                                       geometryInternal2, position2, quaternion2, ...
                                       needMoreInfo)

            %checkCollision Codegen-compatible version of checkCollision with two inputs

            collisionStatus = 0;
            separationDist = 0;
            p1Vec = zeros(3, 1);
            p2Vec = zeros(3, 1);
            coder.cinclude('collisioncodegen_api.hpp');
            collisionStatus = coder.ceval('collisioncodegen_intersect',...
                            geometryInternal1, position1, quaternion1, ...
                            geometryInternal2, position2, quaternion2, ...
                            needMoreInfo, ...
                            coder.ref(p1Vec), coder.ref(p2Vec), ...
                            coder.ref(separationDist));
            witnessPts = [p1Vec, p2Vec];
        end

        function geometryInternal = initializeGeometry()
            %initializeGeometry Internal helper function which declares the type of GeometryInternal.
            geometryInternal = coder.opaque('void*', 'NULL');
        end
    end
end
