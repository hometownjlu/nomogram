# A Model to Predict Chances of Matching into Obstetrics and Gynecology Residency

*Objective:  *
*We sought to construct and validate a model that predict a medical student's chances of matching into an obstetrics and gynecology residency.*

ERAS is a centralized solution to the medical residency application and documents distribution process. The data source to be used for the project is the Electronic Residency Application Service data that was in discrete fields in the application.  No hand-searching of data was done. The data was exported from the ERAS Program Director Work Station under the Archives menu.The data is collected by the University of Colorado OBGYN residency that has both a categorical and a preliminary position.  Medical students who applied to the preliminary position were considered to be unmatched. The data set of years 2015, 2016, 2017, and 2018 applicants to the University of Colorado OBGYN residency. The data is contained in a data frame called 'all_data'. In advance, we might anticipate that USMLE Step 1 Score and US or Canadian Applicant will be key predictors.  Match Status is the dependent Variable and shows the medical students who applied to the OBGYN residency. 

# Codebook
A codebook is a technical description of the data that was collected for a particular purpose. It describes how the data are arranged in the computer file or files, what the various numbers and letters mean, and any special instructions on how to use the data properly.

* Predictors under consideration:
1. `all_data$white_non_white` - Dichotomoized from ethnicity fields in ERAS data, 2 level categorical
2. `all_data$Age` - Age at the time of the match, numerical variable
3. `all_data$Year` - Year of participation in the match, 4 level categorical
4. `all_data$Gender` - Male or Female, 2 level categorical
5. `all_data$Couples_Match` - PArticipating in the couples match? 2 level categorical
6. `all_data$US_or_Canadian_Applicant` - Are they a US Senior or an IMG, 2 level categorical 
7. `all_data$Medical_Education_Interrupted` - Taking breaks, 2 level categorical
8. `all_data$Alpha_Omega_Alpha` - Membership in AOA, 3 level categorical
9. `all_data$Military_Service_Obligation`
10. `all_data$USMLE_Step_1_Score` - I did not use Step 2 score because most students will not have those numbers at the time they apply, numerical variable
11. `all_data$Count_of_Poster_Presentation` - numerical variable
12. `all_data$Count_of_Oral_Presentation` - numerical variable
13. `all_data$Count_of_Articles_Abstracts` - numerical variable
14. `all_data$Count_of_Peer_Reviewed_Book_Chapter` - numerical variable
15. `all_data$Count_of_Other_than_Published` - numerical variable
16. `all_data$Visa_Sponsorship_Needed` - numerical variable
17. `all_data$Medical_Degree` - Allopathic versus Osteopathic medical school education, 2 level categorical

This data was cleaned in a separate R script with the help of exploratory.io.  

Packrat is in use to control package versions and a packrat.lock file is posted to my github repository.  This will allow for easier reproducibility.  Packrat records the exact package versions you depend on, and ensures those exact versions are the ones that get installed wherever you go.  We can also control the environment by deploying the project inside a Docker container as needed.  The project was created in R version 3.6.1 and run inside RStudio 1.2.5019.  

Please contact me with any questions or concerns: tyler (dot) muffly (at) dhha (dot) org.  

A list of medical schools are available at:
https://members.aamc.org/eweb/DynamicPage.aspx?site=AAMC&webcode=AAMCOrgSearchResult&orgtype=Medical%20School

A list of clinical OBGYN departments with amount of NIH dollars was found at:
http://www.brimr.org/NIH_Awards/2019/NIH_Awards_2019.htm
