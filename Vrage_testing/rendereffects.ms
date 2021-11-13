plugin RenderEffect MonoChrome
name:"MonoChrome"
classID:#(0x9e6e9e77, 0xbe815df4)
(
rollout about_rollout "About..."
(
  label about_label "MonoChrome Filter"
)
on apply r_image progressCB: do
(
  progressCB.setTitle "MonoChrome Effect"
  local oldEscapeEnable = escapeEnable
  escapeEnable = false
  bmp_w = r_image.width
  bmp_h = r_image.height
  for y = 0 to bmp_h-1 do
  (
    if progressCB.progress y (bmp_h-1) then exit
    pixel_line = getPixels r_image [0,y] bmp_w
    for x = 1 to bmp_w do
    (
      p_v = pixel_line[x].value
		blueval = pixel_line[x].blue *5
      pixel_line[x] = color p_v p_v blueval pixel_line[x].alpha
    )--end x loop
    setPixels r_image [0,y] pixel_line
  )--end y loop
  escapeEnable = oldEscapeEnable
)--end on apply
)--end plugin