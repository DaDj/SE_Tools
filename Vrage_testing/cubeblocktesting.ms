
 fn recursivechildnames CurrentNode Mystring2=
(
	Mystring = Mystring2 +  "	"
	 local childNodes = CurrentNode.ChildNodes
	for i = 0 to childNodes.count-1 do (
		child_name = childNodes.item[i].name
		child_value = childNodes.item[i].value
		
		child_attr  = childNodes.item[i].Attributes
		
		format "%: %\n" child_name child_value 
		
		if child_attr != undefined do (
		for i2 = 0 to child_attr.count-1 do
			(
			format Mystring 
			format "	%  % \n"	child_attr.ItemOf[i2].name child_attr.ItemOf[i2].value
			)
		)
			
		if childNodes.item[i].ChildNodes.count > 0 do
		(			
			recursivechildnames childNodes.item[i] Mystring
		)
	)
)
--Anzahl der gefunden Child Nodes erfragen
format "\nAnzahl der Kinder: %\n" (num_children = childNodes.count)

--Namen der Child Nodes abfragen
for i = 0 to num_children-1 do (
    child_name = childNodes.item[i].getAttribute "xsi:type"
    format "%: %\n" i child_name
)
 
 filename = "C:\\Users\\patgr\\Desktop\\testblock.xml"
 	clearListener()
xmlDoc = dotNetObject "system.xml.xmlDocument"
 xmlDoc.load filename
------------------------------------------------------------------------------------------------- read document
-- 	--Check to make sure the xmlDoc has a root element. 
 	docEle=xmlDoc.documentElement
 	format "Element Name: %\n\n" docEle.name
	
childNodes = docEle.ChildNodes
--Anzahl der gefunden Child Nodes erfragen
format "\nAnzahl der Kinder: %\n" (num_children = childNodes.count)

--Namen der Child Nodes abfragen
for i = 0 to num_children-1 do (
    child_name = childNodes.item[i].getAttribute "xsi:type"
    format "%: %\n" i child_name
	 recursivechildnames childNodes.item[i] "	"
)