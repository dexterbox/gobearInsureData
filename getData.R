library(rvest)
library(httr)
library(RSelenium)

remDr <- remoteDriver(port = 4445L)

remDr$open()
remDr$getStatus()
