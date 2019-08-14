library(data.table)
library(Rmpfr)

args <- commandArgs(trailingOnly = TRUE)

# Rmpfr function to obtain arbitrary precision float
.N <- function(.) mpfr(., precBits = 10)

# FastGWA output file containing columns BETA, SE and P.
gwasf <- args[1] 

message("Loading file")
DT <- fread(gwasf, header=TRUE)

message("Computing p-values")
# Retain original fastGWA p-value
DT[, P.fastGWA := P]
# Set new p-value as character class, otherwise small p-values will round to 0 if numeric.
DT[, P := NULL]
DT[, P := as.character(P.fastGWA)]

# For fastGWA p-values that are equal to 0, use Rmpfr to obtain arbitraty precision using BETA and SE.
DT[P.fastGWA==0, P := Rmpfr::format(exp(.N(pchisq((BETA/SE)^2, df=1, lower.tail=FALSE, log.p = TRUE))))]

message("Writing output")
write.table(DT, file=paste0(gwasf,".fixed"), sep="\t", quote=FALSE, row.names = FALSE)
