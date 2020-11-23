;-- Create a temporary topographic plot separately
begin
;-- Open a file
  topo_map = "~/Documents/Grad School/Thesis Work/NCFR Data/DEM DATA/N33W118_SRTMGL1_hgt_HEGOUT.nc"
  b = addfile(topo_map, "r")

;-- Terrain Plot - Lat/lon Limits
  minlat = 32
  maxlat = 35
  minlon = -121
  maxlon = -117

;-- Read variables
  hgt = b->hgt({minlat:maxlat}, {minlon:maxlon}) ; load dem data

  printVarSummary(hgt)

;--Open workstation
  wks = gsn_open_wks("png", "test_topo")

;-- Increase the workspace memory
  setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 400000000
  end setvalues

;-- Common resources for terrain plot
  res = True

  res@gsnDraw = False ; turn off draw
  res@gsnFrame = False ; turn off frame
  res@cnFillOn = True ; turn on contour fill
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off contour line labels

  ;- Turn off subtitles
  res@gsnLeftString = "" 
  res@gsnRightString = ""
  res@gsnCenterString = ""

  res@lbLabelFontHeightF = 0.015 ; size of labelbar labels
  res@pmLabelBarOrthogonalPosF = -0.02 ; move labelbar closer to plot

  ;- Keep plot from running off the frame
  res@vpXF = 0.08
  res@vpYF = 0.88
  res@vpWidthF = 0.80
  res@vpHeightF = 0.60
  res@tfDoNDCOverlay = True ; faster plotting if we use native map projection

  ;-- Will use this later for coloring the contours 
  cmap = read_colormap_file("OceanLakeLandSnow")

  res@gsnMaximize = True ; maximize plot in frame

  res@cnFillMode = "RasterFill" ; for faster draw
  res@cnFillPalette = cmap(2:, :) 
  res@cnFillOpacityF = 0.5 ; make contours partially transparent

  res@cnInfoLabelOn = False ; turn off info labels
  res@lbBoxLinesOn = False ; turn off labelbar box lines
  res@lbTitleString = "elevation (meters)" ; add a labelbar title
  res@lbTitleFontHeightF = 0.015
  res@lbTitlePosition = "Bottom"
  res@lbLabelBarOn = False

  ;- Pick "nice" contour levels
  mnmxint = nice_mnmxintvl(min(hgt), max(hgt), 18, False) ; calculate "nice" values for endpoints and spacing
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2) / 8 ; increase the number of levels by choosing a smaller spacing

  ;- Zoom in on map
  res@mpMinLatF = minlat
  res@mpMaxLatF = maxlat
  res@mpMinLonF = minlon
  res@mpMaxLonF = maxlon
  res@mpCenterLonF = (res@mpMinLonF + res@mpMaxLonF) / 2 ; calculate midpoint

  res@mpDataBaseVersion = "MediumRes"

  res@mpFillOn = False ; no map fill
  res@mpOutlineOn = True ; enable drawing of map area outline
  res@mpOutlineBoundarySets = "AllBoundaries" ; draw outlines for all the boundaries
  res@gsnAddCyclic = False ; don't add longitude cyclic point

  res@tiMainString = "Southern California"
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@pmTickMarkDisplayMode = "Always"
  res@pmTitleZone = 4 ; move main title down a little 

  plot = gsn_csm_contour_map(wks, hgt, res)
  draw(plot)
  frame(wks)
end

;- REVELATION!!!! Each netcdf STRM DEM file is a PART of Southern California. Latitude represents the bottom left point
;- longitude represents the center point. So 33N118W means 33N is at bottom left point, 118W means center point!!!
;-- You will need to combine them together and increase memory allocation size to large numbers
