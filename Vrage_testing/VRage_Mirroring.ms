


MyMirroring = Dictionary  #("None", #(0.0, 0.0, 0.0))
PutDictValue MyMirroring "X" #(180.0, 0.0, 0.0)
PutDictValue MyMirroring "Y" #(0.0, 0.0, 180.0)
PutDictValue MyMirroring "Z" #(0.0, 180.0, 0.0)
for ele in MyMirroring do print ele
	
GhostingManager.ShowGhosting  = true
GhostingManager.GhostType = 2
GhostingManager.DisplayGhostInWireframe = false
GhostingManager.TotalGhostFrames = 3
obj = $Box001
print obj

curRot = eulerangles 0 0 0
tkey = addnewkey obj.position.X_position.controller 0
tkey.value = units.decodeValue "0cm"  


tkey = addnewkey obj.rotation.X_rotation.controller 0
tkey.value = curRot.x

tkey = addnewkey obj.rotation.Y_rotation.controller 0
tkey.value = curRot.Y

tkey = addnewkey obj.rotation.Z_rotation.controller 0
tkey.value = curRot.Z



-- Y PLANE
curRot = eulerangles 0.0 180.0 0.0
tkey = addnewkey obj.position.X_position.controller 1
tkey.value = units.decodeValue "0cm"  
tkey = addnewkey obj.position.Y_position.controller 1
tkey.value = units.decodeValue "0cm"  

tkey = addnewkey obj.rotation.X_rotation.controller 1
tkey.value = curRot.x

tkey = addnewkey obj.rotation.Y_rotation.controller 1
tkey.value = curRot.Y

tkey = addnewkey obj.rotation.Z_rotation.controller 1
tkey.value = curRot.Z


-- Z Plane
curRot = eulerangles 0.0 0 180.0
tkey = addnewkey obj.position.Y_position.controller 0
tkey.value = units.decodeValue "0cm"  
tkey = addnewkey obj.position.Y_position.controller 2
tkey.value = units.decodeValue "250cm"  

tkey = addnewkey obj.rotation.X_rotation.controller 2
tkey.value = curRot.x

tkey = addnewkey obj.rotation.Y_rotation.controller 2
tkey.value = curRot.Y

tkey = addnewkey obj.rotation.Z_rotation.controller 2
tkey.value = curRot.Z


--deleteKeys obj 