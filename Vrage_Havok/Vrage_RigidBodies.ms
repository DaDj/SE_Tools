RigidBodyCA = attributes "RigidBody"
(
	parameters main rollout:params 
	(
		hkTypeRigidBody type:#string default:"hkRigidBody"
		mass type:#float ui:sp_mass default:0.0
		friction type:#float ui:sp_friction default:0.5
		restitution type:#float ui:sp_restitution default:0.0
		hkTypeShape type:#string default:"hkShape"
		shapeType type:#string default:"Box"
	)

	rollout params "Custom Attributes" 
	(
		spinner sp_mass "mass"
		spinner sp_friction "friction"
		spinner sp_restitution "restitution"
		dropdownlist ddl_shapeType "shapeType" items:#("Box", "Sphere", "Cylinder", "Capsule", "Mesh") enabled: false
		
		on params open do ddl_shapeType.selection = findItem ddl_shapeType.items shapeType
		on ddl_shapeType selected sel do shapeType = ddl_shapeType.selected
	)
)




fn CreateRigidBodyObject type  FittoObj = 
(
	if type == "Box" then 
	(
		 startObjectCreation VrageHavokBox 
	)
	else if type == "Sphere" then 
	(
		 startObjectCreation VrageHavokSphere 
	)
	else if type == "Cylinder" then 
	(
		startObjectCreation VrageHavokCylinder
	)
	else if type == "Mesh" then 
	(
		MyObj = Box length:1 width:1 height: 1
		---MyObj = plane	length:1 width:1
		MyObj.name = "RigidMesh" 
		)

)