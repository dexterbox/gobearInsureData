library(selectr)
library(rvest)
library(RSelenium)
library(httr)

options(stringsAsFactors = F)

# get list of cars
maker <- GET("https://sg-api.gobear.com/api/cars/makes/")
maker <- content(maker,"parsed") %>% .[grep("^[a-zA-Z]",.)]
maker <- do.call(rbind.data.frame, maker$Makes)[-6,] %>%unique()

# get list of model number with for loop

lmdata<-c()
for (i in 1:nrow(maker)){
  print(i)
  te <- GET(paste0("https://sg-api.gobear.com/api/cars/makes/",maker$ID[i],"/models"))
  print(te)
  models <- content(te,"parsed")
  models <- do.call(rbind.data.frame, models$Models)
  models$make <- maker$Name[i]
  lmdata <- rbind(lmdata,models)
}

save(lmdata,file="modelNum.RData")

load("modelNum.RData")

maritalStatus <- c("Married","Single")
gender <- c("Male","Female")
drivingExperience <- c("None","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
                       "Ten","Eleven","Twelve","Thirteen","Fourteen","FifteenAndAbove")
noClaimValue <- c(0,10,20,30,40,50)

## docker run -d -p 4445:4444 --name ff selenium/standalone-firefox:3.3.0
## docker inspect ff .. IPAddress

url<-"https://www.gobear.com/sg/insurance/car/quote-online?birth=1987-01-01&maritalStatus=Married&gender=Male&drivingExperience=Five&noClaimValue=30&registerYear=2013&make=47abfcbb-87f4-4964-9b66-60b2716b47bd&model=4ab7b203-da15-4c7c-8178-15ab1777bcba&plans=Comprehensive&occupation=Indoor&offPeak=false"

remDr <- remoteDriver(remoteServerAddr="172.17.0.3", port = 4444L, browserName="firefox")

remDr$open()
remDr$navigate(url)
tem <- remDr$getPageSource()[[1]]
tem <- read_html(tem)
comp <- tem %>% html_nodes("h1") %>% html_text()
plan <- tem %>% html_nodes("h2") %>% html_text()
price <- tem %>% html_nodes("span.value") %>% html_text()

home<-"https://www.gobear.com/sg"
remDr$navigate(url)
tem <- remDr$getPageSource()[[1]]
tem <- read_html(tem)
tem %>% html_nodes("#registerYears option") %>% html_text()
tem %>% html_nodes("#make option") %>% html_text() %>% .[grep("^[a-zA-Z]",.)]


