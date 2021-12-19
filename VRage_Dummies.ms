struct VrageSubpartTypes
(
	GUIName = "",
	Name = "",
	Description = ""
)



/***************SubpartDummies****************/
VrageSubpartDef = attributes "VrageSubpartDummy"
(
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
-- File is the customattribute with the filename of the subpart
fn VrageDummySubpartAdd DummyName File Layer = 
(

)


/***************GenericDummies****************/



/***************HighlightDummies****************/
VrageHighlightDef = attributes "VrageHighlightDummy"
(
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
