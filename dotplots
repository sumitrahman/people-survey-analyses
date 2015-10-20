AAA<-themes.directorates

# win.metafile("dotplot Resources by directorates CCP.wmf",width=6,height=8)
# 
# ggplot(data=AAA[AAA$theme=="Resources",],
#        aes(y=reorder(directorate,index.score),x=index.score))+
#   geom_point(aes(colour=group,size=CCP))+
#   scale_colour_brewer(palette="Paired")+
#   theme_bw()+
#   ggtitle("Resources and Workload Index for directorates")+
#   guides(colour=guide_legend(title="Group"),size=FALSE)+
#   scale_x_continuous(labels=percent,name="index score")+
#   scale_size_manual(values=c(3,5))+
#   theme(axis.title.y=element_blank(),
#         panel.grid.minor.x=element_blank(),
#         panel.grid.major.x=element_blank(),
#         panel.grid.major.y=element_line(colour="lightblue",linetype="dotted"),
#         axis.text.y=element_blank(),
#         legend.position=c(1,0),legend.justification=c(1,0))
# 
# dev.off()

win.metafile("dotplot My manager by directorates.wmf",width=6,height=8)

ggplot(data=AAA[AAA$theme=="My manager",],
       aes(y=reorder(directorate,index.score),x=index.score))+
  geom_point(aes(colour=group),size=4)+
  scale_colour_brewer(palette="Paired")+
  theme_bw()+
  ggtitle("My manager Index for directorates")+
  guides(colour=guide_legend(title="Group"),size=FALSE)+
  scale_x_continuous(labels=percent,name="index score")+
  theme(axis.title.y=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        panel.grid.major.y=element_line(colour="lightblue",linetype="dotted"),
        axis.text.y=element_text(size=rel(0.5)),
        legend.position=c(1,0),legend.justification=c(1,0))

dev.off()
