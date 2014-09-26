#!/usr/bin/Rscript

# R Script to merge a set of jMeter stats CSV files. The script takes a base file
# name. JMeter output csv files should follow the structure <basename>_<n>.csv,
# where n is the number of JMeter replications performed
#
# creation date: 2014-09-26
# author: Emmanuel Blondel <emmanuel.blondel1 at gmail.com>
#
# @requires: plyr (available in CRAN)
# @param basename
#
# Usage:
#
# Rscript jmeter_stats.R "results_figis_geoserver_dev_wfs1"
#
cat("=> Loading dependencies...\n")
require(plyr)

#args
args <- commandArgs(TRUE)
basename <- args[1]

#preparing files & merge
cat("=> Merging JMeters results...\n")
names <- c("nb","sampler_label","count","avg","min","max","stddev","error","rate",     
           "bandwidth","bytes")
files <- paste(rep(basename,5), "_", 1:5, sep="")
x <- do.call("rbind",
  lapply(1:5, function(t){
    f <- read.table(paste(files[t],".csv", sep=""), sep = ",", header = TRUE)
    f <- cbind(nb = 1:nrow(f), f)
    return(f)
  })
)
colnames(x) <- names
for(i in 1:ncol(x)){
  if(class(x[,i]) == "factor" & names(x)[i] != "sampler_label"){
    x[,i] <- as.numeric(as.character(x[,i]))
  }
}

#mean aggregation
cat("=> Aggregating JMeter replicate results...\n")
y <- ddply (x,
            .(sampler_label),
            function(X) data.frame (
              nb = mean(X$nb),
              count = mean(X$count),
              avg = mean(X$avg),
              min = mean(X$min),
              max = mean(X$max),
              stddev = mean(X$stddev),
              error = mean(X$error),
              rate = mean(X$rate),
              bandwidth = mean(X$bandwidth),
              bytes = mean(X$bytes)
              ))
y = y[ order(y[,2]), ]


cat("=> Writing JMeter summary...\n")
write.table(y, paste(basename, "summary.csv", sep="_"),
            sep=",", row.names = FALSE)

cat("=> DONE!")
