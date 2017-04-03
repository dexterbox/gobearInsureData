library(selectr)
library(rvest)
library(RSelenium)

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
