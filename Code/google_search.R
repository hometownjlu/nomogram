# Automatic search of Google for the residency program location of OBGYN residents
###  https://medium.com/@curiositybits/automating-the-google-search-for-the-web-presence-of-8000-organizations-54775e9f6097


install.packages("rvest")
install.packages("urltools")
require("rvest")
require("urltools")

applicants <- read.csv(url("https://www.dropbox.com/s/5lbyw8symto1mfx/residents_select_27.csv?raw=1"))

d <- applicants
View(d)

d$Website <- "NA"
d$Twitter <- "NA"
d$Facebook <- "NA"

for (name in d$x[1:1]) {
  print(paste0("finding the url for:",name, suffix, city, state, ProgramName))
  #Example: Aaron D Campbell, MD, Pittsburgh, PA, Allegheny Health Network Medical Education Consortium
  Sys.sleep(3) 
  url1 = utils::URLencode(paste0("https://www.google.com/search?q=",name))  #tested the output in google
  page1 <- read_html(url1)
 results1 <- page1 %>% rvest::html_nodes("cite") %>% rvest::html_text()
 
 result1 <- as.character(results1[1])
 d[d$x==name,]$Website <- result1
 
}


#Original example
for (name in d$OrganizationName[1:2000]) {
  print(paste0("finding the url for:",name))
  Sys.sleep(3) 
  
  url1 = URLencode(paste0(“https://www.google.com/search?q="",name))
 page1 <- read_html(url1)
 results1 <- page1 %>% html_nodes("cite") %>% html_text()
 result1 <- as.character(results1[1])
 d[d$OrganizationName==name,]$Website <- result1
 
 print(paste0(“finding the Twitter url for:”,name))
 url2 = URLencode(paste0(“https://www.google.com/search?q=",gsub("  ","+"",name),"+site:twitter.com"))
  page2 <- read_html(url2)
  results2 <- page2 %>% html_nodes("cite") %>% html_text()
  result2 <- as.character(results2[1])
  d[d$OrganizationName==name,]$Twitter <- result2
  
  print(paste0(“finding the Facebook url for:”,gsub(" ","+",name)))
  url3 = URLencode(paste0("https://www.google.com/search?q=",gsub(" ","+",name),"+site:facebook.com"))
 page3 <- read_html(url3)
 results3 <- page3 %>% html_nodes("cite") %>% html_text()
 result3 <- as.character(results3[1])
 d[d$OrganizationName==name,]$Facebook <- result3
}

View(d)
