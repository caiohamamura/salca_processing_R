if(! require("pacman")){
  install.packages("pacman")
}
p_load("lidR")



# Load point cloud
if (Sys.info()[["sysname"]] ==  "Windows") {
  setwd("U:/Datastore/CSCE/geos/groups/3d_env/data/visitors/2019.caio_hamamura/")
} else {
  setwd("~/myspace")
}
outPath = file.path(getwd(), "R/processed")
dir.create(outPath, showWarnings = F)

files = list.files("R/catalog")
las = readLAScatalog("R/catalog")

f = files[1]

for (f in files[1:length(files)])
{
  data = read.table(f, col.names = c("X","Y","Z","Intensity","zen","az","range","number","azInd","zenInd","wavstart","satTest","rho","width","qRange","qPeak","qIntegral","peak"))
  
  # Fit intensity values to 16 bits range
  minMax = range(data$Intensity)
  nBins = 2^16-1
  data$Intensity = as.integer(floor(((data$Intensity - minMax[1]) / diff(minMax))*nBins))
  
  las = lidR::LAS(data)
  
  outFilePath = file.path(outPath, sub(".0.txt", ".0.las", f))
  output = las
  writeLAS(output, outFilePath)
  rm(las, output)
}

