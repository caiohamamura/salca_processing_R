if(! require("pacman")){
  install.packages("pacman")
}
p_load("lidR", "doParallel")



# Load point cloud
if (Sys.info()[["sysname"]] ==  "Windows") {
  setwd("U:/Datastore/CSCE/geos/groups/3d_env/data/visitors/2019.caio_hamamura/R/catalog")
} else {
  setwd("~/myspace/R/catalog")
}

outPath = file.path(getwd(), "../processed")
dir.create(outPath, showWarnings = F)

files = list.files(".")
f = files[1]

registerDoParallel(cores=6)
foreach(f=files[1:length(files)]) %dopar%
  {
    require(lidR)
    las = lidR::readLAS(f)
    
    
    outFilePath = file.path(outPath, sub("0.las", "0.DSM.tif", f))
    output = lidR::grid_canopy(las, 0.5, p2r())
    raster::writeRaster(output, outFilePath)
    rm(las, output)
  }
stopImplicitCluster()



