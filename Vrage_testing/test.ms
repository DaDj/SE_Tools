rollout image_button_test2 "Test Image Buttons"
(
button btn_imageButton1 width:24 height:24 across:5
button btn_imageButton2 width:24 height:24
button btn_imageButton3 width:24 height:24
button btn_imageButton4 width:24 height:24
button btn_imageButton5 width:24 height:24
checkbox chk_toggleEnabled "Toggle Enabled State" checked:true
local theButtons = #(btn_imageButton1, btn_imageButton2, btn_imageButton3, btn_imageButton4, btn_imageButton5)
fn updateButtons =
(
for i = 1 to theButtons.count do
(
local theIndex = (i*2)-1
theButtons[i].images = #(
"Containers_24i.bmp",
"Containers_24i.bmp",
18, theIndex, theIndex, theIndex+1, theIndex+1, false, true
)
)
)
on chk_toggleEnabled changed state do
for i in theButtons do i.enabled = state
on image_button_test2 open do updateButtons()
)
createDialog image_button_test2