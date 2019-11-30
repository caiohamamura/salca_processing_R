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
  las = lidR::readLAS(f)
  
  ws = seq(3,12, 3)
  th = seq(0.1, 1.5, length.out = length(ws))
  groundLas = lidR::lasground(las, pmf(ws, th))
  
  
  outFilePath = file.path(outPath, sub(".0.las", ".0_g.las", f))
  output = lasfilter(las, groundLas$Classification == 2)
  writeLAS(output, outFilePath)
  rm(las, groundLas, output)
}

