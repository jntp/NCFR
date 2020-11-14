;-- 5-min reflectivity plot (dbz) of NCFR event on February 17-18, 2017

begin
  
  start_cpu_time = get_cpu_time() ; get cpu time

;-- Open file
  filename = "~/Documents/Grad School/Thesis Work/NCFR Data/2017_SoCal_NCFR/20170217_18.nc"
  a = addfile(filename, "r")

;-- Read variables
  dbz = a->Reflectivity(:, :, :)

  printVarSummary(dbz)


end

;-- See animate_3_1.ncl example @ ncl.ucar.edu/Applications/animate.shtml
