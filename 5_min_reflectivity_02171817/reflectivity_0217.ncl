;-- 5-min reflectivity plot (dbz) of NCFR event on February 17-18, 2017

begin
  
  start_cpu_time = get_cpu_time() ; get cpu time

;-- Open file
  filename = "~/Documents/Grad School/Thesis Work/NCFR Data/2017_SoCal_NCFR/20170217_18.nc"
  a = addfile(filename, "r")

;-- Read variables
  ; terrain possibly?
  dbz = a->Reflectivity(:, :, :)

;-- Set all values equal to -2147483648 to missing, so they don't get plotted
  dbz@_FillValue = -999 ; considered missing value when equal to fill value
  dbz = where(dbz .eq. -2147483648, dbz@_FillValue, dbz) ; where dbz = ... --> dbz = fillvalue
  ntim = dimsizes(dbz(:, 0, 0))

  ; ter_plot for terrain plot
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

  ;- Copy common resources for terrain plot

  ;- Copy common resources for dbz plot
  dres = res

  dres@cnFillMode = "RasterFill"
  dres@cnLevelSelectionMode = "ExplicitLevels"
  dres@cnLevels = ispan(-28, 50, 8) ; create an array of values from -28 to 50 at intervals of 8
  dres@lbOrientation = "Vertical"

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
;-- For ispan line, why is there a segmentation fault?!?!?!
