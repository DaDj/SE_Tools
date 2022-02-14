struct VrageSubpartTypes
(
	GUIName = "",
	Name = "",
	Description = ""
)



/***************SubpartDummies****************/

VrageSubpartDef = attributes "VrageSubpartDummy"
(-- File is the customattribute with the filename of the subpart
	parameters main rollout:params
	(
		file type:#string ui:file default: ""
	)
	rollout params "Custom Attributes"
	(
		EditText file "" 
	)
)

-- Add a subpartdummy 
fn VrageDummy_SubpartAdd DummyName File Layer = 
(
	TheDummy = dummy() ;
	TheDummy.Boxsize = [1,1,1]
	TheDummy.name = DummyName;	
	CustAttributes.add TheDummy VrageSubpartDef #unique
	TheDummy.file = File
	Layer.addnode TheDummy
	TheDummy
)


/***************GenericDummies****************/



/***************HighlightDummies****************/
VrageHighlightDef = attributes "VrageHighlightDummy"
(-- Highlights are the nam,es of the objects which will be highlighted
	parameters main rollout:params
	(
		highlight type:#string ui:highlight default: ""
	)
	rollout params "Custom Attributes"
	(
		EditText highlight "highlight" 
	)
)

-- Add a Highlightdummy 
fn VrageDummyHighlightAdd DummyName Objs Layer = 
(
	
)
