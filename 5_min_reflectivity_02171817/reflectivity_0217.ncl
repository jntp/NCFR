;-- 5-min reflectivity plot (dbz) of NCFR event on February 17-18, 2017

;----- Main Code -----;
begin
  
  start_cpu_time = get_cpu_time() ; get cpu time

;-- Open file
  filename = "~/Documents/Grad School/Thesis Work/NCFR Data/2017_SoCal_NCFR/20170217_18.nc"
  topo_map = "~/Documents/Grad School/Thesis Work/NCFR Data/DEM DATA/N32W119_SRTMGL1_hgt_HEGOUT.nc"
  a = addfile(filename, "r")
  b = addfile(topo_map, "r")

;-- Terrain Plot - Lat/lon Limits
  minlat = 32
  maxlat = 35
  minlon = -121
  maxlon = -117

;-- Read variables
  dbz = a->Reflectivity(:, :, :) ; load reflectivity data
  hgt = b->hgt({minlat:maxlat}, {minlon:maxlon}) ; load dem data

;-- Set all values equal to -2147483648 to missing, so they don't get plotted
  dbz@_FillValue = -999 ; considered missing value when equal to fill value
  dbz = where(dbz .eq. -2147483648, dbz@_FillValue, dbz) ; where dbz = ... --> dbz = fillvalue
  ntim = dimsizes(dbz(:, 0, 0))

;-- Open workstation
  wtype = "png"
  wtype@wkWidth = 2500
  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype, "animate") 

;-- Set common resources
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
  res@tfDoNDCOverlay = True ; faster plotting if we use native map projection?

  res@cnConstFEnableFill = True ; force contour fill for constant or near constant values 
  res@cnConstFLabelBackgroundColor = "transparent" ; default is white

;-- Common resources for terrain plot
  tres = res

  ;-- Will use this later for coloring the contours 
  cmap = read_colormap_file("OceanLakeLandSnow")

  tres@gsnMaximize = True ; maximize plot in frame

  tres@cnFillMode = "RasterFill" ; for faster draw
  tres@cnFillPalette = cmap(2:, :) 
  tres@cnFillOpacityF = 0.5 ; make contours partially transparent

  tres@cnInfoLabelOn = False ; turn off info labels
  tres@lbBoxLinesOn = False ; turn off labelbar box lines
  tres@lbTitleString = "elevation (meters)" ; add a labelbar title
  tres@lbTitleFontHeightF = 0.015
  tres@lbTitlePosition = "Bottom"
  tres@lbLabelBarOn = False

  ;- Pick "nice" contour levels
  mnmxint = nice_mnmxintvl(min(hgt), max(hgt), 18, False) ; calculate "nice" values for endpoints and spacing
  tres@cnLevelSelectionMode = "ManualLevels"
  tres@cnMinLevelValF = mnmxint(0)
  tres@cnMaxLevelValF = mnmxint(1)
  tres@cnLevelSpacingF = mnmxint(2) / 8 ; increase the number of levels by choosing a smaller spacing

  ;- Zoom in on map
  tres@mpMinLatF = minlat
  tres@mpMaxLatF = maxlat
  tres@mpMinLonF = minlon
  tres@mpMaxLonF = maxlon
  tres@mpCenterLonF = (tres@mpMinLonF + tres@mpMaxLonF) / 2 ; calculate midpoint

  tres@mpDataBaseVersion = "MediumRes"

  tres@mpFillOn = False ; no map fill
  tres@mpOutlineOn = True ; enable drawing of map area outline
  tres@mpOutlineBoundarySets = "AllBoundaries" ; draw outlines for all the boundaries
  tres@gsnAddCyclic = False ; don't add longitude cyclic point

  tres@tiMainString = "Southern California"
  tres@gsnLeftString = ""
  tres@gsnRightString = ""
  tres@pmTickMarkDisplayMode = "Always"
  tres@pmTitleZone = 4 ; move main title down a little 

;-- Common resources for dbz plot
  dres = res

  dres@cnFillMode = "RasterFill"
  dres@cnLevelSelectionMode = "ExplicitLevels"
  dres@cnLevels = ispan(-28, 50, 8) ; create an array of values from -28 to 50 at intervals of 8
  dres@lbOrientation = "Vertical"

  dres@cnConstFEnableFill = True ; force contour fill for constant or near constant values 
  dres@cnConstFLabelBackgroundColor = "transparent" ; default is white

  ;- Read in colormap so we can subset it
  cmap_r = read_colormap_file("WhViBlGrYeOrRe")
  dres@cnFillPalette = cmap_r(6:, :) ; skip the first few colors

  ;- Create the terrain map with initial title, first dbz plot, and overlay
  tres@tiMainString = 0
  ter_plot = gsn_csm_contour_map(wks, hgt, tres)
  dbz_plot = gsn_csm_contour(wks, dbz(0, :, :), dres)
  overlay(ter_plot, dbz_plot) 

;-- Loop through each time step and draw a new plot
  do nt = 0, ntim - 1
    ;- Don't plot missing or constant fields

    ;- Use "setvalues" to update the two plots
    if (nt .gt. 0) then 
      setvalues ter_plot ; change the title
	"tiMainString" : nt 
      end setvalues
      setvalues dbz_plot@data ; change the data
	"sfDataArray" : dbz(nt, :, :)
      end setvalues
    end if

    ;- Drawing the terrain plot will also draw dbz plot
    draw(ter_plot(nt))
    frame(wks)
  end do

;-- Calculate total time
  end_cpu_time = get_cpu_time() 
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time - start_cpu_time) + " seconds.")
end

;-- See animate_3_3.ncl example @ ncl.ucar.edu/Applications/animate.shtml
;-- Why won't the contour fill for constant or near constant values? See example @ /Applications/Scripts/coneff_17.ncl
;-- You left off at creating the topographic map. See example topo_raster_7 or topo_8.ncl @ ncl.ucar.edu/Applications/topo.shtml
;-- Also, now try to overlay the terrain plot with reflectivity plot in the main code
;-- Damn it... make the plot run faster
