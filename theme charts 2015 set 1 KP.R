facet.age.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="age"&
                           themes.database$Category.clean!="undeclared (age)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.6)+
  scale_size_manual(values=c(1.2,.8,.8,.8,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing different ages")+
  facet_wrap(~Theme,ncol=2)


facet.ethnicity.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="ethnicity"&
                           themes.database$Category.clean!="undeclared (ethnicity)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing different ethnicities")+
  facet_wrap(~Theme,ncol=2)


facet.carer.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="carer"&
                           themes.database$Category.clean!="undeclared (carer)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing carers and others")+
  facet_wrap(~Theme,ncol=2)


facet.childcarer.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="child carer"&
                           themes.database$Category.clean!="undeclared (child carer)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing child carers and others")+
  facet_wrap(~Theme,ncol=2)


facet.disability.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="disability"&
                           themes.database$Category.clean!="undeclared (disability)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\nby disability status")+
  facet_wrap(~Theme,ncol=2)


facet.grade.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="grade"&
                           themes.database$Category.clean!="undeclared (grade)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.03),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.8)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .8, .8, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing grades")+
  facet_wrap(~Theme,ncol=2)


facet.group.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="Group"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.03),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.8)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .8, .8, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing Groups")+
  facet_wrap(~Theme,ncol=2)



facet.hours.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="hours"&
                           themes.database$Category.clean!="job sharer"&
                           themes.database$Category.clean!="undeclared (hours)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2)+
  scale_size_manual(values=c(1.2,.8,.8))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\nby working hours")+
  facet_wrap(~Theme,ncol=2)



facet.service.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="length of service in BIS"&
                           
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.5.pns,labels=c("BIS (100%)","less than 1 year (13%)","1-5 years (27%)","5-10 years (19%)","10-20 years (17%)","20+ years (19%)","undeclared\n(6%)"))+
  scale_size_manual(values=c(1.2,.8,.8,.8,.8,.8,.4),labels=c("BIS (100%)","less than 1 year (13%)","1-5 years (27%)","5-10 years (19%)","10-20 years (17%)","20+ years (19%)","undeclared\n(6%)"))+

  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\nby time in BIS")+
  facet_wrap(~Theme,ncol=2)


facet.location.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="location"&
                           themes.database$Category.clean!="undeclared (location)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.3)+
  scale_size_manual(values=c(1.2, .8, .8, .8))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing locations")+
  facet_wrap(~Theme,ncol=2)


facet.profession.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="profession"&
                           themes.database$Category.clean!="undeclared (profession)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2)+
  scale_size_manual(values=c(1.2, .8, .8))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing professionals and others")+
  facet_wrap(~Theme,ncol=2)


facet.religion.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="religion"&
                           themes.database$Category.clean!="undeclared (religion)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.3.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing religions")+
  facet_wrap(~Theme,ncol=2)


facet.gender.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="gender"&
                           themes.database$Category.clean!="undeclared (gender)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing genders")+
  facet_wrap(~Theme,ncol=2)




facet.sexuality.1<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="sexuality"&
                           themes.database$Category.clean!="undeclared (sexuality)"&
                           themes.database$Theme %in% theme.set.1,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name="Theme score")+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(),legend.key=element_blank(),legend.position=c(1,0.07),legend.justification=c(1,0),
        plot.title=element_text(size=rel(1.5)))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  ggtitle("Theme scores,\ncomparing sexuality")+
  facet_wrap(~Theme,ncol=2)



png(filename = "age1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.age.1
dev.off()

png(filename = "ethnicity1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.ethnicity.1
dev.off()

png(filename = "carer1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.carer.1
dev.off()

png(filename = "childcarer1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.childcarer.1
dev.off()

png(filename = "disability1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.disability.1
dev.off()

png(filename = "grade1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.grade.1
dev.off()

png(filename = "group1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.group.1
dev.off()

png(filename = "hours1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.hours.1
dev.off()

png(filename = "service1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.service.1
dev.off()

png(filename = "location1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.location.1
dev.off()

# png(filename = "profession1.png",width = 13,height = 24,units = "cm",res = 72*4)
# facet.profession.1
# dev.off()

png(filename = "religion1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.religion.1
dev.off()

png(filename = "gender1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.gender.1
dev.off()

png(filename = "sexuality1.png",width = 13,height = 24,units = "cm",res = 72*4)
facet.sexuality.1
dev.off()
