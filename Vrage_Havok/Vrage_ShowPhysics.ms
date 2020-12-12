--unRegisterRedrawViewsCallback showObjectNames
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