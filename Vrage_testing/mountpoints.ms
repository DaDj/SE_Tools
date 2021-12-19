clearListener()
-- OFFSETS ---
-- width:  +1.25m * Blockwidth
-- height:  +1.25m *Blocklength

size_small = 0.5
size_big = 2.5
global	Blockheight_cb = 1
global	Blockwidth_cb =  1
global 	Blocklength_cb =  1
Export_Mountplane = selection
Size_block = size_big
obj = getnodebyname "Boundbox_Large"
obj2 = getnodebyname "Boundbox_Small"

if obj != undefined then( 
	Blockheight_cb = obj.height/2.5
	Blockwidth_cb =  obj.width/2.5
	Blocklength_cb =  obj.length/2.5
	Size_block = size_big
	print("Big Block")
	)
else if obj2 != undefined then ( 
	Blockheight_cb = obj2.height/size_small
	Blockwidth_cb =  obj2.width/size_small
	Blocklength_cb =  obj2.length/size_small
	Size_block = size_small
	print("Small Block")
	)
else  ( 
	print("NO Boundingbox !! Size is set to LARGE 1x1x1 ")
Blockheight_cb = 1
Blockwidth_cb =  1
Blocklength_cb =  1
Size_block = size_big
	)

-- print("Blockheight")
-- print(Blockheight_cb )
-- print("Blockwidth")
-- print(Blockwidth_cb )
-- print("Blocklength")
-- print(Blocklength_cb )

--##############################################
---GET VERTEX COORDINATES----
	fn getVertexPositions obj = (
	local vPositions = #()
	local triMesh = snapshotAsMesh obj
	for v = 1 to triMesh.numVerts do (
		append vPositions (getVert triMesh v)
	)
	delete triMesh
	print(vPositions)
	return vPositions
)
--rounds a float to a set number of decimal places
function roundFloat val dp = (

	---a = val * (10^dp)
-- b = a as integer
-- a = b as float / (10^dp)
-- 
return 	floor(((pow 10 dp) * val))/(pow 10 dp)
)

temp = Size_block/2
Blockheight = Blockheight_cb*temp 
Blockwidth =  Blockwidth_cb*temp 
Blocklength =  Blocklength_cb *temp 

--##############################################
length_temp = Blocklength_cb as integer
height_temp = Blockheight_cb as integer 
width_temp = Blockwidth_cb as integer
format("<Size x=\"")
format(width_temp as string )	
format(" \" y=\"")	
format(height_temp as string)	
format("\" z=\"")	
format(length_temp  as string)
format("\" />\n")

format("<MountPoints> \n")
if expo_selected == undefined then (expo_selected = false)
	
if expo_selected == true then (Export_Mountplane = selection 	)
	else( Export_Mountplane = objects )
	
for i in Export_Mountplane do
(
	PLANE_Name = i.name
	
	planepos_left= "Mountpoint_left"
	planepos_right= "Mountpoint_right"
	testleft =findstring PLANE_Name  planepos_left 
	testright = findstring PLANE_Name planepos_right 
	if testleft == undefined do	(testleft = 0)
	if testright == undefined do	(testright = 0)
	
	planepos_front= "Mountpoint_Front"
	planepos_back= "Mountpoint_back"
	testfront =findstring PLANE_Name  planepos_front
	testback = findstring PLANE_Name	planepos_back
	if testfront == undefined do	(testfront = 0)
	if testback == undefined do	(testback = 0)
	
	planepos_top= "Mountpoint_top"
	planepos_bottom= "Mountpoint_bottom"
	testtop =findstring PLANE_Name  planepos_top
	testbottom = findstring PLANE_Name	planepos_bottom
	if testtop == undefined do	(testtop= 0)
	if testbottom == undefined do	(testbottom= 0)
	
	

	minx= i.min.x +Blockwidth -- get min and max x positions
	maxx = i.max.x + Blockwidth
	minZ = i.min.z + Blockheight -- get min and max Z positions
	maxZ = i.max.z + Blockheight
	miny= i.min.y +Blocklength -- get min and max y positions
	maxy = i.max.y + Blocklength
-- 	print(minZ)
-- 	print(maxZ)
-- 	print(miny)
-- 	print(maxy)
	
		if 	round_1digit == true then (
	minx=( roundFloat  minx 1  )/Size_block
	maxx=( roundFloat  maxx  1 )/Size_block
	minz = (roundFloat  minz 1 )/Size_block
	maxz=( roundFloat  maxz  1 )/Size_block
	miny =( roundFloat  miny 1 )/Size_block
	maxy=( roundFloat  maxy 1 )/Size_block
		)
	else( 
	minx=( roundFloat  minx 2  )/Size_block
	maxx=( roundFloat  maxx  2 )/Size_block
	minz = (roundFloat  minz 2 )/Size_block
	maxz=( roundFloat  maxz  2 )/Size_block
	miny =( roundFloat  miny 2 )/Size_block
	maxy=( roundFloat  maxy 2 )/Size_block
		)
	

			

	if   testleft >= 1  do
	(
		--coord system has to be switched for the left side.
		-- STARTX = 1- MAXY 
		startx = Blocklength_cb - maxy
		startx =  startx as string
		-- ENDX= 1 - SMINX
		endx  = Blocklength_cb - miny
		endx = endx as string
		
		starty =  minz as string
		endy = maxz as string
		format("<MountPoint Side=\"" +  "Left" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
	
		if   testright >= 1 do
	(
		startx =  miny as string
		endx = maxy as string
		
		starty =  minz as string
		endy = maxz as string
		format("<MountPoint Side=\"" +  "Right" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
	
	
	
		if   testfront >= 1  do
	(
		--coord system has to be switched for the front side.
		-- STARTX = 1- MAXY 
		startx = Blockwidth_cb - maxx
		startx =  startx as string
		-- ENDX= 1 - SMINX
		endx  = Blockwidth_cb - minx
		endx = endx as string
		
		starty =  minz as string
		endy = maxz as string
		format("<MountPoint Side=\"" +  "Front" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
	
		if   testback >= 1 do
	(
		startx =  minx as string
		endx = maxx as string
		
		starty =  minz as string
		endy = maxz as string
		format("<MountPoint Side=\"" +  "Back" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
	
	
			if   testbottom >= 1  do
	(
		--coord system has to be switched for the bottom side.
		-- STARTX = 1- MAXY 
		--startx = Blockwidth_cb - maxx
		--startx =  startx as string
		-- ENDX= 1 - SMINX
		--endx  = Blockwidth_cb - minx
		--endx = endx as string
		startx =  minx as string
		endx = maxx as string
		
				--coord system has to be switched for the left side.
		-- STARTX = 1- MAXY 
		starty = Blocklength_cb - maxy
		starty =  starty as string
		-- ENDX= 1 - SMINX
		endy  = Blocklength_cb - miny
		endy = endy as string
		format("<MountPoint Side=\"" +  "Bottom" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
	
		if   testtop >= 1 do
	(
		startx =  minx as string
		endx = maxx as string
		
		starty =  miny as string
		endy = maxy as string
		format("<MountPoint Side=\"" +  "Top" +  "\" StartX=\"" + startx  +  "\" StartY=\"" + starty + "\" EndX=\""  +  endx  + "\" EndY=\"" + endy + "\" />" + "\n")  
	)
)
format("</MountPoints> \n")
	
	