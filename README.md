# nomogram
Logistic Regression Model to Predict Matching for medical students applying to OBGYN

The practice of matching medical student applicants to their preferred residency position is frought with anxiety and worry.  We attempt to create a model to predict matching given easily outputed variables from the ERAS site.  

The Electronic Residency Application Service (ERAS) is a centralized solution to the medical residency application and documents distribution process. The data source to be used for the project is the Electronic Residency Application Service data that was in discrete fields in the application.  No hand-searching of data was done. The data was exported from the ERAS Program Director Work Station under the Archives menu.The data is collected by the University of Colorado OBGYN residency that has both a categorical and a preliminary position.  Medical students who applied to the preliminary position were considered to be unmatched. The data set of years 2015, 2016, 2017, and 2018 applicants to the University of Colorado OBGYN residency. The data is contained in a data frame called 'all_data'. In advance, we might anticipate that USMLE Step 1 Score and US or Canadian Applicant will be key predictors.  Match Status is the dependent Variable and shows the medical students who applied to the OBGYN residency. 

