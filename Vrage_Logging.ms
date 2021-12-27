
Vrage_Logfile = MyVRageCfg.VRageConfigDir + "\\Info.log"
deletefile Vrage_Logfile
logsystem.logName Vrage_Logfile
logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0

global MyVrageGUI_LogFloater
global MyVRageMessageFloater
global MyVrageMessageArray = #()

rollout Rollout_VrageLog "VRage Utilies Log" width:900 height:500
(
	button btn_ClearLog "Clear Log" width:120 height:25 toolTip:"Clears the Logfile " align:#center across:3
	on btn_ClearLog pressed do
	(		
		deletefile Vrage_Logfile
		logsystem.logEntry "Start Logging" debug:1 info:0 warning:0 error:0
		--	VRageLog_Show()
	)	

	button btn_OpenLogFile "Open Log" width:120 height:25 toolTip:"Clears the Logfile " align:#center 
	on btn_OpenLogFile pressed do
	(		
		shellLaunch Vrage_Logfile ""
		--	VRageLog_Show()
	)	

	checkbox Chbx_AutoUpdate "AutoUpdate" checked:true



	dotNetControl textboxctrl "System.Windows.Forms.TextBox" width:850 height:450 align: #center
	
	timer clock "testClock" interval:1000 --tick  every 2 sec
	on clock tick do
	(
		if Chbx_AutoUpdate.state then
		(
			fs = openFile Vrage_Logfile
			textboxctrl.text  = "";
			while not eof fs do
			( 
				Theline = readline fs
				Tmp = filterstring Theline " "
				--MyNewHeader = Tmp[1] + " | " + Tmp[2]  + " | " + Tmp[3]      
				MyNewHeader =  Tmp[2]  + " | " + Tmp[3]      
				MyNewText = ""
				for i = 6 to Tmp.count do MyNewText = MyNewText + " " + Tmp[i] 
				--2020/11/28 22:25:35 WRN: [08532] [07356] What the  actual thing ist this  
				textboxctrl.text = textboxctrl.text +  MyNewHeader  +  MyNewText +"\r\n\r\n" 
			)
			close fs
			textboxctrl.SelectionStart = textboxctrl.Text.count;
			textboxctrl.ScrollToCaret();
		)
	)
	
	
	on Rollout_VrageLog open do
	(
		textboxctrl.AcceptsReturn = true;
		textboxctrl.AcceptsTab = true;
		textboxctrl.WordWrap = false;
		textboxctrl.Multiline = true;
		textboxctrl.ScrollBars = textboxctrl.ScrollBars.vertical;
	)
)

fn VRageLog_Show =
(
	try (closeRolloutFloater MyVrageGUI_LogFloater) catch () 
	MyVrageGUI_LogFloater = newRolloutFloater  "VRage Utilies Log" 900 520 
	addRollout Rollout_VrageLog MyVrageGUI_LogFloater
)

rollout MyVRageMessageFloaterMenu "Menu"
(
	button btnAClearmsg "Clear Messages" width:100 height:25 toolTip:"Apply new name" across:3
	on btnAClearmsg pressed do(
		try (cui.UnRegisterDialogBar MyVRageMessageFloater) catch () 	
		try (closeRolloutFloater MyVRageMessageFloater) catch ()
		Pos = getMaxWindowSize() 
		PosX = Pos[1] - 700
		PosY = Pos[2] - 450
		MyVRageMessageFloater = newRolloutFloater  "VRage Messages" 400 300 PosX PosY
		addrollout MyVRageMessageFloaterMenu MyVRageMessageFloater

		cui.RegisterDialogBar MyVRageMessageFloater style:#(#cui_floatable, #cui_dock_all)
		MyVrageMessageArray = #()
	)
	button btnAOpenlog "Open Log" width:100 height:25 toolTip:"Apply new name" 	
	on btnAOpenlog pressed do VRageLog_Show()
	button btnClearname "Clear Log" width:100 height:25 toolTip:"Apply new name" 	
	
	label description "Last 15 Vrage Messages - New to Old"
)

struct VrageLogMessage
(
	id = 0,
	Type = "Warning",
	Title = "Message Title",
	Message = "Message",
	Date = "",
	Critical = false	
)


struct VrageLogSys
(
	
	fn CreateMessageRollout =(
		try (cui.UnRegisterDialogBar MyVRageMessageFloater) catch () 	
		try (closeRolloutFloater MyVRageMessageFloater) catch ()
		
		Pos = getMaxWindowSize() 
		PosX = Pos[1] - 700
		PosY = Pos[2] - 450
		MyVRageMessageFloater = newRolloutFloater  "VRage Messages" 400 300 PosX PosY
		addrollout MyVRageMessageFloaterMenu MyVRageMessageFloater

		cui.RegisterDialogBar MyVRageMessageFloater style:#(#cui_floatable, #cui_dock_all)
		--	cui.DockDialogBar MyVRageMessageFloater #cui_dock_bottom
	),

	fn AddLogRollout NumMsg Type Title Labltext Critical Date  = (
		Rolloutname = "Rfl" + NumMsg as string
		rfTest = rolloutCreator Rolloutname (Type + ":  " +Title) 
		rfTest.begin()
		if Critical == true and Type != "Info" then (
			rfTest.addControl	#hyperlink #mystate "Critical " paramStr:"Enabled:false color: (color 240 0 0)   align:#left across:3"
		)
		else if  Type != "Info" then (
			rfTest.addControl	#hyperlink #mystate "not critical " paramStr:"Enabled:false color: (color 200 200 0)   align:#left across:3"
		)
		else (
			rfTest.addControl	#hyperlink #mystate "Info" paramStr:"Enabled:false color: (color 200 200 200)   align:#left across:3"
		)
		rfTest.addControl	#Label #MyDate Date  paramStr:" align:#right "
		rfTest.addControl #button #myButton "Open Help"	paramStr:"width:100 height:20 align:#right  Enabled:false"	-- add a button
		--rfTest.addLocal "thisRolloutNumber" init:"RolloutID"
		--rfTest.addHandler #myButton #pressed filter:on codeStr:"removeRollout  MyVRageMessageFloater.rollouts[thisRolloutNumber]  MyVRageMessageFloater" 
		
		lbl = substituteString Labltext "\"" "'"
		lbl = Vrage_wrapText lbl 500
		rfTest.addControl #label #mylabel  lbl paramStr:("height:40  align:#Left ")
		rfTest.end()
		addrollout rfTest.def MyVRageMessageFloater 
	),
	
	fn AddMessage Type Title Message Critical = (
		
		insertItem(VrageLogMessage()) MyVrageMessageArray 1
		MyVrageMessageArray[1].Type = Type 
		MyVrageMessageArray[1].Title = Title 
		MyVrageMessageArray[1].Message = Message 
		MyVrageMessageArray[1].Date = localTime
		MyVrageMessageArray[1].Critical = Critical
		
		if 	MyVrageMessageArray.count > 10 do deleteItem  MyVrageMessageArray MyVrageMessageArray.count 	
		
		if MyVRageMessageFloater == undefined or MyVRageMessageFloater.open  == false do CreateMessageRollout()
		

		if MyVRageMessageFloater != undefined then (
			
			for i  in MyVRageMessageFloater.rollouts do removeRollout i  MyVRageMessageFloater 
			addrollout MyVRageMessageFloaterMenu MyVRageMessageFloater	
			
			for i = 1 to MyVrageMessageArray.count do
			(
				AddLogRollout i  MyVrageMessageArray[i].Type  MyVrageMessageArray[i].Title  MyVrageMessageArray[i].Message MyVrageMessageArray[i].Critical MyVrageMessageArray[i].Date
			)
		)
		
	),	
	

	silent = False,

	fn Info Data  Title: "" Show: false =
	(
		logsystem.logEntry Data debug:0 info:1 warning:0 error:0
		if Show == true do AddMessage "Info" Title  Data false
	),
	
	fn Warn Data Title: "" Show: true =
	(
		logsystem.logEntry Data debug:0 info:0 warning:0 error:1
		if silent do Show = false
		if Show == true do AddMessage "Warning" Title  Data false
	),

	fn Error Data Title: "" Show: true =
	(
		logsystem.logEntry Data debug:0 info:0 warning:0 error:1
		if silent do Show = false
		if Show == true do 	AddMessage "Error"  Title Data true	
	)
)

MyVRageLog = VrageLogSys()









