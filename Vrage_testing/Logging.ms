logsystem.logName "c:\\extra.log"

logsystem.logEntry "What thtte heack" debug:0 info:0 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0
logsystem.logEntry "What thtte heack" debug:0 info:0 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0
logsystem.logEntry "What the heack" debug:0 info:0 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0
logsystem.logEntry "What thtztze heack" debug:0 info:0 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0
logsystem.logEntry "What the heack" debug:0 info:0 warning:1 error:0
logsystem.logEntry "What the  actual thing ist this  " debug:0 info:1 warning:1 error:0

rollout Rollout_VragLog "Untitled" width:849 height:400
(
	dotNetControl textboxctrl "System.Windows.Forms.TextBox" pos:[16,16] width:800 height:400
	
	on Rollout_VragLog open do
	(
	textboxctrl.AcceptsReturn = true;
	textboxctrl.AcceptsTab = true;
	textboxctrl.WordWrap = false;
	textboxctrl.Multiline = true;
	textboxctrl.ScrollBars = textboxctrl.ScrollBars.both;
		
	fs = openFile "c:\\extra.log"
	while not eof fs do
		(
			Theline = readline fs
		
			Tmp = filterstring Theline " "
			
			MyNewHeader = Tmp[1] + "    |    " + Tmp[2]  + "    |    " + Tmp[3]      
			MyNewText = ""
			for i = 6 to Tmp.count do MyNewText = MyNewText + " " + Tmp[i] 
			
			--2020/11/28 22:25:35 WRN: [08532] [07356] What the  actual thing ist this  
			textboxctrl.text = textboxctrl.text + MyNewHeader + "\r\n\r\n" +  MyNewText +"\r\n\r\n" +"\r\n\r\n" 
		)
		close fs
	)
)

showmethods (dotNetObject "TextBox")



try (closeRolloutFloater LogFloater) catch () 
LogFloater = newRolloutFloater  "VRage Utilies Log" 820 430 300 300 

addRollout Rollout_VragLog LogFloater




