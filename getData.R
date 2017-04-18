library(selectr)
library(rvest)
library(httr)
library(foreach)
library(doParallel)

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
  models <- content(te,"parsed")
  models <- do.call(rbind.data.frame, models$Models)
  models$make <- maker$Name[i]
  models$makeID <- maker$ID[i]
  lmdata <- rbind(lmdata,models)
}

save(lmdata,file="modelNum.RData")

load("modelNum.RData")

birth <- "1976-01-21"
registerYear <- "2013"
e <- "30"
carInfo <- lmdata
maritalStatus <- c("Married","Single")
gender <- c("Male","Female")
drivingExperience <- c("None","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
                       "Ten","Eleven","Twelve","Thirteen","Fourteen","FifteenAndAbove")
noClaimValue <- c(0,10,20,30,40,50)
occupation <- "Indoor"
offPeak <- "false"

home<-"https://sg-api.gobear.com/api/insurance/car?CoverageFiltrations=&"

top4 <- c()

for(i in 1:nrow(lmdata)){
  for(j in maritalStatus){
    for(k in gender){
      for(l in drivingExperience){
        for(m in noClaimValue){
          # carInfoUrl <- paste0("&make=",lmdata$makeID[i],"&model=",lmdata$ID[i])
          url <- paste0(home,"DateOfBirth=",birth,"&RegisterYear=",registerYear,
                        "&ModelGuid=",lmdata$ID[i],"&MaritalStatus=",j,
                         "&Gender=",k,"&DrivingExperience=",l,
                         "&NoClaimValue=",m,"&Occupation=",occupation,
                         "&OffPeak=",offPeak)

          tem <- GET(url)
          tem <- content(tem,"parsed")
          
          candidate <- sapply(tem$Insurances, function(x) x$TotalScore)
          Company <- sapply(tem$Insurances, function(x) x$InsurerName)
          Plan <- sapply(tem$Insurances, function(x) x$PlanName)
          Price <- sapply(tem$Insurances, function(x) x$CheckoutOptions[[1]]$Premium)
          
          Company <- Company[candidate==25]
          Plan <- Plan[candidate==25]
          Price <- Price[candidate==25]
          Price <- ifelse(Price==0,1000000,Price)
          Price <- Price[order(Price)][1:4]
          Plan <- Plan[order(Price)][1:4]
          Company <- Company[order(Price)][1:4]
          Price <- ifelse(Price==1000000,"NoPrice",Price)
          
          tem <- data.frame(Gender=k,MaritalStatus=j,Occupation=occupation,
                            DOB=birth,AgeOfDriver=e,LicenceYears=registerYear,
                            NCD=m,OffPeak=offPeak,
                            DrivingExperience=l,
                            Make=lmdata$make[i],Model=lmdata$Name[i],CC=lmdata$Capacity[i],
                            company1=Company[1],Plan1=Plan[1],Price1=Price[1],
                            company2=Company[2],Plan2=Plan[2],Price2=Price[2],
                            company3=Company[3],Plan3=Plan[3],Price3=Price[3],
                            company4=Company[4],Plan4=Plan[4],Price4=Price[4]
                            )
          
          top4 <- rbind(top4,tem)
          print(tem)
          write.csv(top4,"./data.csv",row.names = F)
        }
      }
    }
  }
}



# 
# for(i in nrow(lmdata)){
#   for(j in maritalStatus){
#     for(k in gender){
#       for(l in drivingExperience){
#         for(m in noClaimValue){
# 
# getData <- function(lmdata,maritalStatus,gender,drivingExperience,noClaimValue)
# urlData1 <- merge(data.frame(drivingExperience),data.frame(noClaimValue))
# urlData2 <- merge(data.frame(gender),data.frame(maritalStatus))
# urlData <- merge(urlData1,urlData2)
# 
# url <- paste0(home,"DateOfBirth=",birth,"&RegisterYear=",registerYear,
#               "&ModelGuid=",lmdata$ID[i],"&MaritalStatus=",urlData$maritalStatus,
#               "&Gender=",urlData$gender,"&DrivingExperience=",urlData$drivingExperience,
#               "&NoClaimValue=",urlData$noClaimValue,"&Occupation=",occupation,
#               "&OffPeak=",offPeak)
# 
# registerDoParallel(32)
# 
# te<-foreach(uu = url, 
#             .combine = list,
#             .multicombine = TRUE)  %dopar%  
#   content(GET(uu),"parsed")
# 
# te<-lapply(url,function(x) content(GET(x),"parsed"))
# tem <- content(tem,"parsed")
# 
# candidate <- sapply(tem$Insurances, function(x) x$TotalScore)
# Company <- sapply(tem$Insurances, function(x) x$InsurerName)
# Plan <- sapply(tem$Insurances, function(x) x$PlanName)
# Price <- sapply(tem$Insurances, function(x) x$CheckoutOptions[[1]]$Premium)
# 
# Company <- Company[candidate==25]
# Plan <- Plan[candidate==25]
# Price <- Price[candidate==25]
# Price <- ifelse(Price==0,1000000,Price)
# Price <- Price[order(Price)][1:4]
# Plan <- Plan[order(Price)][1:4]
# Company <- Company[order(Price)][1:4]
# Price <- ifelse(Price==1000000,"NoPrice",Price)
# 
# tem <- data.frame(Gender=k,MaritalStatus=j,Occupation=occupation,
#                   DOB=birth,AgeOfDriver=e,LicenceYears=registerYear,
#                   NCD=m,OffPeak=offPeak,
#                   DrivingExperience=l,
#                   Make=lmdata$make[i],Model=lmdata$Name[i],CC=lmdata$Capacity[i],
#                   company1=Company[1],Plan1=Plan[1],Price1=Price[1],
#                   company2=Company[2],Plan2=Plan[2],Price2=Price[2],
#                   company3=Company[3],Plan3=Plan[3],Price3=Price[3],
#                   company4=Company[4],Plan4=Plan[4],Price4=Price[4]
# )