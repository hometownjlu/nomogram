########################################################################
# Logistic Regression Model to Predict Matching for medical students applying to OBGYN: Source All
# All_ERAS_data_merged.R
# Denver Health and Hospital Authority, 2020

# *Objective: * We sought to construct and validate a model that predict a medical student's chances of matching into a categorical obstetrics and gynecology residency position.
  
  # This file is needed to bring together the data from all the years of match data available.  The data comes from the AAMC from the Archives section of the Residency Program Director Work Station.  
  # https://www.dropbox.com/s/wfv7oqpdhdzjlsr/AAMC%20download.mov?dl=0

#Match Status for Monday vs. for Friday

#Track Allison Strauss's course:
#An applicant applies to a categorical OBGYN position.  Variable that shows this is `Tracks Applied by Applicant_1`.  

#Allison did not match so then she goes into the SOAP to apply for a preliminary residency position.  The variable that shows she did NOT match categorically and went into the SOAP is `SOAP Track applied by Applicant`.  

#Then Allison applies to preliminary OBGYN residency positions.  The variable that shows she applied to preliminary residency spots was `SOAP Track Applied by Applicant`.  

#Then Allison does not get into a preliminary OBGYN residency position.  There is no variable to show this.  The data does show the `SOAP Match Status` variable as "Fully Matched" so when she matched into family medicine this flag went up as "Fully Matched".  

#They way we know that she is not an obgyn resident is because in the NPI database her taxonomy code shows up as "Family Medicine".  


#Multi-collinearity?
#Factor selection?
#More variables?

  
  # Set libPaths.
  .libPaths("/Users/tylermuffly/.exploratory/R/3.6")
  
  # Load required packages.
  library(janitor)
  library(lubridate)
  library(hms)
  library(tidyr)
  library(stringr)
  library(readr)
  library(forcats)
  library(RcppRoll)
  library(dplyr)
  library(tibble)
  library(bit64)
  library(exploratory)
  library(summarytools)
  library(VennDiagram)
  
  here::set_here()  #set_here() creates an empty file named .here, by default in the current directory.Sets root.  
  here::here()
  #May need to run this file line-by-line (CRTL+Enter) by hand. 
  
  # Steps to produce GOBA_list_of_people_who_all_matched_into_OBGYN ----
  
  # Read in all data of GOBA scrapes ----
  # We start with a list of FPMRS physicians and the year that they were boarded called all_bound_together.csv.  The data is filtered for providers who are retired, not in the United States, and has a unique random id.  
  
  # #Read directly from Dropbox, workforce, scraper, Scraper_results_2019
  a1 <- read.csv(url("https://www.dropbox.com/s/81s4sfltiqwymq1/Downloaded%20%289035315-9050954%29%20%282019-08-13%2022.csv?raw=1"))
  a2 <- read.csv(url("https://www.dropbox.com/s/x2q4kn9w0z92em0/Downloaded%20%289037771-9050954%29%20%282019-08-27%2019-21-01%29.csv?raw=1"))
  a3 <- read.csv(url("https://www.dropbox.com/s/p7eggr3w9trhoka/Physicians%20%281-100%29%20%282019-09-06%2017-29-12%29.csv?raw=1"))
  a4 <- read.csv(url("https://www.dropbox.com/s/jke52sy6j0mhyg9/Physicians%20%289e%2B05-6e%2B05%29%20%282019-09-09%2006-29-19%29.csv?raw=1"))
  a5 <- read.csv(url("https://www.dropbox.com/s/gv5qh8jp0mnsoii/Physicians%20%289e%2B06-9032700%29%20%282019-09-08%2006-48-56%29.csv?raw=1"))
  a6 <- read.csv(url("https://www.dropbox.com/s/0lfpdmz7wnj4dae/Physicians%20%28100-10000%29%20%282019-09-06%2019-31-29%29.csv?raw=1"))
  a7 <- read.csv(url("https://www.dropbox.com/s/6ym2y1b4pf1ustt/Physicians%20%2810000-29000%29%20%282019-09-06%2022-53-42%29.csv?raw=1"))
  a8 <- read.csv(url("https://www.dropbox.com/s/6ym2y1b4pf1ustt/Physicians%20%2810000-29000%29%20%282019-09-06%2022-53-42%29.csv?raw=1"))
  a9 <- read.csv(url("https://www.dropbox.com/s/awa08ncbs3c27vg/Physicians%20%28971758-9032700%29%20%282019-09-09%2006-29-59%29.csv?raw=1"))
  a10 <- read.csv(url("https://www.dropbox.com/s/35cte66ijjkwixv/Physicians%20%289000023-8995000%29%20%282019-09-08%2008-54-45%29.csv?raw=1"))
  a11 <- read.csv(url("https://www.dropbox.com/s/og76ky1qolmfo36/Physicians%20%289001120-9032700%29%20%282019-09-08%2014-56-13%29.csv?raw=1"))
  a12 <- read.csv(url("https://www.dropbox.com/s/xep4t7vrmy0so5f/Physicians%20%289014500-9016500%29%20%282019-09-09%2017-29-37%29.csv?raw=1"))
  a13 <- read.csv(url("https://www.dropbox.com/s/0fdaeiqcdxuu4p3/Physicians%20%289014500-90146500%29%20%282019-09-09%2017-25-04%29.csv?raw=1"))
  a14 <- read.csv(url("https://www.dropbox.com/s/1kjeumeyc6rkqaw/Physicians%20%289016500-9019500%29%20%282019-09-09%2017-37-30%29.csv?raw=1"))
  a15 <- read.csv(url("https://www.dropbox.com/s/npak5lc1oqgzxff/Physicians%20%289019500-9029500%29%20%282019-09-09%2017-58-01%29.csv?raw=1"))
  a16 <- read.csv(url("https://www.dropbox.com/s/pu9n1cz62s9rw33/Physicians%20%289029500-9059500%29%20%282019-09-09%2018-12-26%29.csv?raw=1"))
  a17 <- read.csv(url("https://www.dropbox.com/s/afy2x8sn5aiwhls/Physicians%20%289035315-9032700%29%20%282019-09-08%2007-36-38%29.csv?raw=1"))
  a18 <- read.csv(url("https://www.dropbox.com/s/yyb56grdml8r3u2/Physicians%20%289035315-9032700%29%20%282019-09-08%2010-52-04%29.csv?raw=1"))
  a19 <- read.csv(url("https://www.dropbox.com/s/eb2ys0rhrej57gi/Physicians%20%289035315-9032700%29%20%282019-09-08%2010-57-51%29.csv?raw=1"))
  a20 <- read.csv(url("https://www.dropbox.com/s/0icba0c7fiykfg6/Physicians%20%289050954-9030000%29%20%282019-09-07%2021-56-03%29.csv?raw=1"))
  a21 <- read.csv(url("https://www.dropbox.com/s/3myst0596aqn96e/Physicians_total_drop_na_29.csv?raw=1"))
  a22 <- read.csv(url("https://www.dropbox.com/s/bdxfcw0iq9etp77/Physicians_total_left_join_27.csv?raw=1"))
  
  #Read directly from Dropbox, workforce, scraper, GOBA_December_2019_Pull
  a23 <- read.csv(url("https://www.dropbox.com/s/0tia58u15r6deok/Physicians%20%289017048-9007048%29%20%282019-12-23%2008-40-42%29.csv?raw=1"))
  a24 <- read.csv(url("https://www.dropbox.com/s/xzx12mxjjoetf5m/Physicians%20%289027048-9017048%29%20%282019-12-22%2016-53-04%29.csv?raw=1"))
  a25 <- read.csv(url("https://www.dropbox.com/s/3lssg0qzhvvvnac/Physicians%20%289029730-9050000%29%20%282020-01-27%2006-53-03%29.csv?raw=1"))
  a26 <- read.csv(url("https://www.dropbox.com/s/dwjfszn6rbgcxd3/Physicians%20%289032048-9027048%29%20%282019-12-22%2014-30-40%29.csv?raw=1"))
  a27 <- read.csv(url("https://www.dropbox.com/s/yiqm06tooy6skpj/Physicians%20%289037048-9032048%29%20%282019-12-22%2013-22-42%29.csv?raw=1"))
  a28 <- read.csv(url("https://www.dropbox.com/s/bjbvq6xi6izbwl4/Physicians%20%289038000-1%29%20%282020-01-03%2017-06-20%29.csv?raw=1"))
  a29 <- read.csv(url("https://www.dropbox.com/s/lrkgxasq1u8979b/Physicians%20%289041048-9037048%29%20%282019-12-22%2012-25-57%29.csv?raw=1"))
  a30 <- read.csv(url("https://www.dropbox.com/s/fa43ujcfl60ir93/Physicians%20%289041048-9042048%29%20%282019-12-21%2016-51-37%29.csv?raw=1"))
  a31 <- read.csv(url("https://www.dropbox.com/s/y01mt2zt1y7vrex/Physicians%20%289041048-9043048%29%20%282019-12-21%2017-14-39%29.csv?raw=1"))
  a32 <- read.csv(url("https://www.dropbox.com/s/a7n3lby7velswmn/Physicians%20%289041048-9043048%29%20%282019-12-22%2008-51-01%29.csv?raw=1"))
  a33 <- read.csv(url("https://www.dropbox.com/s/y5fc6qcjsdox89k/Physicians%20%289050000-9038000%29%20%282020-01-03%2018-20-19%29.csv?raw=1"))
  
  
  #Read directly from Dropbox, workforce, scraper, Old Mac GOBA Pulls
  a34 <- read.csv(url("https://www.dropbox.com/s/h4bpf3tysmklq18/Physicians%20%289041048-9043048%29%20%282019-12-21%2017-14-39%29.csv?raw=1"))
  a35 <- read.csv(url("https://www.dropbox.com/s/94lih4dnxel8o2s/Physicians%20%281-9050542%29%20%282019-10-22%2019-52-47%29.csv?raw=1"))
  a36 <- read.csv(url("https://www.dropbox.com/s/ivm9cdr42fsye9l/Physicians%20%289041048-9042048%29%20%282019-12-21%2016-51-37%29.csv?raw=1"))
  a37 <- read.csv(url("https://www.dropbox.com/s/uc3frk69k0eiybv/Physicians%20%289041048-9043048%29%20%282019-12-22%2008-51-01%29.csv?raw=1"))
  a38 <- read.csv(url("https://www.dropbox.com/s/upyiagiijk1dz1n/Physicians%20%2817479-9050542%29%20%282019-10-26%2012-03-15%29.csv?raw=1"))
  a39 <- read.csv(url("https://www.dropbox.com/s/whxdypbi3q1eg89/Physicians%20%289e%2B06-9032700%29%20%282019-09-08%2006-48-56%29.csv?raw=1"))
  a40 <- read.csv(url("https://www.dropbox.com/s/tdu6js4jgmlgzk3/Physicians%20%289017048-9007048%29%20%282019-12-23%2008-40-42%29.csv?raw=1"))
  a41 <- read.csv(url("https://www.dropbox.com/s/ecoddjv1ivu8tkb/Physicians%20%289050000-9038000%29%20%282020-01-03%2018-20-19%29.csv?raw=1"))
  a42 <- read.csv(url("https://www.dropbox.com/s/p0t6tfevsklsxx9/Physicians%20%289032048-9027048%29%20%282019-12-22%2014-30-40%29.csv?raw=1"))
  a43 <- read.csv(url("https://www.dropbox.com/s/z5z3m9vbxmdd8hf/Physicians%20%2824456-9050542%29%20%282019-10-28%2020-35-42%29.csv?raw=1"))
  a44 <- read.csv(url("https://www.dropbox.com/s/0zizjata2bdohdo/Physicians%20%289037048-9032048%29%20%282019-12-22%2013-22-42%29.csv?raw=1"))
  a45 <- read.csv(url("https://www.dropbox.com/s/gpz31s436i9ev06/Physicians%20%289027048-9017048%29%20%282019-12-22%2016-53-04%29.csv?raw=1"))
  a46 <- read.csv(url("https://www.dropbox.com/s/jngn8o513mtawif/Physicians%20%289e%2B05-6e%2B05%29%20%282019-09-09%2006-29-19%29.csv?raw=1"))
  a47 <- read.csv(url("https://www.dropbox.com/s/qc3nmzgbv2lo5as/Physicians%20%289038000-1%29%20%282020-01-03%2017-06-20%29.csv?raw=1"))
  a48 <- read.csv(url("https://www.dropbox.com/s/uw6oj0ofkkvxi6n/Physicians%20%28100-10000%29%20%282019-09-06%2019-31-29%29.csv?raw=1"))
  a49 <- read.csv(url("https://www.dropbox.com/s/ucvzbcmenatfatx/Physicians%20%2810000-29000%29%20%282019-09-06%2022-53-42%29.csv?raw=1"))
  a50 <- read.csv(url("https://www.dropbox.com/s/kxbtov4x0t0pd6q/Physicians%20%2824456-9050542%29%20%282019-10-29%2006-54-22%29.csv?raw=1"))
  a51 <- read.csv(url("https://www.dropbox.com/s/mdmjy2vjclb8l5f/Physicians%20%289041048-9037048%29%20%282019-12-22%2012-25-57%29.csv?raw=1"))
  
  #added on 3/7/2020
  a53 <- read.csv(url("https://www.dropbox.com/s/uqu52z9seexace9/Physicians%20%289010000-9024666%29%20%282020-02-25%2019-44-45%29.csv?raw=1"))
  a55 <- read.csv(url("https://www.dropbox.com/s/lt2vtk2d3nz4gff/Physicians%20%288000083-8041022%29%20%282020-02-23%2014-52-06%29.csv?raw=1"))
  a56 <- read.csv(url("https://www.dropbox.com/s/w62lq7ootdj6tnd/Physicians%20%289010000-9024666%29%20%282020-02-25%2021-45-40%29.csv?raw=1"))
  a59 <- read.csv(url("https://www.dropbox.com/s/nh4ppeg4r8q5jpi/Physicians%20%289013114-9024666%29%20%282020-02-26%2018-00-24%29.csv?raw=1"))
  a60 <- read.csv(url("https://www.dropbox.com/s/e5sr31gnee0ppgz/Physicians%20%281-9060000%29%20%282020-02-22%2009-39-54%29.csv?raw=1"))
  a61 <- read.csv(url("https://www.dropbox.com/s/k2h99u8fjz95cur/Physicians%20%281-9060000%29%20%282020-02-22%2009-41-10%29.csv?raw=1"))
  a62 <- read.csv(url("https://www.dropbox.com/s/n5gf97s4uq4nxj4/Physicians%20%281-847312%29%20on%202-22.2020.csv?raw=1"))
  
  #Add March 2020 scrapes 
  a63 <- read.csv(url("https://www.dropbox.com/s/lhoqdltq4f0iodk/Physicians%20%289030000-9024666%29%20%282020-03-07%2016-45-56%29.csv?raw=1"))
  a64 <- read.csv(url("https://www.dropbox.com/s/sx85vsvodmil8h6/Physicians%20%289040000-9030000%29%20%282020-03-08%2014-50-09%29.csv?raw=1"))
  a65 <- read.csv(url("https://www.dropbox.com/s/1yzghhwt63294t1/Physicians%20%289050000-9040000%29%20%282020-03-08%2020-12-49%29.csv?raw=1"))
  
  
  #ABOG 2013 from SGS Bastow project from Dropbox/ workforce/ scraper/ 2013 data
  a52 <- read.csv(url("https://www.dropbox.com/s/4ml8wdoijw67n7g/abog%2012.21.2013.csv?raw=1")) %>%
    dplyr::rename(userid = ID) %>%
    dplyr::mutate(`Certification 2` = dplyr::recode(Certification.2, `Female Pelvic Medicine and Reconstructive Surgery` = "FPM")) %>%
    dplyr::rename(sub1 = Certification.2)
  
  # # Bind together all the individual scrapes ----
  # # Steps to produce the output
  all_a_dataframes <- a1 %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    bind_rows(a2, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a3, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a4, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a5, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a6, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a7, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a8, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a9, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a10, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a11, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a12, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a13, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a14, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a15, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a16, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a17, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a18, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a19, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a20, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a21, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a22, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a23, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a24, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a25, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a26, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a27, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a28, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a29, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a30, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a31, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a32, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a33, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a34, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a35, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a36, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a37, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a38, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a39, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a40, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a41, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a42, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a43, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a44, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a45, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a46, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a47, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a48, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a49, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a50, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a51, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a52, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a53, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a55, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a56, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a59, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a60, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a61, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a62, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE)%>%
    bind_rows(a63, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a64, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    bind_rows(a65, id_column_name = "ID", current_df_name = "Physicians_9037048_9032048_2019_12_22_13_22_42", force_data_type = TRUE) %>%
    select(-contains("new"))
  
  readr::write_csv(all_a_dataframes, "~/Dropbox/Rui/data/all_a_dataframes.csv")
  all_a_dataframes <- readr::read_csv("~/Dropbox/Rui/data/all_a_dataframes.csv")
  
######################################################################################
# We needed this data because it is a check about who is an OBGYN.  The ERAS data only tells us who applied.  The GOBA list tells us who matched.  There is no public information about residents available on Physician Compare, NPPES or Doximity beyond the basics of address.  
  
all_bound_together <- all_a_dataframes %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    dplyr::distinct(userid, .keep_all = TRUE) %>%
    dplyr::select(-starts_with("ID.new")) %>%
    #dplyr::filter(sub1 %in% c("FPM", "Female Pelvic Medicine & Reconstructive Surgery")) %>%
    dplyr::arrange(name) %>%
    dplyr::select(userid:orig_bas) %>%
    dplyr::mutate(unique_random_id = (userid*3.1415926535) - 3, unique_random_id = round(unique_random_id, digits = 0)) %>%
    dplyr::filter(sub1certStatus %nin% c("Retired", "Not Currently Certified")) %>%
    dplyr::filter(sub2certStatus %nin% c("Retired", "Not Currently Certified")) %>%
    dplyr::filter(certStatus %nin% c("Retired", "Not Currently Certified")) %>%
    dplyr::filter(!is.na(state)) %>%
    dplyr::filter(state != "ON") %>%
    dplyr::filter(clinicallyActive !="No") %>%
    tidyr::separate(name, into = c("name", "suffix"), sep = "\\s*\\,\\s*", remove = TRUE, convert = TRUE) %>%
    mutate(firstname = humaniformat::first_name(name)) %>%
    mutate(lastname = humaniformat::last_name(name)) %>%
    select(-suffix, -city, -state, -startDate, -certStatus, -mocStatus, -sub1, -sub1startDate, -sub1certStatus, -sub1mocStatus, -sub2, -sub2startDate, -sub2certStatus, -sub2mocStatus, -clinicallyActive, -orig_sub, -x_sub_orig, -orig_bas, -unique_random_id)
  
  dim(all_bound_together)
  colnames(all_bound_together)
  head(all_bound_together, 200)
  dplyr::glimpse(all_bound_together)
  #View(all_bound_together)
  
  # Write the final bound scraper to disk ----
  readr::write_rds(all_bound_together, "/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/list of people who all matched into OBGYN.rds")
  
  
############################################################
#Bind each year of data together
  
  #2019 archive ----
  # Steps to produce archive_2019_2
  `archive_2019_2` <- exploratory::read_excel_file( "/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2019 All Data 2.xlsx", sheet = "e79bee75-b572-4e23-ba50-6b5b42f", na = c('','NA'), skip=0, col_names=TRUE, trim_ws=TRUE, col_types="text") %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame()
  
  # Steps to produce the output
  archive2019 <- exploratory::read_excel_file( "/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2019 All Data 1.xlsx", sheet = "642b9f43-7b4c-4ea1-8df7-00a8b42", na = c('','NA'), skip=0, col_names=TRUE, trim_ws=TRUE, col_types="text") %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    #left_join(archive_2019_2, by = c("AAMC ID" = "AAMC ID")) %>%  #totally duplicates of everything in first set
    unite(`Applicant Name`, `First Name`, `Last Name`, sep = " ", remove = FALSE, na.rm = FALSE) %>%
    select(-`Last Name`, -`First Name`) %>%
    dplyr::select(`AAMC ID`, `Applicant Name`, `Medical Education or Training Interrupted`, 
                  #ACLS, 
                  #BLS, 
                  #`Malpractice Cases Pending`, 
                  #`Medical Licensure Problem`, 
                  #PALS, 
                  `Felony Conviction`, `Alpha Omega Alpha`, `Tracks Applied by Applicant`,
                  #Citizenship, 
                  `Date of Birth`, Gender, `Gold Humanism Honor Society`, `Military Service Obligation`, `Participating as a Couple in NRMP`, `Self Identify`, 
                  #`Sigma Sigma Phi`, 
                  `US or Canadian Applicant`, `Visa Sponsorship Needed`, #`Higher Education Degree`, 
                  `Medical Degree`, `Medical School of Graduation`, `USMLE Step 1 Score`, `Tracks Applied by Applicant`, `Count of Non Peer Reviewed Online Publication`, `Count of Oral Presentation`, `Count of Other Articles`, `Count of Peer Reviewed Book Chapter`, `Count of Peer Reviewed Journal Articles/Abstracts`, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`, `Count of Peer Reviewed Online Publication`, `Count of Poster Presentation`, `Count of Scientific Monograph`, #`OBGYN Grade--10`, 
                  `Applicant Name`, `Misdemeanor Conviction`,
                  
                  #New variables to include for feature engineering.  Must be included for each year of data.   
                  `Medical School Type`, `USMLE Step 2 CK Score`, #`Language Fluency`, 
                  #`Higher Education Degree_1`, `Higher Education Degree_2`
    ) %>%
    #dplyr::rename(`Applicant Name` = PERSONAL_31) %>%
    dplyr::rename(`Step_2_CK` = `USMLE Step 2 CK Score`) %>%
    dplyr::mutate(`US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
    dplyr::mutate(Gender = dplyr::recode(Gender, Female = "Female"), Gender = dplyr::recode(Gender, Female = "Female", Male = "Male", `No Response` = "Female")) %>%
    #dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), #ACLS = factor(ACLS), BLS = factor(BLS), 
                  #`Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Medical Licensure Problem` = factor(`Medical Licensure Problem`), 
                  #PALS = factor(PALS), 
                  `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (AOA) elections held during senior year` = "Elections_Senior_Year", `Alpha Omega Alpha (Member of AOA)` = "Yes", `No Alpha Omega Alpha (AOA) chapter at my school` = "No"), #`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, , .missing = "No"), 
                  `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`)) %>%
    #filter(!is.na(`Limiting Factors`)) %>%
    dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `Gold Humanism Honor Society (Member of GHHS)` = "Yes", .missing = "Not a Member")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`)) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), Match_Status = dplyr::recode(`Tracks Applied by Applicant`, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did not match")) %>%
    reorder_cols(Match_Status) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched"), `Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `No Gold Humanism Honor Society (GHHS) chapter at my school` = "No", `Not a Member` = "Not_a_Member", Yes = "Yes")) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "Did_Not_Match", Matched = "Matched")) %>%
    dplyr::select(-`Tracks Applied by Applicant`) %>%
    dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Elections in Senior year` = "Senior_Year_Elections", No = "No", `No chapter` = "No_Chapter", Yes = "Yes"), 
                  #Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), 
          `Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White")) %>%
    #filter(!is.na(`Self Identify`)) %>%
    #dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `No Sigma Sigma Phi (SSP) chapter at my school` = "No_Chapter", `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", .default = "No")) %>%
    #dplyr::select(-`Higher Education Degree`) %>%
    dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD")) %>%
    filter(!is.na(`Medical Degree`)) %>%
    dplyr::mutate(`Medical Degree` = factor(`Medical Degree`), 
                  #`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, , .missing = "Not_a_member"), 
                  #`Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), 
                  `Self Identify` = factor(`Self Identify`), `Military Service Obligation` = factor(`Military Service Obligation`)) %>%
    #Citizenship = factor(Citizenship)) %>%
    #dplyr::select(-`Felony Conviction`)) %>%
    #dplyr::mutate(`OBGYN Grade--10` = factor(`OBGYN Grade--10`)) %>%
    #dplyr::select(-`OBGYN Grade--10`) %>%
    dplyr::mutate(Year = 2019) %>%
    mutate(DOB = excel_numeric_to_date(`Date of Birth`)) %>%
    #dplyr::mutate(DOB = lubridate::mdy(`Date of Birth`)) %>%
    #dplyr::rename(DOB = `Date of Birth`) %>%
    dplyr::mutate(`Current date` = mdy("01/01/2019")) %>%
    dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age)/365) %>%
    filter(!is.na(Age) & Age >= 24) %>%
    dplyr::select(c(-`Current date`, -DOB)) %>%
    dplyr::mutate(Match_Status = factor(Match_Status)) %>%
    clean_names(case = "parsed") %>%
    #dplyr::mutate(Year = dplyr::recode(Year, `2017` = "2018"), 
                  #Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, No_Chapter = "No", Not_a_member = "No", Yes_Member = "Yes"),
    #plyr::mutate(Medical_Licensure_Problem = dplyr::recode(Medical_Licensure_Problem, N = "No", Y = "Yes")) %>%
    #dplyr::rename(`Medical Licensure Problem` = Medical_Licensure_Problem) %>%
    dplyr::rename(Type_of_medical_school = `Medical_School_Type`) %>%
    select(-Felony_Conviction, -Date_of_Birth, -Misdemeanor_Conviction) %>%
    dplyr::mutate("Malpractice_Cases_Pending" = "No") %>%
    dplyr::mutate("Medical Licensure Problem" = "No")  %>%
    dplyr::mutate("Felony Conviction" = "No") %>%
    dplyr::mutate("Misdemeanor_Conviction" = "No") %>%
    dplyr::mutate("Sigma_Sigma_Phi" = "No") %>%
    mutate(Citizenship = US_or_Canadian_Applicant)
    
  colnames(archive2019) #Missing ACLS, Missing BLS, Missing PALS, 
  #View(archive2019)
  
  
  # 2018_archive ----
  #2018 does pull in Medical_School_of_Graduation
  archive2018 <- exploratory::read_delim_file(here::here("/data/Archives/2018_archive.csv") , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = ".", grouping_mark = "," ), trim_ws = TRUE , progress = FALSE) %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    dplyr::select(`AAMC ID`, `Applicant Name`, `Medical Education or Training Interrupted`, ACLS, BLS, `Malpractice Cases Pending`, `Medical Licensure Problem`, PALS, `Felony Conviction`, `Alpha Omega Alpha`, Citizenship, `Date of Birth`, Gender, `Gold Humanism Honor Society`, `Military Service Obligation`, `Participating as a Couple in NRMP`, `Self Identify`, `Sigma Sigma Phi`, `US or Canadian Applicant`, `Visa Sponsorship Needed`, #`Higher Education Degree`, 
           `Medical Degree`, `Medical School of Graduation`, `USMLE Step 1 Score`, `Tracks Applied by Applicant`, `Count of Non Peer Reviewed Online Publication`, `Count of Oral Presentation`, `Count of Other Articles`, `Count of Peer Reviewed Book Chapter`, `Count of Peer Reviewed Journal Articles/Abstracts`, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`, `Count of Peer Reviewed Online Publication`, `Count of Poster Presentation`, `Count of Scientific Monograph`, #`OBGYN Grade--10`, 
           `Applicant Name`, `Misdemeanor Conviction`,
        
           #New variables to include for feature engineering.  Must be included for each year of data.   
           `Medical School Type`, `USMLE Step 2 CK Score`, #`Language Fluency`, 
           #`Higher Education Degree_1`, `Higher Education Degree_2`
           ) %>%
    #dplyr::rename(`Applicant Name` = PERSONAL_31) %>%
    dplyr::rename(`Step_2_CK` = `USMLE Step 2 CK Score`) %>%
    dplyr::mutate(`US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
    dplyr::mutate(Gender = dplyr::recode(Gender, Female = "Female"), Gender = dplyr::recode(Gender, Female = "Female", Male = "Male", `No Response` = "Female")) %>%
    dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), ACLS = factor(ACLS), BLS = factor(BLS), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Medical Licensure Problem` = factor(`Medical Licensure Problem`), PALS = factor(PALS), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (AOA) elections held during senior year` = "Elections_Senior_Year", `Alpha Omega Alpha (Member of AOA)` = "Yes", `No Alpha Omega Alpha (AOA) chapter at my school` = "No"), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, , .missing = "No"), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`)) %>%
    #filter(!is.na(`Limiting Factors`)) %>%
    dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `Gold Humanism Honor Society (Member of GHHS)` = "Yes", .missing = "Not a Member")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`)) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), Match_Status = dplyr::recode(`Tracks Applied by Applicant`, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did not match")) %>%
    reorder_cols(Match_Status) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched"), `Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `No Gold Humanism Honor Society (GHHS) chapter at my school` = "No", `Not a Member` = "Not_a_Member", Yes = "Yes")) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "Did_Not_Match", Matched = "Matched")) %>%
    dplyr::select(-`Tracks Applied by Applicant`) %>%
    dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Elections in Senior year` = "Senior_Year_Elections", No = "No", `No chapter` = "No_Chapter", Yes = "Yes"), Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), `Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White")) %>%
    #filter(!is.na(`Self Identify`)) %>%
    dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `No Sigma Sigma Phi (SSP) chapter at my school` = "No_Chapter", `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", .default = "No")) %>%
    #dplyr::select(-`Higher Education Degree`) %>%
    dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD")) %>%
    filter(!is.na(`Medical Degree`)) %>%
    dplyr::mutate(`Medical Degree` = factor(`Medical Degree`), `Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, , .missing = "Not_a_member"), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Self Identify` = factor(`Self Identify`), `Military Service Obligation` = factor(`Military Service Obligation`), Citizenship = factor(Citizenship)) %>%
    dplyr::select(-`Felony Conviction`) %>%
    #dplyr::mutate(`OBGYN Grade--10` = factor(`OBGYN Grade--10`)) %>%
    #dplyr::select(-`OBGYN Grade--10`) %>%
    dplyr::mutate(Year = 2018) %>%
    dplyr::mutate(Positions_offered = 1336, Year = factor(Year)) %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2018` = "2017"), `Date of Birth` = mdy(`Date of Birth`)) %>%
    dplyr::rename(DOB = `Date of Birth`) %>%
    dplyr::mutate(`Current date` = mdy("01/01/2017")) %>%
    dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age)/365) %>%
    filter(!is.na(Age) & Age >= 24) %>%
    dplyr::select(-`Current date`, - DOB, - Positions_offered) %>%
    dplyr::mutate(Match_Status = factor(Match_Status)) %>%
    clean_names(case = "parsed") %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2017` = "2018"), Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, No_Chapter = "No", Not_a_member = "No", Yes_Member = "Yes"), Medical_Licensure_Problem = dplyr::recode(Medical_Licensure_Problem, N = "No", Y = "Yes")) %>%
    dplyr::rename(`Medical Licensure Problem` = Medical_Licensure_Problem) %>%
    dplyr::rename(Type_of_medical_school = `Medical_School_Type`)
  
  # 2017 data -----
  #archive2017$Medical_school_name
  archive2017 <- exploratory::read_delim_file(here::here("/data/Archives/2017_archive.csv"), ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = ".", grouping_mark = "," ), trim_ws = TRUE , progress = FALSE) %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    filter(ACLS != "06/30/2018") %>%
    dplyr::select(`AAMC ID`, `Applicant Name`, `Medical Education or Training Interrupted`, ACLS, BLS, `Malpractice Cases Pending`, `Medical Licensure Problem`, PALS, `Felony Conviction`, `Limiting Factors`, `Alpha Omega Alpha`, Citizenship, `Date of Birth`, Gender, `Gold Humanism Honor Society`, `Military Service Obligation`, `Participating as a Couple in NRMP`, `Self Identify`, `Sigma Sigma Phi`, `US or Canadian Applicant`, `Visa Sponsorship Needed`, `Higher Education Degree`, `Medical Degree`, `Medical School of Graduation`, `Medical School Type`, `USMLE Step 1 Score`, `USMLE Step 2 CK Score`, `Tracks Applied by Applicant`, `Count of Non Peer Reviewed Online Publication`, `Count of Oral Presentation`, `Count of Other Articles`, `Count of Peer Reviewed Book Chapter`, `Count of Peer Reviewed Journal Articles/Abstracts`, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`, `Count of Peer Reviewed Online Publication`, `Count of Poster Presentation`, `Count of Scientific Monograph`, `OBGYN Grade--10`, `Misdemeanor Conviction`) %>%
    dplyr::rename(Step_2_CK = 'USMLE Step 2 CK Score', Type_of_medical_school = `Medical School Type`) %>%
    dplyr::rename(Medical_School_of_Graduation = `Medical School of Graduation`) %>%
    dplyr::filter(`Medical Education or Training Interrupted` != "U.S. Citizen") %>%
    dplyr::mutate(`US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
    dplyr::mutate(Gender = dplyr::recode(Gender, Female = "Female"), Gender = dplyr::recode(Gender, Female = "Female", Male = "Male", `No Response` = "Female")) %>%
    dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), ACLS = factor(ACLS), BLS = factor(BLS), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Medical Licensure Problem` = factor(`Medical Licensure Problem`), PALS = factor(PALS), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (AOA) elections held during senior year` = "Elections_Senior_Year", `Alpha Omega Alpha (Member of AOA)` = "Yes", `No Alpha Omega Alpha (AOA) chapter at my school` = "No"), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, , .missing = "No"), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`)) %>%
    dplyr::filter(!is.na(`Limiting Factors`)) %>%
    dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `Gold Humanism Honor Society (Member of GHHS)` = "Yes", .missing = "Not a Member")) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`)) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), Match_Status = dplyr::recode(`Tracks Applied by Applicant`, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did not match")) %>%
    reorder_cols(Match_Status) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched"), `Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `No Gold Humanism Honor Society (GHHS) chapter at my school` = "No", `Not a Member` = "Not_a_Member", Yes = "Yes")) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "Did_Not_Match", Matched = "Matched")) %>%
    dplyr::select(-`Tracks Applied by Applicant`) %>%
    dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Elections in Senior year` = "Senior_Year_Elections", No = "No", `No chapter` = "No_Chapter", Yes = "Yes"), Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), `Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White")) %>%
    dplyr::filter(!is.na(`Self Identify`)) %>%
    dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `No Sigma Sigma Phi (SSP) chapter at my school` = "No_Chapter", `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", .default = "No")) %>%
    dplyr::select(-`Higher Education Degree`) %>%
    dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD")) %>%
    dplyr::filter(!is.na(`Medical Degree`)) %>%
    dplyr::mutate(`Medical Degree` = factor(`Medical Degree`), `Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, , .missing = "Not_a_member"), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Self Identify` = factor(`Self Identify`), `Military Service Obligation` = factor(`Military Service Obligation`), Citizenship = factor(Citizenship)) %>%
    dplyr::select(-`Felony Conviction`, -`Limiting Factors`) %>%
    dplyr::select(-`OBGYN Grade--10`) %>%
    dplyr::mutate(Year = 2018) %>%
    dplyr::mutate(Year = factor(Year)) %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2018` = "2017"), `Date of Birth` = mdy(`Date of Birth`)) %>%
    dplyr::rename(DOB = `Date of Birth`) %>%
    dplyr::mutate(`Current date` = mdy("01/01/2017")) %>%
    dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age)/365) %>%
    dplyr::filter(!is.na(Age) & Age >= 24) %>%
    dplyr::select(-`Current date`) %>%
    dplyr::mutate(Match_Status = factor(Match_Status)) %>%
    clean_names(case = "parsed") %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2017` = "2017"), Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, No_Chapter = "No", Not_a_member = "No", Yes_Member = "Yes"), Medical_Licensure_Problem = dplyr::recode(Medical_Licensure_Problem, N = "No", Y = "Yes")) %>%
    dplyr::filter(Match_Status != "Atkins, Samantha; Burroughs, Sarah; Cacioppo, Joseph" & Match_Status != "Larson, Kaitlin; Ghadiri, Ali") %>%
    #rename(Medical_school_name = Medical_School_of_Graduation) %>%
    dplyr::filter(Match_Status %in% c("Did_Not_Match", "Matched") & Count_of_Scientific_Monograph != "Ranked" & Age < 100) %>%
    dplyr::select(-DOB) %>%
    dplyr::rename(`Medical Licensure Problem` = Medical_Licensure_Problem)
  
  
  # 2016_archive ----
  # archive2016$Medical_School_of_Graduation
  archive2016 <- exploratory::read_delim_file(here::here("/data/Archives/2016_archive.csv"), ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = "."), trim_ws = TRUE , progress = FALSE) %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    dplyr::mutate(`Current date` = mdy("01/01/2019")) %>%
    dplyr::select(PERSONAL, PERSONAL_4, PERSONAL_6, PERSONAL_8, PERSONAL_19, PERSONAL_26, PERSONAL_28, PERSONAL_31, PERSONAL_34, PERSONAL_45, PERSONAL_51, PERSONAL_52, PERSONAL_59, PERSONAL_65, PERSONAL_79, PERSONAL_80, PERSONAL_82, PERSONAL_84, 
          SCORE_S1, # Step 1 score
          SCORE_CK, #Step 2 CK score
          MEDICAL, MEDICAL_6, MEDICAL_8, EXPERIENCE_12, TRACKSAPPLICANT, TRACKSAPPLICANT_1, PUB_COUNT, PUB_COUNT_1, PUB_COUNT_2, PUB_COUNT_3, PUB_COUNT_4, PUB_COUNT_5, PUB_COUNT_6, PUB_COUNT_7, PUB_COUNT_8, PERSONAL_14, PERSONAL_16, PERSONAL_31,
           
           #`PERSONAL_55`#, `EDUCATION_1`
           
           ) %>%
    dplyr::rename(`Malpractice Cases Pending` = PERSONAL_14) %>%
    dplyr::rename(`Step_2_CK` = SCORE_CK) %>%
    dplyr::mutate(`Malpractice Cases Pending` = dplyr::recode(`Malpractice Cases Pending`, `Malpractice Cases Pending` = "No", N = "No", .missing = "No")) %>%
    dplyr::filter(!is.na(MEDICAL_8)) %>%
    dplyr::rename(`Visa Sponsorship Needed` = PERSONAL_84) %>%
    dplyr::select(-EXPERIENCE_12) %>%
    dplyr::rename(BLS = PERSONAL_8, PALS = PERSONAL_19) %>%
    dplyr::rename(ACLS = PERSONAL_6) %>%
    dplyr::rename(AAMCID = PERSONAL, CouplesMatch = PERSONAL_65) %>%
    filter(ACLS %in% c("Yes", "No")) %>%
    dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
    dplyr::rename(`Alpha Omega Alpha` = PERSONAL_28) %>%
    dplyr::rename(`Applicant Name` = PERSONAL_31) %>%
    dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (Member of AOA)` = "Yes", `AOA elections held during Senior year` = "Elections_Senior_Year", `No AOA Chapter At My School` = "No", .missing = "No")) %>%
    dplyr::rename(`Gold Humanism Honor Society` = PERSONAL_52) %>%
    dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `GHHS (Member of GHHS)` = "Yes", `No GHHS chapter at my school` = "No", .missing = "Not_a_Member")) %>%
    dplyr::rename(`USMLE Step 1 Score` = SCORE_S1) %>%
    dplyr::mutate(`USMLE Step 1 Score` = parse_number(`USMLE Step 1 Score`)) %>%
    filter(!is.na(`USMLE Step 1 Score`)) %>%
    dplyr::mutate(Year2016 = 2016) %>%
    dplyr::mutate(Positions_offered = 1265, AAMCID = parse_number(AAMCID), ACLS = factor(ACLS), BLS = factor(BLS), PALS = factor(PALS), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`), Positions_offered = factor(Positions_offered)) %>%
    dplyr::rename(Citizenship = PERSONAL_34) %>%
    dplyr::mutate(Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), Citizenship = factor(Citizenship)) %>%
    dplyr::rename(`Participating as a Couple in NRMP` = CouplesMatch) %>%
    dplyr::mutate(`Participating as a Couple in NRMP` = dplyr::recode(`Participating as a Couple in NRMP`, False = "No", True = "Yes", .missing = "No"), `Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`)) %>%
    dplyr::rename(`Self Identify` = PERSONAL_79) %>%
    filter(ACLS %in% c("Yes", "No")) %>%
    dplyr::mutate(`Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White", .missing = "White")) %>%
    dplyr::rename(`Medical Degree` = MEDICAL) %>%
    dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD", .default = "MD")) %>%
    dplyr::rename(`Sigma Sigma Phi` = PERSONAL_80) %>%
    dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", `No SSP Chapter At My School` = "No_Chapter", .default = "Not_a_member", .missing = "Not_a_member"), `Self Identify` = factor(`Self Identify`), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Medical Degree` = factor(`Medical Degree`)) %>%
    dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No"), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`)) %>%
    dplyr::rename(`AAMC ID` = AAMCID, `Medical Education or Training Interrupted` = PERSONAL_4, `Misdemeanor Conviction` = PERSONAL_26, `US or Canadian Applicant` = PERSONAL_82) %>%
    filter(TRACKSAPPLICANT %in% c("Ob-Gyn/Preliminary|1076220P0 (Preliminary)", "Obstetrics-Gynecology|1076220C0 (Categorical)")) %>%
    dplyr::select(-TRACKSAPPLICANT_1) %>%
    dplyr::rename(Match_Status = TRACKSAPPLICANT) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did_Not_Match", `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched")) %>%
    dplyr::rename(`Count of Non Peer Reviewed Online Publication` = PUB_COUNT, `Count of Oral Presentation` = PUB_COUNT_1, `Count of Other Articles` = PUB_COUNT_2, `Count of Peer Reviewed Book Chapter` = PUB_COUNT_3, `Count of Peer Reviewed Journal Articles/Abstracts` = PUB_COUNT_4, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = PUB_COUNT_5, `Count of Peer Reviewed Online Publication` = PUB_COUNT_6, `Count of Poster Presentation` = PUB_COUNT_7, `Count of Scientific Monograph` = PUB_COUNT_8) %>%
    reorder_cols(Match_Status) %>%
    dplyr::mutate(Match_Status = factor(Match_Status), `Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), `Misdemeanor Conviction` = factor(`Misdemeanor Conviction`), `Count of Non Peer Reviewed Online Publication` = parse_number(`Count of Non Peer Reviewed Online Publication`)) %>%
    filter(!is.na(`Count of Non Peer Reviewed Online Publication`)) %>%
    dplyr::mutate(`Count of Oral Presentation` = parse_number(`Count of Oral Presentation`), `Count of Other Articles` = parse_number(`Count of Other Articles`), `Count of Peer Reviewed Book Chapter` = parse_number(`Count of Peer Reviewed Book Chapter`), `Count of Peer Reviewed Journal Articles/Abstracts` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts`), `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`), `Count of Peer Reviewed Online Publication` = parse_number(`Count of Peer Reviewed Online Publication`)) %>%
    filter(!is.na(`Count of Peer Reviewed Online Publication`)) %>%
    dplyr::mutate(`Count of Poster Presentation` = parse_number(`Count of Poster Presentation`), `Count of Scientific Monograph` = parse_number(`Count of Scientific Monograph`)) %>%
    dplyr::rename(`Date of Birth` = PERSONAL_45) %>%
    dplyr::mutate(`Date of Birth` = mdy(`Date of Birth`)) %>%
    dplyr::rename(DOB = `Date of Birth`) %>%
    dplyr::mutate(`Current date` = mdy("01/01/2016")) %>%
    dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age/365)) %>%
    filter(Age >= 24) %>%
    filter(!is.na(Age)) %>%
    dplyr::select(-`Current date`) %>%
    dplyr::select(-DOB) %>%
    dplyr::rename(Gender = PERSONAL_51, `Military Service Obligation` = PERSONAL_59, `Malpractice Cases Pending` = `Malpractice Cases Pending`) %>%
    dplyr::mutate(`Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), Gender = factor(Gender), `Military Service Obligation` = factor(`Military Service Obligation`), `US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
    clean_names(case = "parsed") %>%
    dplyr::mutate(Year = 2016, Year = factor(Year)) %>%
    dplyr::select(-Year2016) %>%
    dplyr::rename(Type_of_medical_school = MEDICAL_8) %>%
    dplyr::mutate(Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, Not_a_member = "No", Yes_Member = "Yes", .default = "No"), Type_of_medical_school = factor(Type_of_medical_school)) %>%
    dplyr::rename(`Medical Licensure Problem` = PERSONAL_16) %>%
    dplyr::mutate(`Medical Licensure Problem` = dplyr::recode(`Medical Licensure Problem`, N = "No"), `Medical Licensure Problem` = factor(`Medical Licensure Problem`)) %>%
    dplyr::rename(Medical_School_of_Graduation = MEDICAL_6) %>%
    dplyr::select(-Positions_offered)
  
  
  # 2015_archive  ----
  #archive2015$Medical_School_of_Graduation
  archive2015 <- exploratory::read_delim_file(here::here("data/Archives/2015_archive.csv") , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = "."), trim_ws = TRUE , progress = FALSE) %>%
    readr::type_convert() %>%
    exploratory::clean_data_frame() %>%
    dplyr::select(PERSONAL, PERSONAL_4, PERSONAL_6, PERSONAL_12, PERSONAL_14, PERSONAL_17, PERSONAL_24, PERSONAL_26, PERSONAL_31, PERSONAL_35, PERSONAL_46, PERSONAL_52, PERSONAL_58, PERSONAL_64, PERSONAL_78, PERSONAL_80, PERSONAL_81, PERSONAL_83, USMLE, MEDICAL, MEDICAL_8, TRACKSAPPLICANT, PUB_COUNT, PUB_COUNT_1, PUB_COUNT_2, PUB_COUNT_3, PUB_COUNT_4, PUB_COUNT_5, PUB_COUNT_6, PUB_COUNT_7, PUB_COUNT_8,
           
            MEDICAL_8, #Medical school type         
           `MEDICAL_6`, #Medical school name
           `SCORE_CK`, #`SCORE_S1`, #Step 1 and Step 2 scores
           #`PERSONAL_54`, #Language fluency
           #`EDUCATION_1`
           
           ) %>%
    dplyr::rename(Medical_School_of_Graduation = MEDICAL_6) %>%
    dplyr::rename(Applicant_Name = PERSONAL_31) %>%
    dplyr::rename(Step_2_CK = SCORE_CK) %>%
    dplyr::rename(`Medical Licensure Problem` = PERSONAL_14) %>%
    dplyr::mutate(`Medical Licensure Problem` = dplyr::recode(`Medical Licensure Problem`, `Medical Licensure Problem` = "No", N = "No", Y = "Yes", .missing = "No")) %>%
    filter(!is.na(MEDICAL_8)) %>%
    dplyr::rename(PALS = PERSONAL_17) %>%
    dplyr::rename(ACLS = PERSONAL_6) %>%
    dplyr::rename(AAMCID = PERSONAL) %>%
    filter(ACLS %in% c("Yes", "No")) %>%
    dplyr::rename(`Alpha Omega Alpha` = PERSONAL_26) %>%
    dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (Member of AOA)` = "Yes", `AOA elections held during Senior year` = "Elections_Senior_Year", `No AOA Chapter At My School` = "No", .missing = "No")) %>%
    dplyr::rename(`USMLE Step 1 Score` = USMLE) %>%
    dplyr::mutate(`USMLE Step 1 Score` = parse_number(`USMLE Step 1 Score`)) %>%
    filter(!is.na(`USMLE Step 1 Score`)) %>%
    dplyr::mutate(Year2016 = 2016) %>%
    dplyr::mutate(Positions_offered = 1255, AAMCID = parse_number(AAMCID), ACLS = factor(ACLS), PALS = factor(PALS), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`), Positions_offered = factor(Positions_offered)) %>%
    dplyr::rename(Citizenship = PERSONAL_35) %>%
    dplyr::mutate(Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), Citizenship = factor(Citizenship)) %>%
    dplyr::rename(`Participating as a Couple in NRMP` = PERSONAL_64) %>%
    dplyr::mutate(`Participating as a Couple in NRMP` = dplyr::recode(`Participating as a Couple in NRMP`, False = "No", True = "Yes", .missing = "No")) %>%
    dplyr::rename(`Self Identify` = PERSONAL_78) %>%
    filter(ACLS %in% c("Yes", "No")) %>%
    dplyr::mutate(`Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White", .missing = "White")) %>%
    dplyr::rename(`Medical Degree` = MEDICAL) %>%
    dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD", .default = "MD")) %>%
    dplyr::rename(`Sigma Sigma Phi` = PERSONAL_80) %>%
    dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", `No SSP Chapter At My School` = "No_Chapter", .default = "Not_a_member", .missing = "Not_a_member"), `Self Identify` = factor(`Self Identify`), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Medical Degree` = factor(`Medical Degree`)) %>%
    dplyr::rename(`AAMC ID` = AAMCID, `Medical Education or Training Interrupted` = PERSONAL_4, `Misdemeanor Conviction` = PERSONAL_24, `US or Canadian Applicant` = PERSONAL_81) %>%
    filter(TRACKSAPPLICANT %in% c("Ob-Gyn/Preliminary|1076220P0 (Preliminary)", "Obstetrics-Gynecology|1076220C0 (Categorical)")) %>%
    dplyr::rename(Match_Status = TRACKSAPPLICANT) %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did_Not_Match", `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched")) %>%
    dplyr::rename(`Count of Non Peer Reviewed Online Publication` = PUB_COUNT, `Count of Oral Presentation` = PUB_COUNT_1, `Count of Other Articles` = PUB_COUNT_2, `Count of Peer Reviewed Book Chapter` = PUB_COUNT_3, `Count of Peer Reviewed Journal Articles/Abstracts` = PUB_COUNT_4, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = PUB_COUNT_5, `Count of Peer Reviewed Online Publication` = PUB_COUNT_6, `Count of Poster Presentation` = PUB_COUNT_7, `Count of Scientific Monograph` = PUB_COUNT_8) %>%
    reorder_cols(Match_Status) %>%
    dplyr::mutate(Match_Status = factor(Match_Status), `Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), `Misdemeanor Conviction` = factor(`Misdemeanor Conviction`), `Count of Non Peer Reviewed Online Publication` = parse_number(`Count of Non Peer Reviewed Online Publication`)) %>%
    filter(!is.na(`Count of Non Peer Reviewed Online Publication`)) %>%
    dplyr::mutate(`Count of Oral Presentation` = parse_number(`Count of Oral Presentation`), `Count of Other Articles` = parse_number(`Count of Other Articles`), `Count of Peer Reviewed Book Chapter` = parse_number(`Count of Peer Reviewed Book Chapter`), `Count of Peer Reviewed Journal Articles/Abstracts` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts`), `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`), `Count of Peer Reviewed Online Publication` = parse_number(`Count of Peer Reviewed Online Publication`)) %>%
    filter(!is.na(`Count of Peer Reviewed Online Publication`)) %>%
    dplyr::mutate(`Count of Poster Presentation` = parse_number(`Count of Poster Presentation`), `Count of Scientific Monograph` = parse_number(`Count of Scientific Monograph`)) %>%
    dplyr::rename(`Date of Birth` = PERSONAL_46) %>%
    dplyr::mutate(`Date of Birth` = mdy(`Date of Birth`)) %>%
    dplyr::rename(DOB = `Date of Birth`) %>%
    dplyr::mutate(`Current date` = mdy("01/01/2015")) %>%
    dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age/365)) %>%
    filter(Age >= 24) %>%
    filter(!is.na(Age)) %>%
    dplyr::mutate(`Misdemeanor Conviction` = dplyr::recode(`Misdemeanor Conviction`, Screened = "No")) %>%
    dplyr::select(-`Current date`) %>%
    dplyr::select(-DOB) %>%
    dplyr::rename(Gender = PERSONAL_52, `Military Service Obligation` = PERSONAL_58) %>%
    dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, Not_a_member = "No")) %>%
    dplyr::rename(`Visa Sponsorship Needed` = PERSONAL_83) %>%
    dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
    filter(!is.na(`Count of Poster Presentation`)) %>%
    dplyr::rename(Year2015 = Year2016) %>%
    dplyr::mutate(Year2015 = factor(Year2015)) %>%
    dplyr::rename(`Malpractice Cases Pending` = PERSONAL_12) %>%
    dplyr::mutate(Gender = factor(Gender), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Military Service Obligation` = factor(`Military Service Obligation`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
    clean_names(case = "parsed") %>%
    dplyr::rename(Year = Year2015) %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2016` = "2015")) %>%
    dplyr::rename(Type_of_medical_school = MEDICAL_8) %>%
    dplyr::mutate(Type_of_medical_school = factor(Type_of_medical_school), Medical_Licensure_Problem = factor(Medical_Licensure_Problem)) %>%
    clean_names(case = "parsed") %>%
    dplyr::select(-Positions_offered) %>%
    dplyr::mutate(Year = dplyr::recode(Year, `2016` = "2015")) %>%
    dplyr::rename(`Medical Licensure Problem` = Medical_Licensure_Problem)
    
  #Checking that all column names are the same ----
  colnamesarchive2015 <- names(archive2015) #"Type_of_medical_school"  
  colnamesarchive2016 <- names(archive2016) #"Medical School Type"  
  colnamesarchive2017 <- names(archive2017)
  colnamesarchive2018 <- names(archive2018) #"Type_of_medical_school"
  colnamesarchive2019 <- names(archive2019)
  
  setdiff(colnamesarchive2015, colnamesarchive2016) #all columns equal
  
  setdiff(colnamesarchive2016, colnamesarchive2017)
  
  setdiff(colnamesarchive2017, colnamesarchive2018)
  
  setdiff(colnamesarchive2018, colnamesarchive2019)
  
  
# all years together ----
  all_years <- 
    bind_rows(archive2015, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
    bind_rows(archive2016, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
    bind_rows(archive2017, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
    bind_rows(archive2018, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
    bind_rows(archive2019, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
  #all_years is 3524 rows at this point
  
    clean_names(case = "parsed") %>%
    
  #New variable of medical school type
    mutate(Type_of_medical_school = dplyr::recode(Type_of_medical_school, `International School,International School` = "International School", `International School,International School,International School` = "International School", `International School,International School,U.S. Public School,International School` = "International School", `International School,U.S. Private School` = "International School", `International School,U.S. Private School,U.S. Private School,U.S. Private School` = "International School", `U.S. Private School,International School` = "U.S. Private School", `U.S. Private School,International School,U.S. Private School,U.S. Private School` = "U.S. Private School", `U.S. Private School,International School,U.S. Public School` = "U.S. Private School", `U.S. Private School,U.S. Private School,International School,U.S. Public School,U.S. Private School` = "U.S. Private School", `U.S. Private School,U.S. Public School` = "U.S. Private School", `U.S. Public School,International School` = "U.S. Public School", `U.S. Public School,International School,International School,International School` = "U.S. Public School", `U.S. Public School,Osteopathic School` = "U.S. Public School", `U.S. Public School,U.S. Private School` = "U.S. Public School", `U.S. Public School,U.S. Public School` = "U.S. Public School",  `International School,U.S. Public School,International School,International School` = "International School")) %>%
    dplyr::rename(USMLE_Step_2_CK_Score = Step_2_CK) %>%

    filter(!is.na(USMLE_Step_2_CK_Score)) %>%
    
    dplyr::mutate(Malpractice_Cases_Pending = dplyr::recode(Malpractice_Cases_Pending, N = "No", No = "No", Y = "Yes"), Malpractice_Cases_Pending = factor(Malpractice_Cases_Pending), Misdemeanor_Conviction = dplyr::recode(Misdemeanor_Conviction, No = "No", Yes = "Yes", .missing = "No"), Misdemeanor_Conviction = factor(Misdemeanor_Conviction)) %>%
    dplyr::select(-AAMC_ID) %>%
    
    filter(!is.na(USMLE_Step_1_Score)) %>%  
    #filtered out 96 people with no Step 1 score, total of 3428 people now in analysis
    
    dplyr::rename(white_non_white = Self_Identify, Couples_Match = Participating_as_a_Couple_in_NRMP) %>%
    dplyr::mutate(Match_Status_Dichot = dplyr::recode(Match_Status, Did_Not_Match = "0", Matched = "1"), Match_Status = dplyr::recode(Match_Status, Did_Not_Match = "No", Matched = "Yes")) %>%
    reorder_cols(Match_Status, Match_Status_Dichot, ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant, USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Year) %>%
    dplyr::mutate(US_or_Canadian_Applicant = dplyr::recode(US_or_Canadian_Applicant, No = "international", Yes = "US senior")) %>%
    dplyr::mutate(Match_Status_Dichot_1 = dplyr::recode(Match_Status_Dichot, `0` = "Did not Match", `1` = "Matched Successfully")) %>%
    #all_years has 2438 people.  
  
    dplyr::mutate(Applicant_Name = str_to_title(Applicant_Name), formatted_names = humaniformat::format_reverse(Applicant_Name), firstname = humaniformat::first_name(formatted_names), lastname = humaniformat::last_name(formatted_names)) %>%

    arrange(lastname) %>%
    # I need to look at matches from both sides.  ERAS shows who applied to OBGYN.  The GOBA_list_of_people_who_all_matched_into_OBGYN data shows who actually got into OBGYN.  
    left_join(GOBA_list_of_people_who_all_matched_into_OBGYN, by = c("lastname" = "lastname", "firstname" = "firstname"), ignorecase=TRUE) %>%
    dplyr::mutate(calculation_1 = name, calculation_1 = dplyr::recode(calculation_1, `Aaron D Campbell, M.D.` = "Matched", .default = "Matched")) %>%
    dplyr::rename(`Matched because present in ABOG database` = calculation_1) %>%
    dplyr::mutate(`Matched because present in ABOG database` = impute_na(`Matched because present in ABOG database`, type = "value", val = "Did not match")) %>%
    dplyr::mutate(`Match stats as defined by ERAS data` = Match_Status, `Match stats as defined by ERAS data` = dplyr::recode(`Match stats as defined by ERAS data`, No = "Did not match", Yes = "Matched")) %>%
    unite(`Unite match data from ABOG and from ERAS`, `Matched because present in ABOG database`, `Match stats as defined by ERAS data`, sep = "_", remove = FALSE) %>%
    
    dplyr::mutate(`Final call if they matched` = `Unite match data from ABOG and from ERAS`) %>%
    
    # Ideas here are that the students who may or may not have matched ended up matching.  Giving people the beneift of the doubt.  For example Elizabeth Clain was called by GOBA as a match but not by ERAS for some reason.  
    dplyr::mutate(`Final call if they matched` = factor(`Final call if they matched`), `Final Final Final` = dplyr::recode(`Final call if they matched`, `Did not match_Did not match` = "Did not match", `Did not match_Larson, Kaitlin; Ghadiri, Ali` = "Did not match", `Did not match_Matched` = "Matched", `Did not match_NA` = "Did not match")) %>%
    filter(Match_Status != "Larson, Kaitlin; Ghadiri, Ali") %>%
    dplyr::select(-Match_Status, -Match_Status_Dichot, -ID_new_new, -ID_new, -ID, -Match_Status_Dichot_1, -formatted_names, -firstname, -lastname, -name, -`Unite match data from ABOG and from ERAS`, -`Matched because present in ABOG database`, -`Match stats as defined by ERAS data`, -`Final call if they matched`, Gold_Humanism_Honor_Society) %>%
    
    # Outcome variable has to be the last column.  
    reorder_cols(Applicant_Name, ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant, USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Year, `Final Final Final`) %>%
    dplyr::rename(Match_Status = `Final Final Final`) %>%
    dplyr::mutate(Match_Status = dplyr::recode_factor(Match_Status, `Did not match` = "Did Not Match", Matched = "Matched", `Matched_Did not match` = "Unsure", Matched_Matched = "Matched")) %>%
    filter(Match_Status %in% c("Did Not Match", "Matched")) %>%
    dplyr::mutate(Count_of_Peer_Reviewed_Book_Chapter = parse_number(Count_of_Peer_Reviewed_Book_Chapter)) %>%
    dplyr::mutate_at(vars(ACLS, Alpha_Omega_Alpha, BLS, Citizenship, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant, Visa_Sponsorship_Needed, white_non_white, Year, Type_of_medical_school), funs(factor)) %>%
    filter(Count_of_Peer_Reviewed_Online_Publication != "Obstetrics-Gynecology|1076220C0 (Categorical)") %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "0", Matched = "1")) %>%
    filter(!is_empty(Match_Status)) %>%
    dplyr::select(-Year) %>%
    filter(Match_Status %nin% c("") & Match_Status != "Matched_NA") %>%
    dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `0` = "No.Match", `1` = "Match")) %>%
    fill(ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant, USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Match_Status, .direction = "down") %>%
    dplyr::mutate(Count_of_Non_Peer_Reviewed_Online_Publication = parse_number(Count_of_Non_Peer_Reviewed_Online_Publication), Match_Status_1 = Match_Status) %>%
    #unite(`USMLE_Step_2_CK_Score`, `Step_2_CK`, sep = "_", remove = FALSE) %>%
    #dplyr::select(-`Step_2_CK`) %>%
    dplyr::select(-ID_new_new_new, -userid, - Match_Status_1) %>%
    #as.numeric(USMLE_Step_2_CK_Score) %>%
    dplyr::filter(Age < 100) %>%
    dplyr::mutate(Gold_Humanism_Honor_Society = dplyr::recode(Gold_Humanism_Honor_Society, Not_a_Member = "No"), Medical_Degree = dplyr::recode(Medical_Degree, `B.A.O.,M.D.` = "MD", `DO/MS` = "DO", `DO/PhD` = "DO", `M.B.,B.S.,M.B.,B.S.` = "MD", `M.B.,B.S.,M.D.` = "MD", `M.D.,M.B.,B.S.` = "MD", `M.D.,M.D.` = "MD", `M.D./Ph.D.,M.D.` = "MD", `M.Surg.,M.B.,B.S.` = "MD", MD = "MD", `M.B.B.Ch.,M.D.,M.Med.` = "MD", `M.D.,M.D./Ph.D.` = "MD", `M.D./Ph.D.,M.B.B.Ch.,M.Med.` = "MD")) %>%
    dplyr::filter(Match_Status %in% c("Match", "Did Not Match")) %>%
    #base::droplevels(all_years$Match_Status) %>%
    dplyr::select(- Malpractice_Cases_Pending) %>% #zero variance feature
    dplyr::select(-Gold_Humanism_Honor_Society) 
  
  colnames(all_years)
  dim(all_years)
  
  total_number_of_applicants <- nrow(archive2015) + nrow(archive2016) + nrow(archive2017) + nrow(archive2018) + nrow(archive2018)
  
  print("The number of applicants to OBGYN at CU was:") 
  print(total_number_of_applicants)
  
  print("The number of matched applicants to OBGYN who applied to CU was:")
  print(nrow(all_years))
  
  print("The number of OBGYNs who are confirmed to be in practice was:")
  print(nrow(GOBA_list_of_people_who_all_matched_into_OBGYN))
  
  # Venn diagram ----
  #https://statisticsglobe.com/venn-diagram-in-r
  #install.packages("VennDiagram")                       # Install VennDiagram package
  #library("VennDiagram")                                # Load VennDiagram package
  
  # grid.newpage()                                        # Move to new plotting page
  # draw.pairwise.venn(area1 = 3524,                        # Create pairwise venn diagram
  #                    area2 = 52346,
  #                    cross.area = 3231,
  #                    col = "red",
  #                    fill = c("pink", "green"),
  #                    alpha = 0.5,
  #                    lty = "blank",
  #                    category = c("Names\nof Residency\napplicants", "Names\nof US\nOBGYNs"))
  
  # NIH dollars by OBGYN Department 2018 ----
  # I could not export working R code from exploratory so I exported the file directly from exploratory as a CSV.  
  nih_dollars <- read_csv(here::here("/data/Ob_Gyn_2018_NIH_dollars_from_blue_ridge_funding_mutate_2.csv"))
  
  ## http://www.brimr.org/NIH_Awards/2018/NIH_Awards_2018.htm
  all_years <- all_years %>% 
    left_join(nih_dollars, by = c("Medical_School_of_Graduation" = "Medical School of Graduation"))%>%
    mutate(NIH_dollars = impute_na(NIH_dollars, type = "value", val = "0")) 

  
  # Steps to produce ACOG_Districts
  ACOG_Districts <- read_csv(file = (here::here("/data/ACOG_Districts.csv")))
    
# all_years1 <- all_years %>% 
#       readr::type_convert() %>%
#       exploratory::clean_data_frame() %>%
#       reorder_cols(Type_of_medical_school) %>%
  #     dplyr::mutate(ACOG_district = Medical_School_of_Graduation) %>%
  # 
  # #Issue is somewhere in here...
  #     dplyr::mutate(ACOG_district = dplyr::recode(ACOG_district, `A.T. Still University of Health Sciences-Kirksville College of Osteopathic Medicine` = "MO", `A.T. Still University–School of Osteopathic Medicine in Arizona` = "AZ", `Alabama College of Osteopathic Medicine` = "AL", `Albany Medical College` = "NY", `Albert Einstein College of Medicine` = "NY", `Albert Einstein College of Medicine of Yeshiva University` = "NY", `Baylor College of Medicine` = "TX", `Boston University School of Medicine` = "MA", `Case Western Reserve University School of Medicine` = "OH", `Central Michigan University College of Medicine` = "MI", `Charles E. Schmidt College of Medicine at Florida Atlantic University` = "FL", `Chicago College of Osteopathic Medicine of Midwestern University` = "IL", `Chicago Medical School at Rosalind Franklin University of Medicine & Science` = "IL", `Columbia University College of Physicians and Surgeons` = "NY", `Columbia University Vagelos College of Physicians and Surgeons` = "NY", `Cooper Medical School of Rowan University` = "NJ", `Creighton University School of Medicine` = "NE", `Des Moines University College of Osteopathic Medicine` = "IA", `Donald and Barbara Zucker School of Medicine at Hofstra/Northwell` = "NY", `Drexel University College of Medicine` = "PA", `Duke University School of Medicine` = "NC", `East Tennessee State University James H. Quillen College of Medicine` = "TN", `Eastern Virginia Medical School` = "VA", `Edward Via College of Osteopathic Medicine–Virginia Campus` = "VA", `Edward Via College of Osteopathic Medicine–Carolinas Campus` = "SC", `Edward Via Virginia College of Osteopathic Medicine` = "VA", `Emory University School of Medicine` = "GA", `Florida International University Herbert Wertheim College of Medicine` = "FL", `Florida State University College of Medicine` = "FL", `Florida State University College of Medicine - Daytona Beach` = "FL", `Florida State University College of Medicine - Ft. Pierce` = "FL", `Florida State University College of Medicine - Orlando` = "FL", `Florida State University College of Medicine - Pensacola` = "FL", `Florida State University College of Medicine - Sarasota` = "FL", `Frank H. Netter MD School of Medicine at Quinnipiac University` = "CT", `Geisel School of Medicine at Dartmouth` = "NH", `Geisinger Commonwealth School of Medicine` = "PA", `George Washington University School of Medicine and Health Sciences` = "DC", `Georgetown University School of Medicine` = "DC", `Georgia Regents University/The University of Georgia Medical Partnership` = "GA", `Harvard Medical School` = "MA", `Howard University College of Medicine` = "DC", `Icahn School of Medicine at Mount Sinai` = "NY", `Indiana University School of Medicine` = "IA", `Johns Hopkins University School of Medicine` = "MD", `Kansas City University of Medicine and Biosciences` = "MO", `Keck School of Medicine of the University of Southern California` = "CA", `Lake Erie College of Osteopathic Medicine` = "PA", `Loma Linda University School of Medicine` = "CA", `Louisiana State University School of Medicine in New Orleans` = "LA", `Louisiana State University School of Medicine in Shreveport` = "LA", `Loyola University Chicago Stritch School of Medicine` = "IL", `Marshall University Joan C. Edwards School of Medicine` = "WV", `Mayo Medical School` = "MN", `McGovern Medical School at the University of Texas Health Science Center at Houston` = "TX", `Medical College of Georgia at Augusta University` = "GA", `Medical College of Georgia at Georgia Regents University` = "GA", `Medical College of Wisconsin` = "WI", `Medical University of South Carolina College of Medicine` = "SC", `Meharry Medical College` = "DC", `Mercer University School of Medicine` = "TN", `Mercer University School of Medicine - Savannah` = "GA", `Mercer University School of Medicine,Ross University School of Medicine` = "GA", `Michigan State University College of Human Medicine` = "MI", `Michigan State University College of Human Medicine - Flint` = "MI", `Michigan State University College of Human Medicine - Grand Rapids` = "MI", `Michigan State University College of Human Medicine - Traverse City` = "MI", `Michigan State University College of Osteopathic Medicine` = "MI", `Morehouse School of Medicine` = "GA", `New York Institute of Technology College of Osteopathic Medicine` = "NY", `New York Medical College` = "NY", `New York Medical College,Universidad Autónoma de Guadalajara Facultad de Medicina,Virginia Commonwealth University School of Medicine` = "NY", `New York University School of Medicine` = "NY", `Northeast Ohio Medical University` = "OH", `Northwestern University The Feinberg School of Medicine` = "IL", `Nova Southeastern University College of Osteopathic Medicine` = "FL", `Oakland University William Beaumont School of Medicine` = "MI", `Ohio State University College of Medicine` = "OH", `Oklahoma State University College of Osteopathic Medicine` = "OK", `Oregon Health & Science University School of Medicine` = "OR", `Pacific Northwest University of Health Sciences College of Osteopathic Medicine` = "WA", `Pennsylvania State University College of Medicine` = "PA", `Perelman School of Medicine at the University of Pennsylvania` = "PA", `Philadelphia College of Osteopathic Medicine` = "PA", `Ponce Health Sciences University School of Medicine` = "PR", `Ponce School of Medicine and Health Sciences` = "PR", `Ponce School of Medicine and Health Sciences,American University of Antigua College of Medicine` = "PR", `Robert Larner, M.D., College of Medicine at the University of Vermont` = "VT", `Rocky Vista University College of Osteopathic Medicine` = "CO", `Rutgers New Jersey Medical School` = "NJ", `Rutgers, Robert Wood Johnson Medical School` = "NJ", `Sackler School of Medicine` = "NY", `Sackler School of Medicine - New York State American Branch` = "NY", `Saint Louis University School of Medicine` = "MO", `San Juan Bautista School of Medicine` = "PR", `Sidney Kimmel Medical College at Thomas Jefferson University` = "PA", `Southern Illinois University School of Medicine` = "IL", `Stanford University School of Medicine` = "CA", `State University of New York Downstate Medical Center College of Medicine` = "NY", `State University of New York Upstate Medical University` = "NY", `Stony Brook University School of Medicine` = "NY", `Temple University School of Medicine` = "PA", `Texas A&M Health Science Center College of Medicine` = "TX", `Texas Tech University Health Sciences Center Paul L. Foster School of Medicine` = "TX", `Texas Tech University Health Sciences Center School of Medicine` = "TX", `Texas Tech University School of Medicine - Amarillo` = "TX", `Texas Tech University School of Medicine - Odessa` = "TX", `The Brody School of Medicine at East Carolina University` = "NC", `The University of Texas School of Medicine at San Antonio` = "TX", `The University of Toledo College of Medicine` = "OH", `The Warren Alpert Medical School of Brown University` = "RI", `Touro College of Osteopathic Medicine - Middletown` = "NY", `Touro College of Osteopathic Medicine - New York` = "NY", `Touro University College of Osteopathic Medicine` = "NY", `Touro University College of Osteopathic Medicine–California` = "CA", `Touro University Nevada College of Osteopathic Medicine` = "NV", `Tufts University School of Medicine` = "MA", `Tulane University School of Medicine` = "LA", `UCLA/Drew Medical Education Program` = "CA", `University at Buffalo State University of New York School of Medicine & Biomedical Sciences` = "NY", `University of Alabama School of Medicine` = "LA", `University of Arizona College of Medicine` = "AZ", `University of Arizona College of Medicine - Phoenix` = "AZ", `University of Arizona College of Medicine – Phoenix` = "AZ", `University of Arizona College of Medicine-Phoenix` = "AZ", `University of Arkansas for Medical Sciences College of Medicine` = "AK", `University of California, Davis, School of Medicine` = "CA", `University of California, Irvine, School of Medicine` = "CA", `University of California, Los Angeles David Geffen School of Medicine` = "CA", `University of California, Riverside School of Medicine` = "CA", `University of California, San Diego School of Medicine` = "CA", `University of California, San Francisco, School of Medicine` = "CA", `University of Central Florida College of Medicine` = "FL", `University of Chicago Division of the Biological Sciences The Pritzker School of Medicine` = "IL", `University of Chicago Division of the Biological Sciences The Pritzker School of Medicine,Hofstra North Shore - LIJ School of Medicine,Sackler School of Medicine,State University of New York Downstate Medical Center College of Medicine,Albert Einstein College of Medicine of Yeshiva University` = "IL", `University of Cincinnati College of Medicine` = "OH", `University of Cincinnati College of Medicine,University of Cairo Faculty of Medicine,University of Cairo Faculty of Medicine,University of Cairo Faculty of Medicine` = "OH", `University of Colorado School of Medicine` = "CO", `University of Connecticut School of Medicine` = "CT", `University of Florida College of Medicine` = "FL", `University of Florida College of Medicine,University of California, San Francisco, School of Medicine` = "FL", `University of Hawaii, John A. Burns School of Medicine` = "HI", `University of Illinois College of Medicine` = "IL", `University of Illinois College of Medicine - Peoria` = "IL", `University of Illinois College of Medicine - Rockford` = "IL", `University of Illinois College of Medicine - Urbana` = "IL", `University of Illinois College of Medicine,St. Martinus University Faculty of Medicine` = "IL", `University of Iowa Roy J. and Lucille A. Carver College of Medicine` = "IA", `University of Iowa Roy J. and Lucille A. Carver College of Medicine,Ladoke Akintola University of Technology (LAUTECH) College of Health Sciences` = "IA", `University of Iowa Roy J. and Lucille A. Carver College of Medicine,Medical College of Wisconsin` = "IA", `University of Kansas School of Medicine` = "KS", `University of Kansas School of Medicine-Wichita` = "KS", `University of Kentucky College of Medicine` = "KY", `University of Louisville School of Medicine` = "KY", `University of Maryland School of Medicine` = "MD", `University of Massachusetts Medical School` = "MA", `University of Miami Leonard M. Miller School of Medicine` = "FL", `University of Michigan Medical School` = "MI", `University of Minnesota Medical School` = "MN", `University of Mississippi School of Medicine` = "MS", `University of Missouri-Columbia School of Medicine` = "MO", `University of Missouri-Kansas City School of Medicine` = "MO", `University of Nebraska College of Medicine` = "NE", `University of Nevada School of Medicine` = "NV", `University of New England College of Osteopathic Medicine` = "ME", `University of New Mexico School of Medicine` = "NM", `University of North Carolina at Chapel Hill School of Medicine` = "NC", `University of North Dakota School of Medicine and Health Sciences` = "ND", `University of North Texas Health Science Center - Texas College of Osteopathic Medicine` = "TX", `University of North Texas Health Science Center at Fort Worth/Texas College of Osteopathic Medicine` = "TX", `University of Oklahoma College of Medicine` = "OK", `University of Oklahoma College of Medicine - Tulsa` = "OK", `University of Oklahoma College of Medicine,Lake Erie College of Osteopathic Medicine` = "OK", `University of Oklahoma College of Medicine,University of Oklahoma College of Medicine - Tulsa` = "OK", `University of Pittsburgh School of Medicine` = "PA", `University of Puerto Rico School of Medicine` = "PR", `University of Rochester School of Medicine and Dentistry` = "NY", `University of South Alabama College of Medicine` = "AL", `University of South Carolina School of Medicine` = "SC", `University of South Carolina School of Medicine Greenville` = "SC", `University of South Dakota, Sanford School of Medicine` = "SD", `University of Tennessee Health Science Center College of Medicine` = "TN", `University of Tennessee Health Science Center College of Medicine,Texas Tech University Health Sciences Center School of Medicine` = "TN", `University of Texas Medical Branch School of Medicine` = "TX", `University of Texas Medical School at Houston` = "TX", `University of Texas School of Medicine at San Antonio` = "TX", `University of Texas Southwestern Medical Center Southwestern Medical School` = "TX", `University of Texas Southwestern Medical Center Southwestern Medical School,Faculté de Médecine Paris Descartes` = "TX", `University of Utah School of Medicine` = "UT", `University of Vermont College of Medicine` = "VT", `University of Virginia School of Medicine` = "VA", `University of Washington School of Medicine` = "WA", `University of Wisconsin School of Medicine and Public Health` = "WI", `USF Health Morsani College of Medicine` = "FL", `Vanderbilt University School of Medicine` = "TN", `Virginia Commonwealth University School of Medicine` = "VA", `Virginia Tech Carilion School of Medicine` = "VA", `Wake Forest School of Medicine of Wake Forest Baptist Medical Center` = "NC", `Washington University in St. Louis School of Medicine` = "MO", `Washington University of Health and Sciences` = "WA", `Wayne State University School of Medicine` = "MI", `Weill Cornell Medical College` = "NY", `Weill Cornell Medicine` = "NY", `West Virginia School of Osteopathic Medicine` = "WV", `West Virginia University School of Medicine` = "WV", `West Virginia University School of Medicine - Martinsburg` = "WV", `Western Michigan University Homer Stryker M.D. School of Medicine` = "MI", `Western Univ of Health Sciences/College of Osteopathic Med of the Pacific` = "CA", `Western University of Health Sciences/College of Osteopathic Medicine of the Pacific` = "CA", `Wright State University Boonshoft School of Medicine` = "MI", `Yale School of Medicine` = "CT")) %>%
  # 
  #     dplyr::rename(State_Abbreviation = ACOG_district) %>%
  #     dplyr::left_join(ACOG_Districts, by = c("State_Abbreviation" = "State_Abbreviations")) %>%
  #     dplyr::select(-State_Abbreviation, -State) %>%
  #     dplyr::mutate(ACOG_District_of_medical_school = impute_na(ACOG_District_of_medical_school, type = "value", val = "International Medical School, no ACOG district"))
  
 # all_years <- all_years %>% dplyr::select(-Medical_School_of_Graduation)
                
  all_years$NIH_dollars
  rm(nih_dollars)
  
  ###  Mini-Exploration of the Data ----
  #all_years
  dim(all_years)
  #View(all_years)
  data.table::data.table(all_years)
  funModeling::freq(data=all_years, plot = FALSE, na.rm = FALSE)
  class(all_years$NIH_dollars)
  colnames(all_years)
  all_years <- all_years %>% dplyr::select(c(-Medical_School_of_Graduation, -Applicant_Name, -USMLE_Step_1_Score, -USMLE_Step_2_CK_Score)) %>%
    reorder_cols(ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Medical_Education_or_Training_Interrupted, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant,  Visa_Sponsorship_Needed, white_non_white, Medical_Licensure_Problem, Type_of_medical_school, NIH_dollars, Match_Status) 
  colnames(all_years)
  
  view(summarytools::dfSummary(x = all_years, justify = "l", style = "multiline", varnumbers = FALSE, valid.col = FALSE, tmp.img.dir = "./img", max.distinct.values = 5, graph.magnif = 0.75))
  view(all_years, file = (here::here("/data/all_years_summary_tools.html")))
  summarytools::freq(all_years)
  view(summarytools::freq(all_years), collapse = TRUE, , path = (here::here("/data/")))
  
  write_csv(x = all_years, path = (here::here("/data/All_ERAS_data_merged_output_2_1_2020.csv")))

  # rm(archive2015)
  # rm(archive2016)
  # rm(archive2017)
  # rm(archive2018)
  # rm(GOBA_list_of_people_who_all_matched_into_OBGYN)
  # rm(total_number_of_applicants)
  # rm(colnamesarchive2015)
  # rm(colnamesarchive2016)
  # rm(colnamesarchive2017)
  # rm(colnamesarchive2018)
  # 

  