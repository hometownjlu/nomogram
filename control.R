#Controller

#Creates the data set
source("~/Dropbox/Nomogram/nomogram/All_ERAS_data_merged.R")
print("Sanity check:  The all_years file exists:")
file.exists("~/Dropbox/Nomogram/nomogram/data/All_ERAS_data_merged_output_2_1_2020.csv")

#Creates the custom functions
source("~/Dropbox/Nomogram/nomogram/Code/Additional_functions_nomogram.R", echo=TRUE)  #may need to run by hand

#Exploratory Data Analysis
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/00-Exploratory_Data_Analysis.Rmd", output_format = c("html_document", "pdf_document"), clean = TRUE)
pander::openFileInOS("~/Dropbox/Nomogram/nomogram/00-Exploratory_Data_Analysis.html")
pander::openFileInOS("~/Dropbox/Nomogram/nomogram/00-Exploratory_Data_Analysis.pdf")


#Split the Data
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/01-Split_Data.Rmd", output_format = c("html_document", "pdf_document"), clean = TRUE)
pander::openFileInOS("01-Split_Data.html")
pander::openFileInOS("01-Split_Data.pdf")

#Kitchen Sink Model
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/02-Kitchen_Sink_Model.Rmd", output_format = c("html_document", "pdf_document"), clean = TRUE)
pander::openFileInOS("02-Kitchen_Sink_Model.html")
pander::openFileInOS("02-Kitchen_Sink_Model.pdf")

#Feature Selection
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/03-Feature_Selection.Rmd", output_format = c("html_document", "pdf_document"), clean = TRUE)
pander::openFileInOS("03-Feature_Selection.html")
pander::openFileInOS("03-Feature_Selection.pdf")

#GLM_and_CART_models
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/04-GLM_and_CART_models.Rmd", output_format = c("html_document", "pdf_document"), clean = TRUE)
pander::openFileInOS("04-GLM_and_CART_models.html")
pander::openFileInOS("04-GLM_and_CART_models.pdf")

