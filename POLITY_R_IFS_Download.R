## TITLE: Systemic Peace Pull
## AUTHOR: JAKE DUBBERT
## DATE: 1/8/2019

## The following R script reads in Polity, PITF and Systemic Peace data from the Systemic Peace website (www.systemicpeace.org)
## There are 33 series that need to be imported into IFs
## The data is cleaned up to extract the needed variables to import into IFs, concorded with the IFs Country Concordance list
## and then exported to a file named: POLITY_FINAL.xlsx - which will be located in your working directory
## IMPORTANT: Make sure you have the country concordance .csv file in your working directory
#### The link from the Sytemic Peace website may need to be updated before running code to get most recent version


#### TO RUN ENTIRE SCRIPT, PRESS CONTROL+SHIFT+ENTER


########################################################################333

## Install and load required packages for script
install.packages("readxl")
install.packages("RCurl")
install.packages("dplyr")
install.packages("openxlsx")

library(RCurl)
library(readxl)
library(dplyr)
library(openxlsx)

################################################################################
## DOWNLOAD  DATA
## NOTE: the links may need to be updated (Go to http://www.systemicpeace.org/inscrdata.html, right click on the Polity IV Annual Time Series, Excel Series, and copy link)
###################################################################################
## POLITY DATA
## Download .xls file from website 
url <- "http://www.systemicpeace.org/inscr/p4v2017.xls"
download.file(url, "polity.xls", mode = "wb")
polity <- read_xls("polity.xls")

## PITF DATA
url1 <- "http://www.systemicpeace.org/inscr/PITF%20Adverse%20Regime%20Change%202017.xls"
download.file(url1, "regime.xls", mode = "wb")
regime <- read_xls("regime.xls")
url2 <- "http://www.systemicpeace.org/inscr/PITF%20GenoPoliticide%202017.xls"
download.file(url2, "genocide.xls", mode = "wb")
genocide <- read_xls("genocide.xls")
url3 <- "http://www.systemicpeace.org/inscr/PITF%20Ethnic%20War%202017.xls"
download.file(url3, "ethnic.xls", mode = "wb")
ethnic <- read_xls("ethnic.xls")
url4 <- "http://www.systemicpeace.org/inscr/PITF%20Revolutionary%20War%202017.xls"
download.file(url4, "revol.xls", mode = "wb")
revol <- read_xls("revol.xls")

## STATE FAILURE DATA
url5 <- "http://www.systemicpeace.org/inscr/SFIv2017.xls"
download.file(url5, "statefailure.xls", mode = "wb")
sf <- read_xls("statefailure.xls")

#######################################################################################

## POLITY SERIES
polity <- subset(polity, select = -c(cyear:ccode, flag:fragment, prior:sf))
polity$PolityCombined <- polity$polity+10
names(polity)[names(polity)=="autoc"] <- "PolityAutoc"
names(polity)[names(polity)=="democ"] <- "PolityDemoc"
names(polity)[names(polity)=="durable"] <- "PolityDurable"
names(polity)[names(polity)=="xconst"] <- "PolityExecConstrain"
names(polity)[names(polity)=="xrcomp"] <- "PolityExecRecruitComp"
names(polity)[names(polity)=="xropen"] <- "PolityExecRecruitOpen"
names(polity)[names(polity)=="xrreg"] <- "PolityExecRecruitRegu"
names(polity)[names(polity)=="parcomp"] <- "PolityParticCompet"
names(polity)[names(polity)=="parreg"] <- "PolityParticRegulate"

polity$PolityPartialAutocCat <- ifelse(polity$polity > -7 & polity$polity <= -4, 1, 0)
polity$PolityPartialAutocCat2 <- ifelse(polity$polity > -4 & polity$polity <= 0, 1, 0)
polity$PolityPartialDemocCat <- ifelse(polity$polity >= 4 & polity$polity < 7, 1, 0)
polity$PolityPartialDemocCat2 <- ifelse(polity$polity >=0 & polity$polity < 4, 1, 0)

polity <- subset(polity, select = -c(polity:polity2, exrec:regtrans))

polity[polity == -66] <- NA
polity[polity == -77] <- NA
polity[polity == -88] <- NA


## PITF SERIES
genocide <- subset(genocide, select = -c(CCODE, MOBEGIN:PTYPE, DESC:DESC2))
names(genocide)[names(genocide)=="DEATHMAG"] <- "SFPITFGenocideMag"
genocide$SFPITFGenocideEV <- 1

regime <- subset(regime, select = -c(CCODE, MOBEGIN:MAGVIOL, DESC:DESC2))
names(regime)[names(regime)=="MAGAVE"] <- "SFPITFRegTranMag" 
regime$SFPITFRegTranEv <- 1

ethnic <- subset(ethnic, select = -c(CCODE, MOBEGIN:MAGAREA, DESC:DESC2))
names(ethnic)[names(ethnic)=="AVEMAG"] <- "SFPITFEthnicWarMag"
ethnic$SFPITFEthnicWarEv <- 1

revol <- subset(revol, select = -c(CCODE, MOBEGIN:MAGAREA, DESC:DESC2))
names(revol)[names(revol)=="AVEMAG"] <-"SFPITFRevolWarMag"
revol$SFPITFRevolWarEv <- 1

## State Failure Series
names(sf)[names(sf)=="ecoeff"] <- "SFCenSysPeaceEconEffect"
names(sf)[names(sf)=="ecoleg"] <- "SFCenSysPeaceEconLegit"
names(sf)[names(sf)=="effect"] <- "SFCenSysPeaceEffect"
names(sf)[names(sf)=="sfi"] <- "SFCenSysPeaceIndexScore"
names(sf)[names(sf)=="legit"] <- "SFCenSysPeaceLegit"
names(sf)[names(sf)=="poleff"] <- "SFCenSysPeacePolEffect"
names(sf)[names(sf)=="polleg"] <- "SFCenSysPeacePolLegit"
names(sf)[names(sf)=="seceff"] <- "SFCenSysPeaceSecEffect"
names(sf)[names(sf)=="secleg"] <- "SFCenSysPeaceSecLegit"
names(sf)[names(sf)=="soceff"] <- "SFCenSysPeaceSocEffect"
names(sf)[names(sf)=="socleg"] <- "SFCenSysPeaceSocLegit"
sf <- subset(sf, select = -region)



################################################################################################
## Concord Country Names with IFs Country list

ifsCountry <- read.csv("IFS_country_concordance_POLITY.csv")
polity <- merge(polity, ifsCountry, by.x = "country")






#################################################################################################
## Merge all series into ONE workbook
OUT <- createWorkbook()
addWorksheet(OUT, "polity")
addWorksheet(OUT, "ethnic")
addWorksheet(OUT, "RegTran")
addWorksheet(OUT, "genocide")
addWorksheet(OUT, "revol")
addWorksheet(OUT, "statefailure")
writeData(OUT, sheet = "polity", x = polity)
writeData(OUT, sheet = "ethnic", x = ethnic)
writeData(OUT, sheet = "RegTran", x = regime)
writeData(OUT, sheet = "genocide", x = genocide)
writeData(OUT, sheet = "revol", x = revol)
writeData(OUT, sheet = "statefailure", x = sf)
saveWorkbook(OUT, "POLITY_FINAL.xlsx")
