if(! require("pacman")){
  install.packages("pacman")
}
p_load("lidR")




# Load point cloud
if (Sys.info()[["sysname"]] ==  "Windows") {
  setwd("U:/Datastore/CSCE/geos/groups/3d_env/data/visitors/2019.caio_hamamura/R/catalog")
} else {
  setwd("~/myspace/R/catalog")
}

outPath = file.path(getwd(), "../processed")
dir.create(outPath, showWarnings = F)

files = list.files(".", ".*4mrad.*0.txt")
f = files[1]

for (f in files[1:length(files)])
{
  las = lidR::readLAS(f)
  
  dists = sqrt(las@data$X^2 + las@data$Y^2)
  output = lasfilter(las, dists >= 8 & dists <= 14.5)
  
  outFilePath = file.path(outPath, sub(".0.txt", ".0_8-14_ring.las", f))
  writeLAS(output, outFilePath)
}