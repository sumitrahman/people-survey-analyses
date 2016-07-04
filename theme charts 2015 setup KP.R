require(ggplot2)
require(scales)

setwd("S:/Datasets-Working/SURVEY-SUPPORT-TEAM/Pulse and People/2015/People Survey 2015/R working")

database<-read.csv(file = 'database theme charts 3.csv',header = TRUE)

  
themes.database<-database[,c(1:5,8)]


themes.database$Category<-factor(themes.database$Category,levels=c("BIS (100%)",
                                                                   "16-29 (12%)","30-39 (24%)","40-49 (25%)","50-59 (24%)","60+ (4%)","PNS (age) (10%)", "undeclared (age) (1%)",
                                                                   "White British (73%)","BAME (17%)","PNS (ethnicity) (9%)","undeclared (ethnicity) (1%)",
                                                                   "carer (18%)","not a carer (75%)","PNS (carer) (6%)","undeclared (carer) (1%)",
                                                                   "child carer (32%)","not a child carer (62%)","PNS (child carer) (5%)","undeclared (child carer) (2%)",
                                                                   "disabled (14%)","not disabled (78%)","PNS (disability) (7%)","undeclared (disability) (1%)",
                                                                   "SCS (8%)","G6 (11%)","G7 (27%)","FS (4%)","SEO (14%)","HEO (19%)","EO (11%)","AA/AO (3%)","undeclared (grade) (3%)",
                                                                   "BS (18%)","EM (22%)","FCDT (6%)","LS (6%)","MPST (4%)","PSHE (15%)","ShEx (4%)","SDLG (18%)",
                                                                   "full time (86%)","part time (13%)","job sharer (1%)","undeclared (hours) (1%)",
                                                                   "less than 1 year (13%)","1-5 years (27%)","5-10 years (19%)","10-20 years (17%)","more than 20 years (19%)","undeclared (length of service) (6%)",
                                                                   "London (76%)","Sheffield (10%)","other location (13%)","undeclared (location) (0%)",
                                                                   "member of a professional community (30%)","not a member of a professional community (69%)","undeclared (profession) (1%)",
                                                                   "no religion (41%)","Christian (40%)","other religion (6%)","PNS (religion) (12%)", "undeclared (religion) (1%)",
                                                                   "female (45%)","male (47%)","PNS (gender) (7%)","undeclared (gender) (1%)",
                                                                   "LGB (5%)","heterosexual (82%)","PNS (sexuality) (12%)","undeclared (sexuality) (1%)",
                                                                   "undeclared"))


themes.database$Theme<-factor(themes.database$Theme,levels=c("Engagement Index", "Inclusion and fair treatment","Leadership and managing change",
                                                             "My Manager", "My Work", "Organisational objectives and purpose", "Learning and Development",
                                                             "My Team","Resources and Workload", "Pay and Benefits", "Leadership statement"))
theme.set.1<-c("Engagement Index","Learning and Development","Leadership and managing change","Resources and Workload","My Manager")
theme.set.2<-c("Organisational objectives and purpose","Inclusion and fair treatment","My Team", "My Work")
theme.set.3<-c("Pay and Benefits")


palette.2.pns<-c("#000000","#d95f02","#7570b3","#999999")
palette.2<-c("#000000","#d95f02","#7570b3")
palette.3<-c("#000000","#1b9e77","#d95f02","#7570b3")
palette.3.pns<-c("#000000","#1b9e77","#d95f02","#7570b3","#999999")
palette.5<-c("#000000","#1b9e77","#d95f02","#7570b3","#e7298a","#66a61e")
palette.5.pns<-c("#000000","#1b9e77","#d95f02","#7570b3","#e7298a","#66a61e","#999999")
palette.8<-c("#000000","#313695","#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33","#a65628","#f781bf")
palette.5.sequential<-c("#000000","#d4ffe7","#a1dab4","#41b6c4","#2c7fb8","#253494")
palette.5.sequential.pns<-c("#000000","#d4ffe7","#a1dab4","#41b6c4","#2c7fb8","#253494","#999999")
palette.6<-c("#000000","#f46d43","#fdae61","#4575b4","#d73027","#313695","#74add1") 
palette.7<-c("#a50026","#000000","#d73027","#4575b4","#f46d43","#74add1","#fdae61","#313695","#313695") #9 categories this is colourblind friendly


horizontal.limits<-c(.4,.9)
horizontal.limits.pb<-c(.2,.55)
horizontal.limits.age<-c(.40,.80)
horizontal.limits.parttwo<-c(.63,.85)
horizontal.limits.parttwograde<-c(.63,.90)
