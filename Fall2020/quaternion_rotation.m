
function Q_rotation= quaternion_rotation(Q)

quat = quaternion([0,0,180],'eulerd','XYZ','point');
Q= compact(Q);
v=(Q(:,2:4));
Scal=(Q(:,1));
V=rotateframe(quat, v);
V2=[Scal,V];
Q_rotation = quaternion(V2);