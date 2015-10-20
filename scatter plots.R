scatter.database$Category[scatter.database$Category=="straight"]<-"heterosexual"
scatter.database$Category[scatter.database$Category=="not straight"]<-"not heterosexual"

###################################################################################################################
#This produces plots for 1 category for each theme

win.metafile("scatter ShEx by theme.wmf",width=6,height=8)

ggplot(subset(x = scatter.database,
              Category=="ShEx"&Breakdown=="Group"&Theme!="BIS questions"&Theme!="Pay and benefits"&Theme!="Wellbeing"),
              aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Question),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant charts for ShEx by theme")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
#  coord_cartesian(xlim = c(-.05,.05), ylim = c(-.12,.12))+
  facet_wrap(~Theme, ncol = 3)

dev.off()
###################################################################################################################


###################################################################################################################
#This produces plots for 1 question for each breakdown

win.metafile("scatter B17 by breakdown.wmf",width=6,height=8)

ggplot(subset(x = scatter.database,Question=="B17"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Category),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant chart for question B17\n'I think that my performance is evaluated fairly'")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  coord_cartesian(xlim = c(-.25,.20), ylim = c(-.20,.12))+
  facet_wrap(~Breakdown, ncol = 3)

dev.off()
###################################################################################################################


###################################################################################################################
#This produces plots of question for each category for a theme

win.metafile("scatter Wellbeing by age.wmf",width=6,height=8)

ggplot(subset(x = scatter.database,
              Breakdown=="Age"&Theme=="Wellbeing"&Category!="undeclared age"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Question),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant charts for Wellbeing theme, by age")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  #coord_cartesian(xlim = c(-.10,.15), ylim = c(-.10,.40))+
  facet_wrap(~Category, ncol = 2)

dev.off()
###################################################################################################################


###################################################################################################################
#This produces plots of category for each question of a theme

ggplot(subset(x = scatter.database,
              Breakdown=="Hours"&Theme=="My manager"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Category),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant chart for My manager")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  # coord_cartesian(xlim = c(-.09,.09), ylim = c(-.12,.12))+
  facet_wrap(~Question, ncol = 3)
###################################################################################################################



###################################################################################################################
#This produces plots for 1 EM directorate for each theme

win.metafile("scatter LM by theme.wmf",width=6,height=8)

ggplot(subset(x = scatter.database.EM,
              Breakdown=="LM"&Theme!="BIS questions"&Theme!="Pay and \nbenefits"&Theme!="Wellbeing"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Question),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant charts for LM by theme")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  #  coord_cartesian(xlim = c(-.05,.05), ylim = c(-.12,.12))+
  facet_wrap(~Theme, ncol = 3)

dev.off()
###################################################################################################################




###################################################################################################################
#This produces plots of question for each directorate for a chosen theme

win.metafile("scatter TA by directorate.wmf",width=6,height=8)

ggplot(subset(x = scatter.database.EM,
              Theme=="Taking action"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Question),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant charts for Taking action, by directorate")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  #coord_cartesian(xlim = c(-.10,.15), ylim = c(-.10,.40))+
  facet_wrap(~Breakdown, ncol = 3)

dev.off()
###################################################################################################################


###################################################################################################################
#This produces plots of directorate for each question of a chosen theme

win.metafile("scatter Resources by question.wmf",width=6,height=8)

ggplot(subset(x = scatter.database.EM,
              Theme=="Resources"),
       aes(x=Change,y=Benchmarked))+
  geom_text(aes(label=Breakdown),size=3)+
  geom_hline(yintercept=0)+geom_vline(xintercept=0)+
  ggtitle("Quadrant chart for Resources and workload")+
  scale_x_continuous(labels=percent,name="change since 2013")+
  scale_y_continuous(labels=percent,name="difference from CS benchmark")+
  theme_bw()+theme(panel.grid.major.x=element_blank(),panel.grid.major.y=element_blank())+
  # coord_cartesian(xlim = c(-.09,.09), ylim = c(-.12,.12))+
  facet_wrap(~Question, ncol = 3)

dev.off()
###################################################################################################################
