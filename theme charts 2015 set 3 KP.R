
facet.age.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="age"&
                           themes.database$Category.clean!="undeclared (age)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"),
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.6)+
  scale_size_manual(values=c(1.2,.8,.8,.8,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  
  facet_wrap(~Theme,ncol=2)




facet.ethnicity.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="ethnicity"&
                           themes.database$Category.clean!="undeclared (ethnicity)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"),
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\ncomparing different ethnicities")+
  facet_wrap(~Theme,ncol=2)


facet.carer.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="carer"&
                           themes.database$Category.clean!="undeclared (carer)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\ncomparing carers and others")+
  facet_wrap(~Theme,ncol=2)


facet.childcarer.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="child carer"&
                           themes.database$Category.clean!="undeclared (child carer)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\ncomparing child carers and others")+
  facet_wrap(~Theme,ncol=2)


facet.disability.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="disability"&
                           themes.database$Category.clean!="undeclared (disability)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\nby disability status")+
  facet_wrap(~Theme,ncol=2)


facet.grade.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="grade"&
                           themes.database$Category.clean!="undeclared (grade)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.8)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .8, .8, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\ncomparing grades")+
  facet_wrap(~Theme,ncol=2)


facet.group.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="Group"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.8)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .8, .8, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\ncomparing Groups")+
  facet_wrap(~Theme,ncol=2)



facet.hours.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="hours"&
                           themes.database$Category.clean!="job sharer"&
                           themes.database$Category.clean!="undeclared (hours)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2)+
  scale_size_manual(values=c(1.2,.8,.8))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\nby working hours")+
  facet_wrap(~Theme,ncol=2)



facet.service.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="length of service in BIS"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.5.pns)+
  scale_size_manual(values=c(1.2,.8,.8,.8,.8,.8,.4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\nby time in BIS")+
  facet_wrap(~Theme,ncol=2)


facet.location.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="location"&
                           themes.database$Category.clean!="undeclared (location)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.3)+
  scale_size_manual(values=c(1.2, .8, .8, .8))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
  #ggtitle("Corrected theme scores,\ncomparing locations")+
  facet_wrap(~Theme,ncol=2)


facet.profession.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="profession"&
                           themes.database$Category.clean!="undeclared (profession)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2,labels=c("BIS (100%)","professional (30%)","not professional (69%)"))+
  scale_size_manual(values=c(1.2, .8, .8))+
  
  guides(colour=FALSE)+
 # ggtitle("Corrected theme scores,\ncomparing professionals and others")+
  facet_wrap(~Theme,ncol=2)


facet.religion.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="religion"&
                           themes.database$Category.clean!="undeclared (religion)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.3.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\ncomparing religions")+
  facet_wrap(~Theme,ncol=2)


facet.gender.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="gender"&
                           themes.database$Category.clean!="undeclared (gender)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\ncomparing genders")+
  facet_wrap(~Theme,ncol=2)


facet.sexuality.3<-
  ggplot(
    data=themes.database[themes.database$Breakdown=="sexuality"&
                           themes.database$Category.clean!="undeclared (sexuality)"&
                           themes.database$Theme %in% theme.set.3,],
    aes(x=factor(Year),
        y=Value,
        group=Category,
        colour=Category,
        size=Category
    ))+
  
  geom_line()+
  scale_x_discrete(name="")+
  ##percent is a function from the scales package, horizontal.limits is set by me 
  scale_y_continuous(labels=percent,name=" ", limits=horizontal.limits.pb)+
  theme_bw()+
  theme(panel.grid.major.x=element_blank(), legend.position="none", panel.background=element_rect("slategray2"), 
        plot.title=element_text(size=rel(1.5)), axis.text.y=element_text(colour="darkred"))+
  
  # #the next two lines will need manually changing for the palette and line widths
  scale_colour_manual(values=palette.2.pns)+
  scale_size_manual(values=c(1.2, .8, .8, .4))+
  
  guides(colour=guide_legend(title=NULL),size=guide_legend(title=NULL))+
 # ggtitle("Corrected theme scores,\ncomparing sexuality")+
  facet_wrap(~Theme,ncol=2)



png(filename = "age3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.age.3
dev.off()

png(filename = "ethnicity3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.ethnicity.3
dev.off()

png(filename = "carer3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.carer.3
dev.off()

png(filename = "childcarer3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.childcarer.3
dev.off()

png(filename = "disability3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.disability.3
dev.off()

png(filename = "grade3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.grade.3
dev.off()

png(filename = "group3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.group.3
dev.off()

png(filename = "hours3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.hours.3
dev.off()

png(filename = "service3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.service.3
dev.off()

png(filename = "location3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.location.3
dev.off()

png(filename = "profession3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.profession.3
dev.off()

png(filename = "religion3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.religion.3
dev.off()

png(filename = "gender3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.gender.3
dev.off()

png(filename = "sexuality3.png",width = 7.5,height = 7,units = "cm",res = 72*4)
facet.sexuality.3
dev.off()
