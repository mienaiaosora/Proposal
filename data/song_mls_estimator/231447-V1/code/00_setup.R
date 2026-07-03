# ==============================================================================
# Required packages
# ==============================================================================
library(tidyverse)
library(data.table)
library(sf)
library(units)
library(readxl)
library(lfe)
library(fixest)
library(argparse)

# ==============================================================================
# Set file paths
# ==============================================================================
# Note: Set the root directory of the replication package as the working directory
# before running any scripts. This ensures that relative paths to data/ and output/ folders resolve correctly.

# Raw data directory
data_path = "data/"

# INT data directory (not included in the replication package, replicable using the code files)
int_path = "INT/"

# Path to save all logs and figures
output_path = "output/"

# Path to Census boundaries and school district maps
map_path = paste0(data_path, "map/")

# Path to CoreLogic Parcel Data (note: multiple historical records exist per parcel)
tax_path = paste0(data_path, "tax_sfr/")

# Path to CoreLogic Deed Data
deed_path = paste0(data_path, "deed_sfr/")

# Path to CoreLogic Deed+HMDA Data
hmda_path = paste0(data_path, "hmda_sfr/")

# Path to CoreLogic MLS Data (restricted to rental listings)
mls_path = paste0(data_path, "mls_sfr/")

# ==============================================================================
# Other spec.
# ==============================================================================
# Parcel ID variables
id_vars = c("fips","apn_unformatted","apn_num")

# state FIPS code, CBSAs, and region
fips_dt = fread(paste0(map_path, "state-fips.csv"))
cbsa_dt <- fread(paste0(map_path, "cbsa2fipsxw.csv"))
cbsa_dt <- cbsa_dt[2:.N][,.(fips=fipsstatecode*1000+fipscountycode,
                            cbsa_id = cbsacode,
                            i_metro=ifelse(str_detect(metropolitanmicropolitanstatis,"Metro"),1,0),
                            i_micro=ifelse(str_detect(metropolitanmicropolitanstatis,"Micro"),1,0))]
region_dt = fips_dt[,.(state_fips, state_region=ifelse(state_region=="NW","NE",state_region))]

# graphics theme
theme_set(theme_bw()+theme(text = element_text(size=20),
                           legend.text = element_text(size=20),
                           plot.title=element_text(size=20),
                           axis.text = element_text(size=18),
                           strip.text=element_text(size=18),
                           legend.position="bottom"))
