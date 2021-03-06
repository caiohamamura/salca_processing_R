calibrate = function(r, rho, m, c, k, a, k2, P0) {
  arg = k2*r
  n = length(r)
  shortR = 1 - exp(-1*arg)
  rhoEff = P0 * rho * shortR / r^2
  arg = k * rhoEff
  nonLin = 1 - exp(-1 * arg) 
  DN = (m*rhoEff+c)*nonLin
  
  return(DN)
}


setwd("U:/Datastore/CSCE/geos/groups/3d_env/data/visitors/2019.caio_hamamura/Zemin/Radiation correction introduction/Radiation correction/result")

data = read.table("result_2832.txt")
r = data$V1
rho = data$V5
DNs = data$V2
m = 137.21
c1 = 407.04
k = 16.83
a=1.5
k2 = 0.18
k3 = 0.84
P0r = 1


i = 1


DN = calibrate(r, rho, m, c1, k, 0.0, 100000.0, P0r)
deviates = (DNs - DN)^2





install.packages("minpack.lm")
library(minpack.lm)

angular_phase = 1
range_function = (1/r^a)*(1-exp(-k2*r^k3))
area_projected = 1
area_footprint = 1
projected_area_ratio = area_projected/area_footprint
nlsLM(DN ~ (m*rho*angular_phase*P0*range_function*projected_area_ratio+c1)*(1-exp(-k*(rho*angular_phase*P0*range_function*projected_area_ratio))), start=list(P0=P0r))



p_eff = function(rho, angle_phase, P0, f_r, proj_area_ratio) {
  rho*angle_phase*P0*f_r*proj_area_ratio
}


vals = sapply(1:4, FUN=function(x) c(runif(2, 0, 1),runif(2, 0, 100), runif(1, 0, 1)))
apply(vals, 2, function(x) do.call(p_eff, as.list(x)))
apply(vals, 2, function(x) {
  cat(paste0("ASSERT_NEAR(fn_effective_reflectance(", paste(x, collapse=', '), ")\n"))
})


r_f = function(r, a, k2, k3) {
  (1/r^a*(1-exp(-k2*r^k3)))
}

fn_name = "fn_range_dependency"
vals = sapply(1:4, FUN=function(x) c(runif(1, 0, 1),runif(3, 0, 50)))
res=apply(vals, 2, function(x) do.call(r_f, as.list(x)))
txt=apply(vals, 2, function(x) {
  (paste0("ASSERT_NEAR(", fn_name, "(", paste(x, collapse=', '),"), "))
})
txt2=sapply(res, function(x) {
  x
  })
cat(paste0(paste0(txt, txt2), ", EPSILON);\n"))


DN = function(m, peff, c, k) {
  (m*peff + c)/(1-exp(-k*peff))

}

fn_name = "fn_dn"
vals = sapply(1:4, FUN=function(x) c(runif(1, 1, 900),runif(1, 0, 1),runif(2, 0, 50)))
res=apply(vals, 2, function(x) do.call(DN, as.list(x)))
txt=apply(vals, 2, function(x) {
  (paste0("ASSERT_NEAR(", fn_name, "(", paste(x, collapse=', '),"), "))
})
txt2=sapply(res, function(x) {
  x
})
cat(paste0(paste0(txt, txt2), ", EPSILON);\n"))


dn_summarize = function(r, rho, P0, m, c, k, a, k2, k3, ang_phase, proj_area_ratio) {
  range_f = r_f(r, a, k2, k3)
  rho_eff = p_eff(rho, ang_phase, P0, range_f, proj_area_ratio)
  dn = DN(m, rho_eff, c, k)
  dn
}


fn_name = "fn_dn_summarize"
(vals = sapply(1:4, FUN=function(x) c(runif(1, 0.1, 60), runif(1, 0, 1), runif(1, 0.1, 100), runif(1, 1, 200), runif(5, 0, 10), rep(1, 2))))
(res=apply(vals, 2, function(x) do.call(dn_summarize, as.list(x))))
txt=apply(vals, 2, function(x) {
  (paste0("  ASSERT_NEAR(", fn_name, "(", paste(x, collapse=', '),"), "))
})
txt2=sapply(res, function(x) {
  x
})
cat(paste0(paste0(txt, txt2), ", EPSILON);\n"))


dn_summarize(6.47525668235294, 0.604931, 1, 137.21, 407.04, 16.83, 1.5, 0.18, 0.89, 1, 1)
