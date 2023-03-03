## Set Base File 
base<-here::here('Data', 'Med', 'GATES')

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

### Make GATES graphs
setwd(base)
file.names <- list.files(path = ".")
G <- bind_rows(lapply(file.names, FUN=read.csv))
G$X <- NULL

G_coefs <- sapply(G[,1:3],median)
G_UL <- sapply(G[,4:6],median)
G_LL <- sapply(G[,7:9],median)
Gs <- c("1st","2nd","3rd")

GATES <- data.frame(Gs,G_coefs,G_UL,G_LL)

figure13_path = here::here('Results', 'Figures', 'FigureA13_GATES.pdf')

pdf(figure13_path,
    width = 10, height = 7)

GATES_plot = ggplot(GATES,aes(x=Gs,y=G_coefs))+
  geom_pointrange(aes(ymin=G_UL,ymax=G_LL))+
  my_theme_vert()+
  labs(x="Tercile of Treatment Effect",y="Estimated Treatment Effect")+
  scale_y_continuous(breaks=seq(-1.2,0.2,0.2),labels=scales::comma)

print(GATES_plot)

dev.off()

extrafont::embed_fonts(figure13_path, outfile=figure13_path)

