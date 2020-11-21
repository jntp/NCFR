;-- 5-min reflectivity plot (dbz) of NCFR event on February 17-18, 2017

;----- Create function that allows for creation of a topography map -----;
undef("create_topo_map")
function create_topo_map(wks, minlat, maxlat, minlon, maxlon)
local topo_file, a, hgt, res, cmap
begin
;-- Load files
  topo_file = "~/Documents/Grad School/Thesis Work/NCFR Data/DEM DATA/N32W119_SRTMGL1_hgt_HEGOUT.nc"
  a = addfile(topo_file, "r")
  hgt = a->hgt({minlat:maxlat}, {minlon:maxlon})

;-- Will use this later for coloring the contours
  cmap = read_colormap_file("OceanLakeLandSnow")

;-- Set some resources for contouring and mapping
  res = True
  
  res@gsnMaximize = True ; maximize plot in frame

  res@gsnDraw = False
  res@gsnFrame = False

  res@cnFillOn = True ; turn on contour fill
  res@cnFillMode = "MeshFill" ; for faster draw
  res@cnFillPalette(2:, :) 

  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off line labels
  res@cnInfoLabelOn = False ; turn off info labels
  res@lbBoxLinesOn = False ; turn off labelbar box lines
  res@lbTitleString = "elevation (meters)" ; add a labelbar title
  res@lbTitleFontHeightF = 0.015
  res@lbTitlePosition = "Bottom"
  res@pmLabelBarOrthogonalPosF = 0.15

;-- Pick "nice" contour levels
  mnmxint = nice_mnmxintvl(min(elev, max(elev), 18, False) ; calculate "nice" values for endpoints and spacing
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2) / 8 ; increase the number of levels by choosing a smaller spacing

;-- Zoom in on map
  res@mpMinLatF = minlat
  res@mpMaxLatF = maxlat
  res@mpMinLonF = minlot
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
  res@pmTitleZzone = 4 ; move main title down a little 

;-- Create map and return it
  plot = gsn_csm_contour_map(wks, hgt, res)
  return(plot)
end


;----- Main Code -----;
begin
  
  start_cpu_time = get_cpu_time() ; get cpu time

;-- Open file
  filename = "~/Documents/Grad School/Thesis Work/NCFR Data/2017_SoCal_NCFR/20170217_18.nc"
  filename_dem = "~/Documents/Grad School/Thesis Work/NCFR Data/DEM DATA/N32W119_SRTMGL1_hgt_HEGOUT.nc"
  a = addfile(filename, "r")
  b = addfile(filename_dem, "r")

;-- Read variables
  dbz = a->Ref
  lectivity(:, :, :) # load reflectivity data
  hgt = b->hgt({minlat:maxlat}, {minlon:maxlon}) # load dem data

;-- Set all values equal to -2147483648 to missing, so they don't get plotted
  dbz@_FillValue = -999 ; considered missing value when equal to fill value
  dbz = where(dbz .eq. -2147483648, dbz@_FillValue, dbz) ; where dbz = ... --> dbz = fillvalue
  ntim = dimsizes(dbz(:, 0, 0))

  ter_plot = new(tim, graphic) 
  dbz_plot = new(ntim, graphic)

;-- Open workstation
  wks = gsn_open_wks("png", "5_min_reflectivity_02171817")

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

  ;- Copy common resources for terrain plot
  tres = res


  ;- Copy common resources for dbz plot
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

;-- Loop through each time step and draw a new plot
  do nt = 0, ntim - 1
    ;- Don't plot missing or constant fields
    
    ;- Create the two plots
    dres@tiMainString = nt
    dbz_plot(nt) = gsn_csm_contour(wks, dbz(nt, :, :), dres)

    ;- Drawing the terrain plot will also draw dbz plot
    draw(dbz_plot(nt))
    frame(wks)
  end do

;-- Calculate total time
  end_cpu_time = get_cpu_time() 
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time - start_cpu_time) + " seconds.")
end

;-- See animate_3_1.ncl example @ ncl.ucar.edu/Applications/animate.shtml
;-- Why won't the contour fill for constant or near constant values? See example @ /Applications/Scripts/coneff_17.ncl
;-- You left off at creating the topographic map. See example @ /Applications/Scripts/topo_8.ncl
;-- Also, now try to overlay the terrain plot with reflectivity plot in the main code 
