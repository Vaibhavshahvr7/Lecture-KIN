/* Copyright 2019 The MathWorks, Inc. */
#ifdef BUILDING_LIBMWCOLLISIONCODEGEN
#include "collisioncodegen/collisioncodegen_api.hpp"
#include "collisioncodegen/collisioncodegen_checkCollision_api.hpp"
#include "collisioncodegen/collisioncodegen_CollisionGeometry.hpp"
#else
#include "collisioncodegen_api.hpp"
#include "collisioncodegen_checkCollision_api.hpp"
#include "collisioncodegen_CollisionGeometry.hpp"
#endif

CollisionGeometryType collisioncodegen_makeBox(double x, double y, double z)
{
    return static_cast<void*>(new shared_robotics::CollisionGeometry(x, y, z));
}

CollisionGeometryType collisioncodegen_makeSphere(double r)
{
    return static_cast<void*>(new shared_robotics::CollisionGeometry(r));
}

CollisionGeometryType collisioncodegen_makeCylinder(double r, double h)
{
    return static_cast<void*>(new shared_robotics::CollisionGeometry(r, h));
}

CollisionGeometryType collisioncodegen_makeMesh(double *vertices, double numVertices) 
{
    return static_cast<void*>(new shared_robotics::CollisionGeometry(vertices, static_cast<int>(numVertices), true));
}

int collisioncodegen_intersect(CollisionGeometryType obj1,
                              double* pos1, 
                              double* quat1,
                              CollisionGeometryType obj2,
                              double* pos2, 
                              double* quat2,
                              double computeDistance,
                              double* p1Vec,
                              double* p2Vec,
                              double* distance)
{
    shared_robotics::updatePose(obj1, pos1, quat1);
    shared_robotics::updatePose(obj2, pos2, quat2);
    return shared_robotics::intersect(obj1, obj2, static_cast<int>(computeDistance), p1Vec, p2Vec, *distance);
}
