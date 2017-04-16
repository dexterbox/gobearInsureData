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
#  print(i)
  te <- GET(paste0("https://sg-api.gobear.com/api/cars/makes/",maker$ID[i],"/models"))
#  print(te)
  models <- content(te,"parsed")
  models <- do.call(rbind.data.frame, models$Models)
  models$make <- maker$Name[i]
  models$makeID <- maker$ID[i]
  lmdata <- rbind(lmdata,models)
}

save(lmdata,file="modelNum.RData")

load("modelNum.RData")

birth <- "1976-01-21"
e <- "30"
registerYear <- "2013"
carInfo <- lmdata
#carInfo <- paste0("&make=",lmdata$makeID,"&model=",lmdata$ID)
plans <- "Comprehensive"
maritalStatus <- c("Married","Single")
gender <- c("Male","Female")
drivingExperience <- c("None","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
                       "Ten","Eleven","Twelve","Thirteen","Fourteen","FifteenAndAbove")
noClaimValue <- c(0,10,20,30,40,50)
occupation <- "Indoor"
offPeak <- "false"

home<-"https://www.gobear.com/sg/insurance/car/quote-online?"

## docker run -d -p 4445:4444 --name ff selenium/standalone-firefox:3.3.0
## docker inspect ff .. IPAddress > if using in docker

remDr <- remoteDriver(remoteServerAddr="192.168.99.100", port = 4445L, 
                      browserName="firefox")
remDr$open()

top4 <- c()

for(i in nrow(carInfo)){
  for(j in maritalStatus){
    for(k in gender){
      for(l in drivingExperience){
        for(m in noClaimValue){
          carInfoUrl <- paste0("&make=",lmdata$makeID[i],"&model=",lmdata$ID[i])
          url <- paste0(home,"birth=",birth,"&e=",e,"&registerYear=",registerYear,
                        carInfoUrl,"&plans=",plans,"&maritalStatus=",j,
                         "&gender=",k,"&drivingExperience=",l,
                         "&noClaimValue=",m,"&occupation=",occupation,
                         "&offPeak=",offPeak)

          remDr$navigate(url)
          Sys.sleep(1)
          tem <- remDr$getPageSource()[[1]]
          tem <- read_html(tem)
          comp <- tem %>% html_nodes("h1") %>% html_text()
          plan <- tem %>% html_nodes("h2") %>% html_text()
          price <- tem %>% html_nodes("span.value") %>% html_text()
          if(length(price)!=length(comp)){
            tem <- sample("NA",10,replace = T)
            price <- c(price,tem)
            price <- price[1:10]
          }
          
          tem <- data.frame(Gender=k,MaritalStatus=j,Occupation=occupation,
                            DOB=birth,AgeOfDriver=e,LicenceYears=registerYear,
                            NCD=m,OffPeak=offPeak,
                            DrivingExperience=l,
                            Make=lmdata$make[i],Model=lmdata$Name[i],CC=lmdata$Capacity[i],
                            company1=comp[1],Plan=plan[1],Price=price[1],
                            company1=comp[2],Plan=plan[2],Price=price[2],
                            company1=comp[3],Plan=plan[3],Price=price[3],
                            company1=comp[4],Plan=plan[4],Price=price[4]
                            )
          
          top4 <- rbind(top4,tem)
          print(tem)
        }
      }
    }
  }
}







