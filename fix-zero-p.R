library(data.table)
library(Rmpfr)

.N <- function(.) mpfr(., precBits = 10)

fix.p <- function(BETA, SE){
    
    Rmpfr::format(exp(.N(pchisq((BETA/SE)^2, df=1, lower.tail=FALSE, log.p = TRUE))))
}

args <- commandArgs(trailingOnly = TRUE)

# Rmpfr function to obtain arbitrary precision float
.N <- function(.) mpfr(., precBits = 10)

# GWAS output file containing at minimum columns labelled BETA, SE and P.
gwasf <- args[1] 

message("Loading file")
DT <- fread(gwasf, header=TRUE)

# Retain original p-value
DT[, P.old := P]
# Set new p-value as character class, otherwise small p-values will round to 0 if numeric.
DT[, P := NULL]
DT[, P := as.character(P.old)]

message("Computing new p-values")
# For GWAS p-values that are equal to 0, use Rmpfr to obtain arbitraty precision using BETA and SE.
DT[P.old==0, P := fix.p(BETA, SE)]

message("Writing output")
write.table(DT, file=paste0(gwasf,".fzp"), sep="\t", quote=FALSE, row.names = FALSE)
