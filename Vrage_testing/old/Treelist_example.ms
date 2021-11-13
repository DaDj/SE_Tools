rollout tltest "XtraTreeList Test" width: 500 height: 500
(
    dotNetControl tl "DevExpress.XtraTreeList.TreeList" width: 450 height: 450
    
    on tltest open do
    (
        -- Set up the treelist 
        
        tl.OptionsSelection.MultiSelect = false
        tl.OptionsView.ShowRoot =true
        tl.OptionsView.ShowIndicator = false
        tl.OptionsView.AutoWidth = true
        tl.BeginUpdate();
 
        tl.Appearance.EvenRow.BackColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)
        tl.Appearance.OddRow.BackColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)
        tl.Appearance.EvenRow.ForeColor =  MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
        tl.Appearance.OddRow.ForeColor =  MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
        tl.Appearance.Empty.ForeColor  = MXSColor_to_dotNetColor (((colorman.getColor #text  )*255) as color)
        tl.Appearance.FocusedRow.BackColor = MXSColor_to_dotNetColor (((colorman.getColor #itemHilight    )*255) as color)
    tl.Appearance.Empty.BackColor = MXSColor_to_dotNetColor (((colorman.getColor #window)*255) as color)
        tl.OptionsView.EnableAppearanceEvenRow = true;
        tl.OptionsView.EnableAppearanceOddRow = true;
        
       
        -- Fixed the first column to the left. this is the column that contains the indented tree nodes
        col = tl.Columns.Add()
        col.visible = true
        tl.Columns.item[0].Fixed = tl.Columns.item[0].Fixed.Left
        tl.RowHeight = 50
 
        -- Set up the 2nd column with a combo box editor
        col = tl.Columns.Add()
        col.visible = true
        riCombo = dotnetobject "DevExpress.XtraEditors.Repository.RepositoryItemComboBox"
        riCombo.Items.AddRange #("lantern", "angel", "hat", "dog"  )
        tl.RepositoryItems.Add riCombo
        col.ColumnEdit =  riCombo  
        
        -- Set up the 3rd column with a spin editor
        col = tl.Columns.Add()
        col.visible = true
        riSpin = dotnetobject "DevExpress.XtraEditors.Repository.RepositoryItemSpinEdit"
        tl.RepositoryItems.Add riSpin
        col.ColumnEdit =  riSpin
    
        col = tl.Columns.Add()
        col.visible = true
        
        -- The 3 columns fixed to the right are all checkboxes
        riCheck = dotnetobject "DevExpress.XtraEditors.Repository.RepositoryItemCheckEdit"
        tl.RepositoryItems.Add riCheck
        for  i = 2 to 0 by -1 do 
        (
            col = tl.Columns.Add()
            col.visible = true
            col.caption =  (i as string)
            col.ColumnEdit =  riCheck
            col.Width = 5
            col.Fixed = col.Fixed.Right
        )
        
        tl.EndUpdate()
           
        tl.BeginUnboundLoad()

        -- Four root level nodes 
        n0 = tl.AppendNode #("green","lantern" ,0, "dog", false, true, false)  -1
        n1 = tl.AppendNode #("blue", "angel"	,1, "rat", false, true, true)  -1
        n2 = tl.AppendNode #("blue", "moon"	,2 , "hawk", false, true, true)  -1
        n3 = tl.AppendNode #("blue", "mood"	,1, "horse", false, true, true)  -1
        
        -- Four child nodes
        n00 = tl.AppendNode #("red", "hat"		,5, "turtle",false, false, true) n0		
        n10 = tl.AppendNode #("yellow", "dog"	,3, "gull", true, false, true) n1		
        n20 = tl.AppendNode #("red", "menace"   ,6, "fish",false, false, true) n2		
        n30 = tl.AppendNode #("yellow", "streak"	,4, "rock", true, false, true) n3		
        tl.EndUnboundLoad()
        
    )
        
)

createdialog tltest