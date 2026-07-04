# Replication Package for  
**"The Effects of Residential Zoning in U.S. Housing Markets"**  
**Author:** Jaehee Song  
**Date:** 2025-05-30

---

## Required Software

- **R (version ≥ 4.1.0)**
- **R packages:** `tidyverse`, `data.table`, `fixest`, `lfe`, `sf`, `units`, `readxl`
- **Others:** The computation is highly parallelizable. The code was executed on a Linux cluster with 36 CPUs, although parallelization is not strictly required. If you intend to run scripts in parallel, the `argparse` R package is additionally required. Submit scripts via the command line using arguments as shown in the comments within each file.

---

## File Structure  
*(Brackets indicate excluded components due to data use restrictions)*

```
- code/
  ├── 00_setup.R
  ├── fn_binscatter.R
  ├── mla_estimation/
  │   ├── 01_merge_geo.R
  │   ├── 02_infer_MLA.R
  │   ├── 03_validation.R
  │   ├── 04_descriptive.R
  │   └── fn_struc_break.R
  └── border_analysis/
      ├── 11_define_borders.R
      ├── 12_build_sample.R
      ├── 13_main_analysis.R
      ├── run_binscatter.R
      ├── run_by_dist.R
      ├── run_demo.R
      ├── run_housing_production.R
      ├── run_no_ipums.R
      ├── run_other_mla.R
      ├── run_price_and_rent.R
      └── run_within_sd.R

- data/
  ├── CBG_chars.csv
  ├── georef-county-subdivision.csv
  ├── ipums40_chars_muni.csv
  ├── validation_set.csv
  ├── map/
  ├── [muni_incorporation/]
  ├── [tax_sfr/]
  ├── [deed_sfr/]
  ├── [hmda_sfr/]
  └── [mls_sfr/]

- [INT/]  ← Intermediate files (excluded)

- output/ ← Output log files, regression tables, and figures

- README.md
```

---

## Instructions

### 1. Estimating Minimum Lot Sizes (Section 3.1)
  a. Run `00_setup.R` to load required packages and define paths.  
  b. Run `mla_estimation/01_merge_geo.R` to merge municipal geography with parcel data.  
  c. Run `mla_estimation/02_infer_MLA.R` to estimate minimum lot sizes using structural break detection.  

### 2. Validation Exercise (Section 3.2)
  a. Run `00_setup.R`  
  b. Run `mla_estimation/03_validation.R` to compare estimated MLS values with actual zoning codebook data for a validation sample.

### 3. Descriptive Analysis (Section 3.3)
  a. Run `00_setup.R`  
  b. Run `mla_estimation/04_descriptive.R` to generate descriptive statistics and spatial patterns of zoning stringency.

### 4. Border Discontinuity Analysis (Section 4)
  a. Run `00_setup.R`  
  b. Run `border_analysis/11_define_borders.R` to define municipal border segments.  
  c. Run `border_analysis/12_build_sample.R` to build transaction-level border samples from deed, deed-HMDA, and MLS datasets.  
  d. Run `border_analysis/13_main_analysis.R` to replicate main regression results.

### 5. Output
All output files will be saved in the `/output/` directory.

---

## Notes

### Data Access and Availability
CoreLogic data, complete-count 1940 IPUMS data, HMDA data, and Municipal Incorporation Data are not included in this replication package due to data use restrictions. Intermediate files based on these datasets are also excluded.

Access must be obtained independently:
- **CoreLogic data:** Available from [CoreLogic](https://www.corelogic.com). Other data providers, such as [ATTOM](https://www.attomdata.com), offer similar parcel-level datasets.
- **1940 IPUMS full-count census data:** [IPUMS USA](https://usa.ipums.org/usa/)
- **HMDA (2007–2017):** Available at [CFPB](https://www.consumerfinance.gov/data-research/hmda/) and [ICPSR](https://www.icpsr.umich.edu/web/ICPSR/series/226)
- **Municipal Incorporation Data:** [Goodman (2023) GitHub Repository](https://github.com/cbgoodman/muni-incorporation/)

*The results in the paper are fully replicable using these external datasets along with the provided code and raw inputs included in this package.*

### Data Preparation Assumptions
- Tax assessor, deed, and MLS records must be merged via consistent parcel IDs and split into county-level files. Each file should be named using the format: `fips_[5-digit county FIPS code].csv`.
- Deed records must be **matched to HMDA data** using **Census tract**, **mortgage amount**, and **lender name**. For reference, Stephen Billings provides a comprehensive guide and example code for this matching process, available [here](https://sites.google.com/a/colorado.edu/stephen-billings/code).
- All parcel-level files must be restricted to single-family residences, identified using the `property type` and `land use` variables.
- These preprocessing steps must be completed before running any of the scripts.

### Working Directory
Ensure the root directory of the replication package is set as your working directory before executing scripts. This ensures all relative file paths resolve correctly.
