#!/usr/bin/Rscript

# R Script to prepare a random list of cql_filters for a given feature collection
# and a given feature property (attribute). This list of cql filters can then be
# use as source dataset within JMeter scripts.
#
# creation date: 2014-09-26
# author: Emmanuel Blondel <emmanuel.blondel1 at gmail.com> 
# 
# @requires: RFigisGeo
# - available at: https://github.com/openfigis/RFigisGeo
# - installation:
#    require(devtools)
#    install_gihub("RFigisGeo","openfigis")
#
# @param host (host of the OWS server)
# @param path (path of the OWS server)
# @param typeName (name of the feature collection as published in the OWS server)
# @param propertyName (property name of interest for generating filters)
# @param count (number of randoms)
#

cat("=> Loading dependencies...\n")
require(RFigisGeo)

#arguments
args <- commandArgs(TRUE)
host <- args[1]
path <- args[2]
typeName <- args[3]
propertyName <- args[4]
count <- as.integer(args[5])

cat("=> Reading WFS data...\n")
wfs.request <- paste(host, "/", path,
					"?service=WFS&version=1.0.0&request=GetFeature",
					"&typeName=",typeName, sep = "")
wfs.sp <- readWFS(wfs.request)

cat("=> Generating random cql filters...\n")
wfs.df <- as(wfs.sp, "data.frame")
wfs.property <- unique(wfs.df[,propertyName])
wfs.random.data <- sample(wfs.property, count, replace=TRUE)
wfs.random.cql <- paste(propertyName, "='", wfs.random.data, "'", sep = "")
output <- as.data.frame(wfs.random.cql)
colnames(output) <- "cql_filter"

cat("=> Writing output CSV file...\n")
write.table(output, file = "cql_filters.csv", sep = ";",
			row.names = FALSE, quote = FALSE)

cat("=> DONE!")
