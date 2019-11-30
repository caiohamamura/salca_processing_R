######################
## PARAMETERS
######################
distance = 20
sliceWidth = 10
######################

halfDist = distance/2
halfSliceWidth = sliceWidth/2
innerRingPos = halfDist - halfSliceWidth
outerRingPos = halfDist + halfSliceWidth


if(! require(pacman)){
  install.packages("pacman")
  require(pacman)
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

registerDoParallel(cores=7)
foreach (f=files[1:length(files)]) %dopar%
{
  require(lidR)
  las = readLAS(f)
  
  dists = sqrt(las@data$X^2 + las@data$Y^2)
  output = lasfilter(las, dists >= innerRingPos & dists <= outerRingPos)
  
  outFilePath = file.path(outPath, sub(".0.las", paste0(".0_", round(innerRingPos) , "-", round(outerRingPos),"_ring.las"), f))
  writeLAS(output, outFilePath)
  rm(las, output)
}
stopImplicitCluster()


