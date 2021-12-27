
cust_attrib = attributes "Custom Attributes"
(
	parameters main rollout:params (
		hkTypeRigidBody type:#string default:"hkRigidBody"
		mass type:#float ui:sp_mass default:0.0
		friction type:#float ui:sp_friction default:0.5
		restitution type:#float ui:sp_restitution default:0.0
		hkTypeShape type:#string default:"hkShape"
		shapeType type:#string default:"Box"
	)

	rollout params "Custom Attributes" (

		spinner sp_mass "mass"
		spinner sp_friction "friction"
		spinner sp_restitution "restitution"
		
		dropdownlist ddl_shapeType "shapeType" items:#("Box", "Sphere", "Cylinder", "Capsule", "Mesh") enabled: true

		on params open do (
			ddl_shapeType.selection = findItem ddl_shapeType.items shapeType
		)
		
		on ddl_shapeType selected sel do (
			shapeType = ddl_shapeType.selected
		)
	)
)


		

-- 'CONVEX_HULL': 'Hull',
 --   'BOX': 'Box',
  --  'SPHERE': 'Sphere',
  --  'CYLINDER': 'Cylinder',
  --  'CAPSULE': 'Capsule',
 --   'MESH': 'Mesh',
  --  'CONE': 'Hull',



for obj in selection do ( 
 	test = obj.name
 	custAttributes.delete  obj 1
 	print(obj.name)
	em  = emptyModifier() 
	em.name = "Havok - RigidBody"
	addModifier obj  em
	CustAttributes.add em cust_attrib #unique 
--  	test = obj.name
 --	obj.highlight= test
--  	old_def = custAttributes.getDef obj 1
--  	old_def_data = custAttributes.getDefData old_def -- get my defData from it
--  	print(custAttributes.getPBlockDefs old_def)
	)
