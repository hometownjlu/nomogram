#Venn diagram
# Venn diagram with VennDiagram package

# Load the VennDiagram package
library(VennDiagram)

# applicants <- read_csv("~/Dropbox/Venn_test/All_Years_rename_56.csv") %>% 
#   unite(first_last_name, first_name, last_name, sep = " ", remove = FALSE, na.rm = FALSE) %>%
#   pull("first_last_name") 

applicants <- read.csv(url("https://www.dropbox.com/s/o4j1h7tqbmb5746/pull_All_Years_rename_56.csv?raw=1"))%>% pull(x)

# residents <- read_csv ("~/Dropbox/Venn_test/residents_distinct_23.csv") %>% 
#   unite(first_last_name, first_name, last_name, sep = " ", remove = FALSE, na.rm = FALSE) %>%
#   pull("first_last_name")

residents <- read.csv(url("https://www.dropbox.com/s/7v67tpo8v52q58k/pull_residents_distinct_23.csv?raw=1")) %>% pull(x)


set.seed(12)
set1 <-  applicants 
set2 <- residents
colors <- c("#6b7fff", "#c3db0f")

# Make Venn diagram from list of groups
venn.diagram(x = list(set1, set2) ,
             category.names = c("Applicants", "Residents"),
             filename = 'datadaft_venn.png',
             output=TRUE,
             
             #Output features
             imagetype="png", 
             height = 480, 
             width = 480,
             resolution = 300,
             compression = "lzw",
             
             #Circles
             scaled = FALSE,
             col = "black",
             fill = c("red", "blue"),
             # Circles
             lwd = 2,
             lty = 'blank',
             
             # Numbers
             cex = .6,
             fontface = "bold",
             fontfamily = "sans",
             
             # Set names
             cat.cex = 0.6,
             cat.fontface = "bold",
             cat.default.pos = "outer",
             cat.pos = c(-250, 200),
             
             margin = 0.15, 
             alpha=c(0.5,0.5),
             main="Applicants and Residents")

# # Display saved image
# options(repr.plot.height=12, repr.plot.width= 12)
library("png")
pp <- readPNG("datadaft_venn.png")
plot.new() 
rasterImage(pp,0,0,1.1,1.1)
