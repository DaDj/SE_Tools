
fn recursivechildnames CurrentNode Mystring2=
(
	Mystring = Mystring2 +  "	"
	local childNodes = CurrentNode.ChildNodes
	for i = 0 to childNodes.count-1 do (
		child_name = childNodes.item[i].name
		child_value = childNodes.item[i].value
		child_type = childNodes.item[i].GetType() 
		child_attr  = childNodes.item[i].Attributes

		
		format Mystring 
		format "%: %            %\n" child_name child_value child_type
		

		if child_attr != undefined do (
			for i2 = 0 to child_attr.count-1 do
			(
				format Mystring 
				format "%  % \n"	child_attr.ItemOf[i2].name child_attr.ItemOf[i2].value
			)
		)
		
		if childNodes.item[i].ChildNodes.count > 0 do
		(			
			recursivechildnames childNodes.item[i] Mystring
		)
	)
)

fn GetCubeBlocks CurrentNode = 
(	local childNodes = CurrentNode.selectNodes "CubeBlocks//Definition" 

	for i = 0 to childNodes.count-1 do 
	(
		child_name = childNodes.item[i].name
		child_value = childNodes.item[i].value
		--child_type = childNodes.item[i].GetType() 
		child_attr  = childNodes.item[i].Attributes
		local TypeId = childNodes.item[i].selectNodes "Id//TypeId" 

	
		print TypeId.item[0].innertext
		--Mountpoints = childNodes.item[i].selectNodes "//MountPoints" 
		--recursivechildnames Mountpoints.item[0] ""
	
	--	format "%: %            \n" child_name child_value --child_type
	)
	childNodes
)

fn create_XML Path TheBlockNode = 
(
	xmlDoc = dotNetObject "system.xml.xmlDocument"

	/* create header */
	header = xmlDoc.CreateXmlDeclaration "1.0" "" ""
	xmlDoc.AppendChild header

	/*Add Definitions */
	root = xmlDoc.createElement "Definitions"
	xmlDoc.appendChild root

	/*Add the selectd block */
	
	newref = xmlDoc.createElement "CubeBlocks"
	root.appendChild newref

	newBook = xmlDoc.ImportNode TheBlockNode True  -- import and
	newref.appendChild newBook -- add it 
	--xmlDoc.save Path
	xmlDoc
)

clearListener()
filename = @"C:\Program Files (x86)\Steam\steamapps\common\SpaceEngineers\Content\Data\CubeBlocks\CubeBlocks_Control.sbc"
xmlDoc = dotNetObject "system.xml.xmlDocument"
xmlDoc.load filename
------------------------------------------------------------------------------------------------- read document
-- 	--Check to make sure the xmlDoc has a root element. 
docEle=xmlDoc.documentElement
--format "Element Name: %\n\n" docEle.name
thing = GetCubeBlocks docEle
theDoc = create_XML @"C:\Users\patgr\Desktop\xml.xml" thing.item[3]

TestString = theDoc.innerxml
print TestString
TheNewDoc = dotNetObject "system.xml.xmlDocument"
TheNewDoc.innerxml = TestString
TheNewDoc.save @"C:\Users\patgr\Desktop\xml.xml"
print TheNewDoc
--recursivechildnames docEle ""


