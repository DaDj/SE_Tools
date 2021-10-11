collisionWirecolor = color 50 210 250

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

    rollout params "hkRigidBody" 
    (
        spinner sp_mass "mass"
        spinner sp_friction "friction"
		spinner sp_restitution "restitution"
		
		-- dropdownlist ddl_shapeType "shapeType" items:#("Box", "Sphere", "Cylinder", "Capsule","Hull") enabled: false
		
		-- on params open do ddl_shapeType.selection = findItem ddl_shapeType.items shapeType
		-- on ddl_shapeType selected sel do shapeType = ddl_shapeType.selected
    )
)

plugin geometry VrageHavokBox 
name:"Box"
classID:#(0x3fbdad54, 0x1bdbbb95)	
category:"Vrage: Physics Rigidbodies"
extends:Box
(
	local initialPos = [0,0,0]
	local selfnode
	
	tool create (
		
		on start do (
			
			selfnode = (refs.dependentnodes this)[1]

			if selfnode != undefined do (				
				selfnode.castShadows = off
				selfnode.backfacecull = off
				selfnode.receiveshadows = off
				at time 0 (selfnode.visibility = 0 )
				(addNewKey selfnode.visibility.controller 30).value = 0.3
				custAttributes.add selfnode RigidBodyCA
				selfnode.wirecolor = collisionWirecolor
			)
			
		)
		
		on mousePoint click do (
			case click of (
				1: (
					nodeTM = matrix3 [1,0,0] [0,1,0] [0,0,1] gridPoint
					initialPos = gridPoint
				)
				3: (#stop
					resetxform selfnode
				)
			)
		)
		
		on mouseMove click do (
			case click of (
				2: (
					delegate.width = abs(gridDist.x)
					delegate.length = abs(gridDist.y)
					nodeTM.translation = initialPos + [gridDist.x, gridDist.y, 0]/2
				)
				3: (
					delegate.height = gridDist.z
				)
			)
		)
	)
)




plugin geometry VrageHavokSphere 
name:"Sphere"
classID:#(0x69a5a6ba, 0x6c24fa67)
category:"Vrage: Physics Rigidbodies"
extends:Sphere
(
	local initialPos = [0,0,0]
	local selfnode
	
	tool create (
		
		on start do (
			
			selfnode = (refs.dependentnodes this)[1]

			if selfnode != undefined do (				
				selfnode.castShadows = off
				selfnode.backfacecull = off
				selfnode.receiveshadows = off
				at time 0 (selfnode.visibility = 0 )
				(addNewKey selfnode.visibility.controller 30).value = 0.3
				custAttributes.add selfnode RigidBodyCA
				selfnode.shapeType = "Sphere"
				selfnode.wirecolor = collisionWirecolor
			)
			
		)
		
		on mousePoint click do (
			case click of (
				1: (
					nodeTM = matrix3 [1,0,0] [0,1,0] [0,0,1] gridPoint
					initialPos = gridPoint
				)
				2: (#stop
					resetxform selfnode
				)
			)
		)
		
		on mouseMove click do (
			case click of (
				2: (
					delegate.radius = amax #(abs(gridDist.x), abs(gridDist.y))
					)
			)
		)
	)
)



plugin geometry VrageHavokCylinder
name:"Cylinder"
classID:#(0x6c912bfa, 0x3bafd0ab)
category:"Vrage: Physics Rigidbodies"
extends:Cylinder
(
	local initialPos = [0,0,0]
	local selfnode
	
	tool create (
		
		on start do (
			
			selfnode = (refs.dependentnodes this)[1]

			if selfnode != undefined do (				
				selfnode.castShadows = off
				selfnode.backfacecull = off
				selfnode.receiveshadows = off
				at time 0 (selfnode.visibility = 0 )
				(addNewKey selfnode.visibility.controller 30).value = 0.3
				custAttributes.add selfnode RigidBodyCA
				selfnode.shapeType = "Cylinder"
				selfnode.wirecolor = collisionWirecolor
			)
			
		)
		
		on mousePoint click do (
			case click of (
				1: (
					nodeTM = matrix3 [1,0,0] [0,1,0] [0,0,1] gridPoint
					initialPos = gridPoint
				)
				3: (#stop
					resetxform selfnode
				)
			)
		)
		
		on mouseMove click do (
			case click of (
				2: (
					delegate.radius = amax #(abs(gridDist.x), abs(gridDist.y))
				)
				3: (
					delegate.height = gridDist.z
				)
			)
		)
	)
)




fn CreateRigidBodyObject type  FittoObj = 
(

	if FittoObj == false then (
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
		else if type == "Hull" then 
		(
			MyObj = Box length:1 width:1 height: 1
			---MyObj = plane	length:1 width:1
			MyObj.name = "RigidMesh" 
			custAttributes.add MyObj RigidBodyCA
			MyObj.shapeType = "Hull"
			MyObj.wirecolor = collisionWirecolor
			MyObj.castShadows = off
			MyObj.backfacecull = off
			MyObj.receiveshadows = off
			at time 0 (MyObj.visibility = 0 )
			(addNewKey MyObj.visibility.controller 30).value = 0.3
			convertToMesh MyObj
		)
	)
	else (
			if  selection.count == 0 do return 0
			y =  ((selection.max.y)-(selection.min.y))
			x =  ((selection.max.x)-(selection.min.x))
			z = ((selection.max.z)-(selection.min.z))
		if type == "Box" then 
		(
			MyObj = Box length:1 width:1 height: 1
			custAttributes.add MyObj RigidBodyCA
			---MyObj.shapeType = "Box"
			MyObj.length = y
			MyObj.width =  x
			MyObj.height = z
			MyObj.pivot = MyObj.center
			MyObj.position = selection.center
		)
		else if type == "Sphere" then 
		(
			MyObj = Sphere radius:1
			custAttributes.add MyObj RigidBodyCA
			MyObj.shapeType = "Sphere"
			MyObj.radius = amax #(x,y,z) /2
			MyObj.pivot = MyObj.center
			MyObj.position = selection.center
		)
		else if type == "Cylinder" then 
		(
			MyObj = Cylinder height:1 radius:1
			custAttributes.add MyObj RigidBodyCA
			MyObj.shapeType = "Cylinder"

			if queryBox "Do you want to use the longest distance as height instead of radius?" beep:false then
			(
				MyObj.height =  z
				MyObj.radius = amax #(x,y) /2

				if x > z and x > y do (
					MyObj.rotation = eulerAngles 0 90 0
					MyObj.height =  x
					MyObj.radius = amax #(z,y) /2
					print "1"
				) 
				if y > x and y > z do (
					MyObj.rotation = eulerAngles 90 0 0
					MyObj.height =  y
					MyObj.radius = amax #(z,x) /2			
				) 		
				MyObj.pivot = MyObj.center
				MyObj.position = selection.center
			)
			else (
					if z > x and z > y then (
						if y > x then (
							MyObj.height =   x
							MyObj.rotation = eulerAngles 0 90 0
						)
						else (
							MyObj.height =   y
							MyObj.rotation = eulerAngles 90 0 0
						)
						MyObj.radius = z /2
					) 
					else if x > z and x > y then (
						if y > z then (
							MyObj.height =   z
							MyObj.rotation = eulerAngles 0 0 0
						)
						else (
							MyObj.height =   y
							MyObj.rotation = eulerAngles 90 0 0
						)
						MyObj.radius = x /2
					) 

				else if y > x and y > z do (
						if x > z then (
							MyObj.height =   z
							MyObj.rotation = eulerAngles 0 0 0
						)
						else (
							MyObj.height =   x
							MyObj.rotation = eulerAngles 0 90 0
						)
						MyObj.radius =  y /2		
					) 	
					MyObj.pivot = MyObj.center
					MyObj.position = selection.center
			)
		
	

			
		)
		else if type == "Hull" then (
			return -1
		)
		MyObj.wirecolor = collisionWirecolor
		MyObj.castShadows = off
		MyObj.backfacecull = off
		MyObj.receiveshadows = off
		at time 0 (MyObj.visibility = 0 )
		(addNewKey MyObj.visibility.controller 30).value = 0.3
	)

)



try (unRegisterRedrawViewsCallback showObjectNames) catch()
fn showObjectNames=
(
gw.setTransform(Matrix3 1)
for o in objects where not o.isHidden do
(

	if isProperty o #hkTypeRigidBody  then ( 		gw.text o.pos ("Physics -RB") color:yellow)
)
gw.enlargeUpdateRect #whole
gw.updateScreen()
)
registerRedrawViewsCallback showObjectNames
showObjectNames()
