fn getMaterialThumbnail mat = (
	local thumb = undefined
	local iGlobal = (dotnetClass "Autodesk.Max.GlobalInterface").Instance
	if iGlobal != undefined then (
		local IntPtr = dotnetClass "System.IntPtr"
		local pStampSize = (dotnetclass "Autodesk.Max.PostageStampSize").Large

		local backupMat = meditMaterials[1]
		meditMaterials[1] = mat
		local matRef = iGlobal.CoreInterface.GetMtlSlot 0

		local pStamp = matRef.CreatePStamp pStampSize true
		local bytes = pStamp.Image
		local size = pStamp.Width
		thumb = bitmap size size gamma:2.2

		local step = size * 3
		for y = 1 to bytes.count by step do (
			local row = for x = y to (y + step - 1) by 3 collect [bytes[x + 2], bytes[x + 1], bytes[x]]
			setpixels thumb [0, size -= 1] row
		)

		pStamp.Dispose()
		matRef.Dispose()
		meditMaterials[1] = backupMat
	)
	return thumb
)

Fn GetMaterialSample inputMaterial inputWidth inputHeight =
(
    result = undefined
    with redraw off
    with undo off
    (
        tempHiddenObject = for tempObject in Objects where not tempObject.ishidden collect tempObject
        Hide tempHiddenObject
        tempCamera = Freecamera fov:45 targetDistance:50 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off pos:[0,0,40]
        tempBackground = Plane pos:[0,0,-10] Length:150 Width:150 wireColor:gray
        tempSphere = Sphere pos:[0,0,0] rotation:(quat -0.707107 0 0 0.707107) wirecolor:gray radius:10 smooth:on segs:32 chop:0 slice:off sliceFrom:0 sliceTo:0 mapcoords:on recenter:off
       -- tempSphere.rotation = eulerAngles -90 0 0
        tempSphere.material = inputMaterial
        for tempLight in Lights where IsProperty tempLight #excludeList do 
        (
            tempLight.excludeList = Append tempLight.excludeList tempSphere
            tempLight.excludeList = Append tempLight.excludeList tempBackground
        )
        tempLight = Omnilight multiplier:1.0 pos:[20,20,40]
        tempLight2 = Omnilight multiplier:1.0 pos:[-15,-20,0]
        result = render camera:tempCamera outputsize:[inputWidth,inputHeight] vfb:false
        delete #(tempCamera,tempLight,tempLight2,tempSphere,tempBackground)
        UnHide tempHiddenObject
    )
    result
)

try(DestroyDialog TestRollout)catch()
Rollout TestRollout ""
(
    Bitmap MaterialSampleBitMap width: 400 height: 400
    
    dropdownlist scale_dd "Scale" items:MyVrageMatLib.mat_names
    on scale_dd selected i do (
        format "You selected '%'!\n" scale_dd.items[i]
        myMAt =  Vrage_getmatbyname MyVrageMatLib.mat_names[i]
        MaterialSampleBitMap.bitmap = (GetMaterialSample myMAt 256 256)
    )

    
)
CreateDialog TestRollout width: 400 height: 600


--display thumbs