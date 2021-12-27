fn viewport_snapshot fname frame =
(	
	snapshot_name = (getDir #preview)+"/" + fname;
	view_size = getViewSize()
	anim_bmp = bitmap view_size.x view_size.y filename:snapshot_name
	sliderTime = frame
	dib = gw.getViewportDib captureAlpha:true
	copy dib anim_bmp
	save anim_bmp
	close anim_bmp
	gc()
)

viewport_snapshot "temp.png" 30f