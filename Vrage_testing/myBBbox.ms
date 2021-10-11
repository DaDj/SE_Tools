selection.max
selection.min
selection.center

MyObj = Box  length:1 width:1 height: 1
custAttributes.add MyObj RigidBodyCA
MyObj.shapeType = "Box"

MyObj.length =  (abs(selection.max.y)+abs(selection.min.y))
MyObj.width =  (abs(selection.max.x)+abs(selection.min.x))
MyObj.height = (abs(selection.max.z)+abs(selection.min.z))
	
MyObj.pivot = MyObj.center
MyObj.position = selection.center