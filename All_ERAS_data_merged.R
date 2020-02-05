# *Objective: * We sought to construct and validate a model that predict a medical student's chances of matching into an obstetrics and gynecology residency.

# This file is needed to bring together the data from all the years of match data available.  The data comes from the AAMC from the Archives section of the Residency Program Director Work Station.  
# https://www.dropbox.com/s/wfv7oqpdhdzjlsr/AAMC%20download.mov?dl=0

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

here::set_here()  #set_here() creates an empty file named .here, by default in the current directory.Sets root.  
here::here()
#May need to run this file line-by-line (CRTL+Enter) by hand. 

# Steps to produce GOBA_list_of_people_who_all_matched_into_OBGYN
GOBA_list_of_people_who_all_matched_into_OBGYN <- 
  # We needed this data because it is a check about who is an OBGYN.  There is no public information about residents available on Physician Compare, NPPES or Doximity beyond the basics of address.  This ABOG data also groups people by userid putting consecutive userids/people next to each other who were enrolled in the same residency.  
  exploratory::read_rds_file("/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/list of people who all matched into OBGYN.rds") %>%
  readr::type_convert() %>%
  exploratory::clean_data_frame() %>%
  #arrange(desc(userid) %>%
  dplyr::select(userid, firstname, lastname, name) #, city_state, state)


# Steps to produce 2018_archive
archive2018 <- exploratory::read_delim_file("/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2018_archive.csv" , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = ".", grouping_mark = "," ), trim_ws = TRUE , progress = FALSE) %>%
  readr::type_convert() %>%
  exploratory::clean_data_frame() %>%
  select(`AAMC ID`, `Applicant Name`, `Medical Education or Training Interrupted`, ACLS, BLS, `Malpractice Cases Pending`, `Medical Licensure Problem`, PALS, `Felony Conviction`, `Limiting Factors`, `Alpha Omega Alpha`, Citizenship, `Date of Birth`, Gender, `Gold Humanism Honor Society`, `Military Service Obligation`, `Participating as a Couple in NRMP`, `Self Identify`, `Sigma Sigma Phi`, `US or Canadian Applicant`, `Visa Sponsorship Needed`, #`Higher Education Degree`, 
         `Medical Degree`, `Medical School of Graduation`, `USMLE Step 1 Score`, `Tracks Applied by Applicant`, `Count of Non Peer Reviewed Online Publication`, `Count of Oral Presentation`, `Count of Other Articles`, `Count of Peer Reviewed Book Chapter`, `Count of Peer Reviewed Journal Articles/Abstracts`, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`, `Count of Peer Reviewed Online Publication`, `Count of Poster Presentation`, `Count of Scientific Monograph`, `OBGYN Grade--10`,
      
         #New variables to include for feature engineering.  Must be included for each year of data.   
         `Medical School Type`, `USMLE Step 2 CK Score`, #`Language Fluency`, 
         #`Higher Education Degree_1`, `Higher Education Degree_2`
         ) %>%
  rename(PERSONAL_31 = `Applicant Name`) %>%
  rename(`Step_2_CK` = `USMLE Step 2 CK Score`) %>%
  dplyr::mutate(`US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
  dplyr::mutate(Gender = dplyr::recode(Gender, Female = "Female"), Gender = dplyr::recode(Gender, Female = "Female", Male = "Male", `No Response` = "Female")) %>%
  dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
  dplyr::mutate(`Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), ACLS = factor(ACLS), BLS = factor(BLS), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Medical Licensure Problem` = factor(`Medical Licensure Problem`), PALS = factor(PALS), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (AOA) elections held during senior year` = "Elections_Senior_Year", `Alpha Omega Alpha (Member of AOA)` = "Yes", `No Alpha Omega Alpha (AOA) chapter at my school` = "No"), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, , .missing = "No"), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`)) %>%
  filter(!is.na(`Limiting Factors`)) %>%
  dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `Gold Humanism Honor Society (Member of GHHS)` = "Yes", .missing = "Not a Member")) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`)) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), Match_Status = dplyr::recode(`Tracks Applied by Applicant`, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did not match")) %>%
  reorder_cols(Match_Status) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched"), `Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `No Gold Humanism Honor Society (GHHS) chapter at my school` = "No", `Not a Member` = "Not_a_Member", Yes = "Yes")) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "Did_Not_Match", Matched = "Matched")) %>%
  select(-`Tracks Applied by Applicant`) %>%
  dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Elections in Senior year` = "Senior_Year_Elections", No = "No", `No chapter` = "No_Chapter", Yes = "Yes"), Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), `Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White")) %>%
  filter(!is.na(`Self Identify`)) %>%
  dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `No Sigma Sigma Phi (SSP) chapter at my school` = "No_Chapter", `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", .default = "No")) %>%
  #select(-`Higher Education Degree`) %>%
  dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD")) %>%
  filter(!is.na(`Medical Degree`)) %>%
  dplyr::mutate(`Medical Degree` = factor(`Medical Degree`), `Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, , .missing = "Not_a_member"), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Self Identify` = factor(`Self Identify`), `Military Service Obligation` = factor(`Military Service Obligation`), Citizenship = factor(Citizenship)) %>%
  select(-`Felony Conviction`, -`Limiting Factors`) %>%
  dplyr::mutate(`OBGYN Grade--10` = factor(`OBGYN Grade--10`)) %>%
  select(-`OBGYN Grade--10`) %>%
  dplyr::mutate(Year = 2018) %>%
  dplyr::mutate(Positions_offered = 1336, Year = factor(Year)) %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2018` = "2017"), `Date of Birth` = mdy(`Date of Birth`)) %>%
  rename(DOB = `Date of Birth`) %>%
  dplyr::mutate(`Current date` = mdy("01/01/2017")) %>%
  dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age)/365) %>%
  filter(!is.na(Age) & Age >= 24) %>%
  select(-`Current date`) %>%
  dplyr::mutate(Match_Status = factor(Match_Status)) %>%
  clean_names(case = "parsed") %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2017` = "2018"), Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, No_Chapter = "No", Not_a_member = "No", Yes_Member = "Yes"), Medical_Licensure_Problem = dplyr::recode(Medical_Licensure_Problem, N = "No", Y = "Yes"), Positions_offered = factor(Positions_offered))


# Steps to produce 2017_archive
archive2017 <- exploratory::read_delim_file("/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2017_archive.csv" , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = ".", grouping_mark = "," ), trim_ws = TRUE , progress = FALSE) %>%
  readr::type_convert() %>%
  exploratory::clean_data_frame() %>%
  select(`AAMC ID`, `Applicant Name`, `Medical Education or Training Interrupted`, ACLS, BLS, `Malpractice Cases Pending`, `Medical Licensure Problem`, PALS, `Felony Conviction`, `Limiting Factors`, `Alpha Omega Alpha`, Citizenship, `Date of Birth`, Gender, `Gold Humanism Honor Society`, `Military Service Obligation`, `Participating as a Couple in NRMP`, `Self Identify`, `Sigma Sigma Phi`, `US or Canadian Applicant`, `Visa Sponsorship Needed`, #`Higher Education Degree`, 
         `Medical Degree`, `Medical School of Graduation`, `USMLE Step 1 Score`, `Tracks Applied by Applicant`, `Count of Non Peer Reviewed Online Publication`, `Count of Oral Presentation`, `Count of Other Articles`, `Count of Peer Reviewed Book Chapter`, `Count of Peer Reviewed Journal Articles/Abstracts`, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`, `Count of Peer Reviewed Online Publication`, `Count of Poster Presentation`, `Count of Scientific Monograph`, `OBGYN Grade--10`,
         
         #New variables to include for feature engineering.  Must be included for each year of data.   
         `Medical School Type`, `USMLE Step 2 CK Score`, #`Language Fluency`#, 
         #`Higher Education Degree_1`, `Higher Education Degree_2`
         ) %>%
  rename(PERSONAL_31 = `Applicant Name`) %>%
  rename(Step_2_CK =  `USMLE Step 2 CK Score`) %>%
  dplyr::mutate(`US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
  dplyr::mutate(Gender = dplyr::recode(Gender, Female = "Female"), Gender = dplyr::recode(Gender, Female = "Female", Male = "Male", `No Response` = "Female")) %>%
  dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
  dplyr::mutate(`Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), ACLS = factor(ACLS), BLS = factor(BLS), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Medical Licensure Problem` = factor(`Medical Licensure Problem`), PALS = factor(PALS), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (AOA) elections held during senior year` = "Elections_Senior_Year", `Alpha Omega Alpha (Member of AOA)` = "Yes", `No Alpha Omega Alpha (AOA) chapter at my school` = "No"), `Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, , .missing = "No"), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`)) %>%
  filter(!is.na(`Limiting Factors`)) %>%
  dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `Gold Humanism Honor Society (Member of GHHS)` = "Yes", .missing = "Not a Member")) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`)) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), Match_Status = dplyr::recode(`Tracks Applied by Applicant`, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did not match")) %>%
  reorder_cols(Match_Status) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched"), `Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `No Gold Humanism Honor Society (GHHS) chapter at my school` = "No", `Not a Member` = "Not_a_Member", Yes = "Yes")) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "Did_Not_Match", Matched = "Matched")) %>%
  select(-`Tracks Applied by Applicant`) %>%
  dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Elections in Senior year` = "Senior_Year_Elections", No = "No", `No chapter` = "No_Chapter", Yes = "Yes"), Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), `Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White")) %>%
  filter(!is.na(`Self Identify`)) %>%
  dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `No Sigma Sigma Phi (SSP) chapter at my school` = "No_Chapter", `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", .default = "No")) %>%
  #select(-`Higher Education Degree`) %>%
  dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD")) %>%
  filter(!is.na(`Medical Degree`)) %>%
  dplyr::mutate(`Medical Degree` = factor(`Medical Degree`), `Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, , .missing = "Not_a_member"), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Self Identify` = factor(`Self Identify`), `Military Service Obligation` = factor(`Military Service Obligation`), Citizenship = factor(Citizenship)) %>%
  select(-`Felony Conviction`, -`Limiting Factors`) %>%
  dplyr::mutate(`OBGYN Grade--10` = factor(`OBGYN Grade--10`)) %>%
  select(-`OBGYN Grade--10`) %>%
  dplyr::mutate(Year = 2018) %>%
  dplyr::mutate(Positions_offered = 1336, Year = factor(Year)) %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2018` = "2017"), `Date of Birth` = mdy(`Date of Birth`)) %>%
  rename(DOB = `Date of Birth`) %>%
  dplyr::mutate(`Current date` = mdy("01/01/2017")) %>%
  dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age)/365) %>%
  filter(!is.na(Age) & Age >= 24) %>%
  select(-`Current date`) %>%
  dplyr::mutate(Match_Status = factor(Match_Status)) %>%
  clean_names(case = "parsed") %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2017` = "2018"), Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, No_Chapter = "No", Not_a_member = "No", Yes_Member = "Yes"), Medical_Licensure_Problem = dplyr::recode(Medical_Licensure_Problem, N = "No", Y = "Yes"), Positions_offered = factor(Positions_offered))


# Steps to produce 2016_archive
archive2016 <- exploratory::read_delim_file("/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2016_archive.csv" , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = "."), trim_ws = TRUE , progress = FALSE) %>%
  readr::type_convert() %>%
  exploratory::clean_data_frame() %>%
  dplyr::mutate(`Current date` = mdy("01/01/2019")) %>%
  select(PERSONAL, PERSONAL_4, PERSONAL_6, PERSONAL_8, PERSONAL_19, PERSONAL_26, PERSONAL_28, PERSONAL_34, PERSONAL_45, PERSONAL_51, PERSONAL_52, PERSONAL_59, PERSONAL_65, PERSONAL_79, PERSONAL_80, PERSONAL_82, PERSONAL_84, 
        SCORE_S1, # Step 1 score
        SCORE_CK, #Step 2 CK score
        MEDICAL, MEDICAL_6, MEDICAL_8, EXPERIENCE_12, TRACKSAPPLICANT, TRACKSAPPLICANT_1, PUB_COUNT, PUB_COUNT_1, PUB_COUNT_2, PUB_COUNT_3, PUB_COUNT_4, PUB_COUNT_5, PUB_COUNT_6, PUB_COUNT_7, PUB_COUNT_8, PERSONAL_14, PERSONAL_16, PERSONAL_31,
         
         #`PERSONAL_55`#, `EDUCATION_1`
         
         ) %>%
  rename(`Malpractice Cases Pending` = PERSONAL_14) %>%
  rename(`Step_2_CK` = SCORE_CK) %>%
  dplyr::mutate(`Malpractice Cases Pending` = dplyr::recode(`Malpractice Cases Pending`, `Malpractice Cases Pending` = "No", N = "No", .missing = "No")) %>%
  filter(!is.na(MEDICAL_8)) %>%
  rename(`Visa Sponsorship Needed` = PERSONAL_84) %>%
  select(-EXPERIENCE_12) %>%
  rename(BLS = PERSONAL_8, PALS = PERSONAL_19) %>%
  rename(ACLS = PERSONAL_6) %>%
  rename(AAMCID = PERSONAL, CouplesMatch = PERSONAL_65) %>%
  filter(ACLS %in% c("Yes", "No")) %>%
  dplyr::mutate(BLS = dplyr::recode(BLS, Yes = "Yes", .missing = "No")) %>%
  rename(`Alpha Omega Alpha` = PERSONAL_28) %>%
  dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (Member of AOA)` = "Yes", `AOA elections held during Senior year` = "Elections_Senior_Year", `No AOA Chapter At My School` = "No", .missing = "No")) %>%
  rename(`Gold Humanism Honor Society` = PERSONAL_52) %>%
  dplyr::mutate(`Gold Humanism Honor Society` = dplyr::recode(`Gold Humanism Honor Society`, `GHHS (Member of GHHS)` = "Yes", `No GHHS chapter at my school` = "No", .missing = "Not_a_Member")) %>%
  rename(`USMLE Step 1 Score` = SCORE_S1) %>%
  dplyr::mutate(`USMLE Step 1 Score` = parse_number(`USMLE Step 1 Score`)) %>%
  filter(!is.na(`USMLE Step 1 Score`)) %>%
  dplyr::mutate(Year2016 = 2016) %>%
  dplyr::mutate(Positions_offered = 1265, AAMCID = parse_number(AAMCID), ACLS = factor(ACLS), BLS = factor(BLS), PALS = factor(PALS), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`), Positions_offered = factor(Positions_offered)) %>%
  rename(Citizenship = PERSONAL_34) %>%
  dplyr::mutate(Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), Citizenship = factor(Citizenship)) %>%
  rename(`Participating as a Couple in NRMP` = CouplesMatch) %>%
  dplyr::mutate(`Participating as a Couple in NRMP` = dplyr::recode(`Participating as a Couple in NRMP`, False = "No", True = "Yes", .missing = "No"), `Gold Humanism Honor Society` = factor(`Gold Humanism Honor Society`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`)) %>%
  rename(`Self Identify` = PERSONAL_79) %>%
  filter(ACLS %in% c("Yes", "No")) %>%
  dplyr::mutate(`Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White", .missing = "White")) %>%
  rename(`Medical Degree` = MEDICAL) %>%
  dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD", .default = "MD")) %>%
  rename(`Sigma Sigma Phi` = PERSONAL_80) %>%
  dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", `No SSP Chapter At My School` = "No_Chapter", .default = "Not_a_member", .missing = "Not_a_member"), `Self Identify` = factor(`Self Identify`), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Medical Degree` = factor(`Medical Degree`)) %>%
  dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No"), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`)) %>%
  rename(`AAMC ID` = AAMCID, `Medical Education or Training Interrupted` = PERSONAL_4, `Misdemeanor Conviction` = PERSONAL_26, `US or Canadian Applicant` = PERSONAL_82) %>%
  filter(TRACKSAPPLICANT %in% c("Ob-Gyn/Preliminary|1076220P0 (Preliminary)", "Obstetrics-Gynecology|1076220C0 (Categorical)")) %>%
  select(-TRACKSAPPLICANT_1) %>%
  rename(Match_Status = TRACKSAPPLICANT) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did_Not_Match", `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched")) %>%
  rename(`Count of Non Peer Reviewed Online Publication` = PUB_COUNT, `Count of Oral Presentation` = PUB_COUNT_1, `Count of Other Articles` = PUB_COUNT_2, `Count of Peer Reviewed Book Chapter` = PUB_COUNT_3, `Count of Peer Reviewed Journal Articles/Abstracts` = PUB_COUNT_4, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = PUB_COUNT_5, `Count of Peer Reviewed Online Publication` = PUB_COUNT_6, `Count of Poster Presentation` = PUB_COUNT_7, `Count of Scientific Monograph` = PUB_COUNT_8) %>%
  reorder_cols(Match_Status) %>%
  dplyr::mutate(Match_Status = factor(Match_Status), `Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), `Misdemeanor Conviction` = factor(`Misdemeanor Conviction`), `Count of Non Peer Reviewed Online Publication` = parse_number(`Count of Non Peer Reviewed Online Publication`)) %>%
  filter(!is.na(`Count of Non Peer Reviewed Online Publication`)) %>%
  dplyr::mutate(`Count of Oral Presentation` = parse_number(`Count of Oral Presentation`), `Count of Other Articles` = parse_number(`Count of Other Articles`), `Count of Peer Reviewed Book Chapter` = parse_number(`Count of Peer Reviewed Book Chapter`), `Count of Peer Reviewed Journal Articles/Abstracts` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts`), `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`), `Count of Peer Reviewed Online Publication` = parse_number(`Count of Peer Reviewed Online Publication`)) %>%
  filter(!is.na(`Count of Peer Reviewed Online Publication`)) %>%
  dplyr::mutate(`Count of Poster Presentation` = parse_number(`Count of Poster Presentation`), `Count of Scientific Monograph` = parse_number(`Count of Scientific Monograph`)) %>%
  rename(`Date of Birth` = PERSONAL_45) %>%
  dplyr::mutate(`Date of Birth` = mdy(`Date of Birth`)) %>%
  rename(DOB = `Date of Birth`) %>%
  dplyr::mutate(`Current date` = mdy("01/01/2016")) %>%
  dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age/365)) %>%
  filter(Age >= 24) %>%
  filter(!is.na(Age)) %>%
  select(-`Current date`) %>%
  select(-DOB) %>%
  rename(Gender = PERSONAL_51, `Military Service Obligation` = PERSONAL_59, `Malpractice Cases Pending` = `Malpractice Cases Pending`) %>%
  dplyr::mutate(`Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), Gender = factor(Gender), `Military Service Obligation` = factor(`Military Service Obligation`), `US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
  clean_names(case = "parsed") %>%
  dplyr::mutate(Year = 2016, Year = factor(Year)) %>%
  select(-Year2016) %>%
  rename(`Medical School Type` = MEDICAL_8) %>%
  dplyr::mutate(Sigma_Sigma_Phi = dplyr::recode(Sigma_Sigma_Phi, Not_a_member = "No", Yes_Member = "Yes", .default = "No"), `Medical School Type` = factor(`Medical School Type`)) %>%
  rename(`Medical Licensure Problem` = PERSONAL_16) %>%
  dplyr::mutate(`Medical Licensure Problem` = dplyr::recode(`Medical Licensure Problem`, N = "No"), `Medical Licensure Problem` = factor(`Medical Licensure Problem`)) %>%
  rename(Medical_School_of_Graduation = MEDICAL_6)


# Steps to produce the 2015 archive
archive2015 <- exploratory::read_delim_file("/Users/tylermuffly/Dropbox/Nomogram/nomogram/data/Archives/2015_archive.csv" , ",", quote = "\"", skip = 0 , col_names = TRUE , na = c('','NA') , locale=readr::locale(encoding = "UTF-8", decimal_mark = "."), trim_ws = TRUE , progress = FALSE) %>%
  readr::type_convert() %>%
  exploratory::clean_data_frame() %>%
  select(PERSONAL, PERSONAL_4, PERSONAL_6, PERSONAL_12, PERSONAL_14, PERSONAL_17, PERSONAL_24, PERSONAL_26, PERSONAL_31, PERSONAL_35, PERSONAL_46, PERSONAL_52, PERSONAL_58, PERSONAL_64, PERSONAL_78, PERSONAL_80, PERSONAL_81, PERSONAL_83, USMLE, MEDICAL, MEDICAL_8, TRACKSAPPLICANT, PUB_COUNT, PUB_COUNT_1, PUB_COUNT_2, PUB_COUNT_3, PUB_COUNT_4, PUB_COUNT_5, PUB_COUNT_6, PUB_COUNT_7, PUB_COUNT_8,
         
          MEDICAL_8, #Medical school type         
         `MEDICAL_6`, #Medical school name
         `SCORE_CK`, #`SCORE_S1`, #Step 1 and Step 2 scores
         #`PERSONAL_54`, #Language fluency
         #`EDUCATION_1`
         
         ) %>%
  rename(Medical_School_of_Graduation = MEDICAL_6) %>%
  #rename(Medical_School_Type = MEDICAL_8) %>%
  rename(Step_2_CK = SCORE_CK) %>%
  rename(`Medical Licensure Problem` = PERSONAL_14) %>%
  dplyr::mutate(`Medical Licensure Problem` = dplyr::recode(`Medical Licensure Problem`, `Medical Licensure Problem` = "No", N = "No", Y = "Yes", .missing = "No")) %>%
  filter(!is.na(MEDICAL_8)) %>%
  rename(PALS = PERSONAL_17) %>%
  rename(ACLS = PERSONAL_6) %>%
  rename(AAMCID = PERSONAL) %>%
  filter(ACLS %in% c("Yes", "No")) %>%
  rename(`Alpha Omega Alpha` = PERSONAL_26) %>%
  dplyr::mutate(`Alpha Omega Alpha` = dplyr::recode(`Alpha Omega Alpha`, `Alpha Omega Alpha (Member of AOA)` = "Yes", `AOA elections held during Senior year` = "Elections_Senior_Year", `No AOA Chapter At My School` = "No", .missing = "No")) %>%
  rename(`USMLE Step 1 Score` = USMLE) %>%
  dplyr::mutate(`USMLE Step 1 Score` = parse_number(`USMLE Step 1 Score`)) %>%
  filter(!is.na(`USMLE Step 1 Score`)) %>%
  dplyr::mutate(Year2016 = 2016) %>%
  dplyr::mutate(Positions_offered = 1255, AAMCID = parse_number(AAMCID), ACLS = factor(ACLS), PALS = factor(PALS), `Alpha Omega Alpha` = factor(`Alpha Omega Alpha`), Positions_offered = factor(Positions_offered)) %>%
  rename(Citizenship = PERSONAL_35) %>%
  dplyr::mutate(Citizenship = dplyr::recode(Citizenship, `U.S. Citizen` = "US_Citizen", .default = "Not_A_Citizen"), Citizenship = factor(Citizenship)) %>%
  rename(`Participating as a Couple in NRMP` = PERSONAL_64) %>%
  dplyr::mutate(`Participating as a Couple in NRMP` = dplyr::recode(`Participating as a Couple in NRMP`, False = "No", True = "Yes", .missing = "No")) %>%
  rename(`Self Identify` = PERSONAL_78) %>%
  filter(ACLS %in% c("Yes", "No")) %>%
  dplyr::mutate(`Self Identify` = dplyr::recode(`Self Identify`, White = "White", `White|Other: Arab-American` = "White", `White|Other: Guyanese` = "White", `White|Other: Lebanese-American` = "White", `White|Other: Middle Eastern` = "White", `White|Other: Middle-Eastern (Jewish)` = "White", `White|Other: Persian` = "White", `White|Other: Portuguese` = "White", `White|Other: Turkish` = "White", .default = "Not_White", .missing = "White")) %>%
  rename(`Medical Degree` = MEDICAL) %>%
  dplyr::mutate(`Medical Degree` = dplyr::recode(`Medical Degree`, `B.A./M.D.` = "MD", D.O. = "DO", `B.S./M.D.` = "MD", `DO/MA` = "DO", `DO/MBA` = "DO", `DO/MPH` = "DO", M.D. = "MD", `M.D./M.B.A.` = "MD", `M.D./M.P.H.` = "MD", `M.D./Other` = "MD", `M.D./Ph.D.` = "MD", `M.S./M.D.` = "MD", M.B. = "MD", `M.B.,B.S.` = "MD", M.B.B.Ch. = "MD", M.B.B.Ch.B = "MD", M.B.Ch.B. = "MD", B.A.O. = "MD", M.C. = "MD", M.Med. = "MD", .default = "MD")) %>%
  rename(`Sigma Sigma Phi` = PERSONAL_80) %>%
  dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, `Sigma Sigma Phi (Member of SSP)` = "Yes_Member", `No SSP Chapter At My School` = "No_Chapter", .default = "Not_a_member", .missing = "Not_a_member"), `Self Identify` = factor(`Self Identify`), `Sigma Sigma Phi` = factor(`Sigma Sigma Phi`), `Medical Degree` = factor(`Medical Degree`)) %>%
  rename(`AAMC ID` = AAMCID, `Medical Education or Training Interrupted` = PERSONAL_4, `Misdemeanor Conviction` = PERSONAL_24, `US or Canadian Applicant` = PERSONAL_81) %>%
  filter(TRACKSAPPLICANT %in% c("Ob-Gyn/Preliminary|1076220P0 (Preliminary)", "Obstetrics-Gynecology|1076220C0 (Categorical)")) %>%
  rename(Match_Status = TRACKSAPPLICANT) %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Ob-Gyn/Preliminary|1076220P0 (Preliminary)` = "Did_Not_Match", `Obstetrics-Gynecology|1076220C0 (Categorical)` = "Matched")) %>%
  rename(`Count of Non Peer Reviewed Online Publication` = PUB_COUNT, `Count of Oral Presentation` = PUB_COUNT_1, `Count of Other Articles` = PUB_COUNT_2, `Count of Peer Reviewed Book Chapter` = PUB_COUNT_3, `Count of Peer Reviewed Journal Articles/Abstracts` = PUB_COUNT_4, `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = PUB_COUNT_5, `Count of Peer Reviewed Online Publication` = PUB_COUNT_6, `Count of Poster Presentation` = PUB_COUNT_7, `Count of Scientific Monograph` = PUB_COUNT_8) %>%
  reorder_cols(Match_Status) %>%
  dplyr::mutate(Match_Status = factor(Match_Status), `Medical Education or Training Interrupted` = factor(`Medical Education or Training Interrupted`), `Misdemeanor Conviction` = factor(`Misdemeanor Conviction`), `Count of Non Peer Reviewed Online Publication` = parse_number(`Count of Non Peer Reviewed Online Publication`)) %>%
  filter(!is.na(`Count of Non Peer Reviewed Online Publication`)) %>%
  dplyr::mutate(`Count of Oral Presentation` = parse_number(`Count of Oral Presentation`), `Count of Other Articles` = parse_number(`Count of Other Articles`), `Count of Peer Reviewed Book Chapter` = parse_number(`Count of Peer Reviewed Book Chapter`), `Count of Peer Reviewed Journal Articles/Abstracts` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts`), `Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)` = parse_number(`Count of Peer Reviewed Journal Articles/Abstracts(Other than Published)`), `Count of Peer Reviewed Online Publication` = parse_number(`Count of Peer Reviewed Online Publication`)) %>%
  filter(!is.na(`Count of Peer Reviewed Online Publication`)) %>%
  dplyr::mutate(`Count of Poster Presentation` = parse_number(`Count of Poster Presentation`), `Count of Scientific Monograph` = parse_number(`Count of Scientific Monograph`)) %>%
  rename(`Date of Birth` = PERSONAL_46) %>%
  dplyr::mutate(`Date of Birth` = mdy(`Date of Birth`)) %>%
  rename(DOB = `Date of Birth`) %>%
  dplyr::mutate(`Current date` = mdy("01/01/2015")) %>%
  dplyr::mutate(Age = `Current date`- DOB, Age = as.numeric(Age/365)) %>%
  filter(Age >= 24) %>%
  filter(!is.na(Age)) %>%
  dplyr::mutate(`Misdemeanor Conviction` = dplyr::recode(`Misdemeanor Conviction`, Screened = "No")) %>%
  select(-`Current date`) %>%
  select(-DOB) %>%
  rename(Gender = PERSONAL_52, `Military Service Obligation` = PERSONAL_58) %>%
  dplyr::mutate(`Sigma Sigma Phi` = dplyr::recode(`Sigma Sigma Phi`, Not_a_member = "No")) %>%
  rename(`Visa Sponsorship Needed` = PERSONAL_83) %>%
  dplyr::mutate(`Visa Sponsorship Needed` = dplyr::recode(`Visa Sponsorship Needed`, No = "No", Yes = "Yes", .missing = "No")) %>%
  filter(!is.na(`Count of Poster Presentation`)) %>%
  rename(Year2015 = Year2016) %>%
  dplyr::mutate(Year2015 = factor(Year2015)) %>%
  rename(`Malpractice Cases Pending` = PERSONAL_12) %>%
  dplyr::mutate(Gender = factor(Gender), `Visa Sponsorship Needed` = factor(`Visa Sponsorship Needed`), `Malpractice Cases Pending` = factor(`Malpractice Cases Pending`), `Military Service Obligation` = factor(`Military Service Obligation`), `Participating as a Couple in NRMP` = factor(`Participating as a Couple in NRMP`), `US or Canadian Applicant` = factor(`US or Canadian Applicant`)) %>%
  clean_names(case = "parsed") %>%
  rename(Year = Year2015) %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2016` = "2015")) %>%
  rename(`Medical School Type` = MEDICAL_8) %>%
  dplyr::mutate(`Medical School Type` = factor(`Medical School Type`), Medical_Licensure_Problem = factor(Medical_Licensure_Problem)) %>%
  clean_names(case = "parsed") %>%
  dplyr::mutate(Year = dplyr::recode(Year, `2016` = "2015"))
  


#Bring all years together
all_years <- 
  bind_rows(archive2015, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
  bind_rows(archive2016, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
  bind_rows(archive2017, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
  bind_rows(archive2018, id_column_name = "ID", current_df_name = "all_years", force_data_type = TRUE) %>%
  clean_names(case = "parsed") %>%
  
#New variable of medical school type
  tidyr::unite("Medical_School_Type", Medical_School_Type, Medical_School_Type_2, sep = "_", remove = FALSE) %>%
  mutate(Medical_School_Type = str_remove(Medical_School_Type, "_NA$"), #Removes NA from end of string
         Medical_School_Type = str_remove(Medical_School_Type, "^NA_")) %>%  #Removes NA from start of string
  mutate(Medical_School_Type = dplyr::recode(Medical_School_Type, `International School,International School` = "International School", `International School,International School,International School` = "International School", `International School,International School,U.S. Public School,International School` = "International School", `International School,U.S. Private School` = "International School", `International School,U.S. Private School,U.S. Private School,U.S. Private School` = "International School", `U.S. Private School,International School` = "U.S. Private School", `U.S. Private School,International School,U.S. Private School,U.S. Private School` = "U.S. Private School", `U.S. Private School,International School,U.S. Public School` = "U.S. Private School", `U.S. Private School,U.S. Private School,International School,U.S. Public School,U.S. Private School` = "U.S. Private School", `U.S. Private School,U.S. Public School` = "U.S. Private School", `U.S. Public School,International School` = "U.S. Public School", `U.S. Public School,International School,International School,International School` = "U.S. Public School", `U.S. Public School,Osteopathic School` = "U.S. Public School", `U.S. Public School,U.S. Private School` = "U.S. Public School", `U.S. Public School,U.S. Public School` = "U.S. Public School")) %>%
  
  #Bring in Step 2 Clinical Skills score here
  
  dplyr::mutate(Malpractice_Cases_Pending = dplyr::recode(Malpractice_Cases_Pending, N = "No", No = "No", Y = "Yes"), Malpractice_Cases_Pending = factor(Malpractice_Cases_Pending), Misdemeanor_Conviction = dplyr::recode(Misdemeanor_Conviction, No = "No", Yes = "Yes", .missing = "No"), Misdemeanor_Conviction = factor(Misdemeanor_Conviction)) %>%
  select(-DOB, -Medical_Licensure_Problem, -Medical_Licensure_Problem_2, -AAMC_ID) %>%
  filter(!is.na(USMLE_Step_1_Score)) %>%
  rename(white_non_white = Self_Identify, Couples_Match = Participating_as_a_Couple_in_NRMP) %>%
  dplyr::mutate(Match_Status_Dichot = dplyr::recode(Match_Status, Did_Not_Match = "0", Matched = "1"), Match_Status = dplyr::recode(Match_Status, Did_Not_Match = "No", Matched = "Yes")) %>%
  reorder_cols(Match_Status, Match_Status_Dichot, ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Positions_offered, Sigma_Sigma_Phi, US_or_Canadian_Applicant, 
               USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Year) %>%
  dplyr::mutate(US_or_Canadian_Applicant = dplyr::recode(US_or_Canadian_Applicant, No = "international", Yes = "US senior")) %>%
  dplyr::mutate(Match_Status_Dichot_1 = dplyr::recode(Match_Status_Dichot, `0` = "Did not Match", `1` = "Matched Successfully")) %>%
  rename(Applicant_name = PERSONAL_31) %>%
  dplyr::mutate(Applicant_name = str_to_title(Applicant_name), formatted_names = humaniformat::format_reverse(Applicant_name), firstname = humaniformat::first_name(formatted_names), lastname = humaniformat::last_name(formatted_names)) %>%
  distinct(Applicant_name, .keep_all = TRUE) %>%
  arrange(lastname) %>%
  # I need to look at matches from both sides.  ERAS shows who applied to OBGYN.  The GOBA_list_of_people_who_all_matched_into_OBGYN data shows who actually got into OBGYN.  
  left_join(GOBA_list_of_people_who_all_matched_into_OBGYN, by = c("lastname" = "lastname", "firstname" = "firstname"), ignorecase=TRUE) %>%
  dplyr::mutate(calculation_1 = name, calculation_1 = dplyr::recode(calculation_1, `Aaron D Campbell, M.D.` = "Matched", .default = "Matched")) %>%
  rename(`Matched because present in ABOG database` = calculation_1) %>%
  dplyr::mutate(`Matched because present in ABOG database` = impute_na(`Matched because present in ABOG database`, type = "value", val = "Did not match")) %>%
  dplyr::mutate(`Match stats as defined by ERAS data` = Match_Status, `Match stats as defined by ERAS data` = dplyr::recode(`Match stats as defined by ERAS data`, No = "Did not match", Yes = "Matched")) %>%
  unite(`Unite match data from ABOG and from ERAS`, `Matched because present in ABOG database`, `Match stats as defined by ERAS data`, sep = "_", remove = FALSE) %>%
  
  # I merged the matched status from the ABOG data (saying that they had an ABOG userid) and the ERAS data (applied to CU). 
  dplyr::mutate(`Final call if they matched` = `Unite match data from ABOG and from ERAS`) %>%
  
  # Ideas here are that the students who may or may not have matched ended up matching.  Giving people the beneift of the doubt.  For example Elizabeth Clain was called by GOBA as a match but not by ERAS for some reason.  
  dplyr::mutate(`Final call if they matched` = factor(`Final call if they matched`), `Final Final Final` = dplyr::recode(`Final call if they matched`, `Did not match_Did not match` = "Did not match", `Did not match_Larson, Kaitlin; Ghadiri, Ali` = "Did not match", `Did not match_Matched` = "Matched", `Did not match_NA` = "Did not match")) %>%
  filter(Match_Status != "Larson, Kaitlin; Ghadiri, Ali") %>%
  select(-Match_Status, -Match_Status_Dichot, -ID_new_new, -ID_new, -ID, -Match_Status_Dichot_1, -formatted_names, -firstname, -lastname, -name, -`Unite match data from ABOG and from ERAS`, -`Matched because present in ABOG database`, -`Match stats as defined by ERAS data`, -`Final call if they matched`) %>%
  
  # Outcome variable has to be the last column.  
  reorder_cols(Applicant_name, ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Positions_offered, Sigma_Sigma_Phi, US_or_Canadian_Applicant, USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Year, `Final Final Final`) %>%
  rename(Match_Status = `Final Final Final`) %>%
  dplyr::mutate(Match_Status = dplyr::recode_factor(Match_Status, `Did not match` = "Did Not Match", Matched = "Matched", `Matched_Did not match` = "Unsure", Matched_Matched = "Matched")) %>%
  filter(Match_Status %in% c("Did Not Match", "Matched")) %>%
  dplyr::mutate(Count_of_Peer_Reviewed_Book_Chapter = parse_number(Count_of_Peer_Reviewed_Book_Chapter)) %>%
  dplyr::mutate_at(vars(ACLS, Alpha_Omega_Alpha, BLS, Citizenship, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Sigma_Sigma_Phi, US_or_Canadian_Applicant, Visa_Sponsorship_Needed, white_non_white, Year, Medical_School_Type), funs(factor)) %>%
  filter(Count_of_Peer_Reviewed_Online_Publication != "Obstetrics-Gynecology|1076220C0 (Categorical)") %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `Did not match` = "0", Matched = "1")) %>%
  filter(!is_empty(Match_Status)) %>%
  select(-Applicant_name, -Year) %>%
  filter(Match_Status %nin% c("") & Match_Status != "Matched_NA") %>%
  dplyr::mutate(Match_Status = dplyr::recode(Match_Status, `0` = "No.Match", `1` = "Match")) %>%
  fill(ACLS, Age, Alpha_Omega_Alpha, BLS, Citizenship, Count_of_Non_Peer_Reviewed_Online_Publication, Count_of_Oral_Presentation, Count_of_Other_Articles, Count_of_Peer_Reviewed_Book_Chapter, Count_of_Peer_Reviewed_Journal_Articles_Abstracts, Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published, Count_of_Peer_Reviewed_Online_Publication, Count_of_Poster_Presentation, Count_of_Scientific_Monograph, Couples_Match, Gender, Gold_Humanism_Honor_Society, Medical_Education_or_Training_Interrupted, Malpractice_Cases_Pending, Medical_Degree, Military_Service_Obligation, Misdemeanor_Conviction, PALS, Positions_offered, Sigma_Sigma_Phi, US_or_Canadian_Applicant, USMLE_Step_1_Score, Visa_Sponsorship_Needed, white_non_white, Match_Status, .direction = "down") %>%
  dplyr::mutate(Count_of_Non_Peer_Reviewed_Online_Publication = parse_number(Count_of_Non_Peer_Reviewed_Online_Publication), Match_Status_1 = Match_Status) %>%
  unite(`USMLE_Step_2_CK_Score`, `Step_2_CK`, sep = "_", remove = FALSE) %>%
  select(-`Step_2_CK`, - Medical_School_Type_2) %>%
  select(-ID_new_new_new, - Positions_offered, -userid, - Match_Status_1, - Medical_School_of_Graduation) %>%
  #as.numeric(USMLE_Step_2_CK_Score) %>%
  dplyr::filter(Age < 100) %>%
  dplyr::mutate(Gold_Humanism_Honor_Society = dplyr::recode(Gold_Humanism_Honor_Society, Not_a_Member = "No"), Medical_Degree = dplyr::recode(Medical_Degree, `B.A.O.,M.D.` = "MD", `DO/MS` = "DO", `DO/PhD` = "DO", `M.B.,B.S.,M.B.,B.S.` = "MD", `M.B.,B.S.,M.D.` = "MD", `M.D.,M.B.,B.S.` = "MD", `M.D.,M.D.` = "MD", `M.D./Ph.D.,M.D.` = "MD", `M.Surg.,M.B.,B.S.` = "MD", MD = "MD")) %>%
  dplyr::filter(Match_Status %in% c("Match", "Did Not Match")) %>%
  base::droplevels(all_years$Match_Status) %>%
  select(- Malpractice_Cases_Pending)

###Exploration of the Data
all_years
dim(all_years)
View(all_years)
data.table::data.table(all_years)
funModeling::freq(data=all_years, plot = FALSE, na.rm = FALSE)

view(summarytools::dfSummary(x = all_years, justify = "l", style = "multiline", varnumbers = FALSE, valid.col = FALSE, tmp.img.dir = "./img", max.distinct.values = 5))

write_csv(x = all_years, path = "~/Dropbox/Nomogram/nomogram/data/All_ERAS_data_merged_output_2_1_2020.csv")

