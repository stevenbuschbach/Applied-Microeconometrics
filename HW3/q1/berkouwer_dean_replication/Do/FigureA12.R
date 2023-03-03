######## Make Cookstoves Graphs ##########
## Define Themes
  my_theme_vert <- function(base_size = 16, ticks = TRUE) {
    ret <- theme_bw(base_size = base_size) +
      theme(legend.background = element_blank(),
            legend.position="bottom",
            legend.justification="center",
            legend.direction="horizontal",
            legend.key=element_blank(),
            panel.grid = element_line(colour = NULL),
            panel.border=element_blank(),
            panel.grid.minor = element_blank(),
            strip.background = element_blank(),
            plot.background = element_blank(),
            axis.line = element_blank(),
            axis.ticks=element_blank(),
            panel.grid.major.y = element_line(color = "#D2D2D2"),
            panel.grid.major.x = element_blank())
    
    if (!ticks) {
      ret <- ret + theme(axis.ticks = element_blank())
    }
    ret
  }
 
  
  my_pal <- function() {
    function(n) {
      colors <- c("#FF8554","#999083","#ffa200","#2EA7C4","#127289","#CE9C6E","#915722", "#993763", "#FFCB2B")
      unname(colors[seq_len(n)])
    }
  }
  
  my_scale_fill <- function(palette="fill",...) {
    discrete_scale("fill", "my", my_pal(), ...)
  }
  
  my_scale_color <- function(palette="colour",...) {
    discrete_scale("colour", "my", my_pal(), ...)
  }
  
  ####### Quantile Graphs ######### 
  
  datfile <- here::here('Data', 'Med','QTE.xlsx')
  dat <- readxl::read_excel(datfile, col_names=FALSE)
  dat <- t(dat)
  rownames(dat) <- NULL
  QTE_dat <- data.frame(b=dat[,1],se=dat[,2])
  QTE_dat <- QTE_dat %>% 
    mutate(ul=b+1.97*se, ll=b-1.96*se, quantile=seq(1,99,1))
  
  ###Plot###
  figure12_path = here::here('Results', 'Figures',"FigureA12_QTE.pdf")
  pdf(figure12_path,
    width = 10, height = 7)
  
   QTE_graph = ggplot(QTE_dat,aes(x=quantile))+geom_line(aes(y=b),color="#FF8554",size=1)+geom_ribbon(aes(ymin=ll,ymax=ul),alpha=0.2)+
    my_theme_vert() + labs(x="Quantile",y="Unconditional Local Quantile Treatment Effect")+
    scale_y_continuous(breaks=seq(-1.5,1.5,.5)) 
   
  print(QTE_graph)
  
  dev.off()
  
  extrafont::embed_fonts(figure12_path, outfile=figure12_path)
  
