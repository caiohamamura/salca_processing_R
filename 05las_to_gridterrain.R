if(! require("pacman")){
  install.packages("pacman")
}
p_load("lidR", "doParallel")



# Load point cloud
if (Sys.info()[["sysname"]] ==  "Windows") {
  setwd("U:/Datastore/CSCE/geos/groups/3d_env/data/visitors/2019.caio_hamamura/R/processed/ground")
} else {
  setwd("~/myspace/R/processed/ground")
}

outPath = file.path(getwd(), "..")
dir.create(outPath, showWarnings = F)

files = list.files(".")
f = files[1]

registerDoParallel(cores=6)
foreach(f=files[1:length(files)]) %dopar%
  {
    require(lidR)
    las = lidR::readLAS(f)
    las@data$Classification = 2
    
    outFilePath = file.path(outPath, sub("0_g.las", "0_g.tif", f))
    output = lidR::grid_terrain(las, 0.5, knnidw())
    cropExtent = raster::extent(c(-10, 10, -10, 10))
    output = raster::crop(output, cropExtent)
    
    raster::writeRaster(output, outFilePath)
    rm(las, output)
  }
stopImplicitCluster()



