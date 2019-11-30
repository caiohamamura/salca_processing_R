# Configure paths
salcaFiles = '..'
outDir = file.path(salcaFiles, 'processing')
dir.create(outDir, showWarnings = F)

files = list.files(salcaFiles, '*.txt')


# Create a normalization function
NormalizeIntensity = function(x) {
  # Calculate euclidean sqr distance
  sqrDist = x[,1]^2 + x[,2]^2 + x[,3]^2
  intensity = x[,4]
  return (intesity * sqrDist)
}


# Loop for each file
for (file in files) {
  # file = files[1]
  
  tlsData = read.table(file.path(salcaFiles, file))
  tlsData[,4] = NormalizeIntensity(tlsData)
  write.csv(tlsData[,1:4], file.path(outDir, sub('\\.txt', '_n\\.txt', file)), row.names = F, col.names = F)
}