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
		dropdownlist ddl_shapeType "shapeType" items:#("Box", "Sphere", "Cylinder", "Capsule","Hull") enabled: false
		
		on params open do ddl_shapeType.selection = findItem ddl_shapeType.items shapeType
		on ddl_shapeType selected sel do shapeType = ddl_shapeType.selected
	)
)




