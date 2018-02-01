#!/usr/bin/Rscript --vanilla

###############################################################################
# Command Line Processing
###############################################################################
suppressPackageStartupMessages(library(argparse));

# create parser object
parser <- ArgumentParser()

# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("-f", "--folder", type="character", 
                    help="Folder to save images",
                    metavar="folder")

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
args <- parser$parse_args()

if (is.null(args$folder)) {
  print("Expected one parameter: a target folder for the images, see usage data`.");
  parser$print_help();
  quit();
}

###############################################################################
# Plotting
###############################################################################

dir.create(args$folder[1], showWarnings = FALSE)

library(ggplot2)
library(BerginskiRMisc)
library(grid)

temp = read.csv('last_week.csv');
temp$Time = seq(along=temp$Time,from=7,to=0);

#missing values throw an error with ggplot, replacing missing vals with 0
temp$Relay[is.na(temp$Relay)] = 0;
temp$Relay = temp$Relay * temp$Time;
temp$Relay[temp$Relay == 0] = NA;

tempPlot = ggplot(temp,aes(x=Time)) + 
  geom_vline(aes(xintercept = Relay),size=0.1,alpha=0.25) +
  geom_line(aes(y=Target_temp,color="Target"),alpha=0.5) +
  geom_line(aes(y=Freezer_temp,color="Freezer"),alpha=0.9) +
  geom_line(aes(y=Outside_Temp,color="Outside"),alpha=0.9) + 
  scale_color_brewer("",type = "qual",palette = "Dark2") +
  ylab('Temperature (°F)') +
  theme_berginski() +
  coord_cartesian(ylim=c(30,100)) +
  scale_x_continuous("Time (days ago)",breaks = c(0:7), expand=c(0,0)) +
  theme(text = element_text(size=6), legend.margin = unit(0,"cm"),
	axis.title.x=element_text(margin=margin(1.5,0,0,0)),
	axis.title.y=element_text(margin=margin(0,1.5,0,0)))

ggsave(file.path(args$folder,'week.jpg'),tempPlot,width=4.25,height=2)
system(paste("convert -trim ", file.path(args$folder,'week.jpg'), file.path(args$folder,'week.jpg')))

tempDay = subset(temp, Time < 1);
tempDay$Time = seq(along=tempDay$Time,from=24,to=0)
tempDay$Relay = tempDay$Relay * 24;

tempPlotDay = tempPlot %+% tempDay;
tempPlotDay = tempPlotDay + 
  scale_x_continuous("Time (hours ago)", breaks = c(0:24), expand=c(0,0))

ggsave(file.path(args$folder,'day.jpg'),tempPlotDay,width=4.25,height=2)
system(paste("convert -trim ", file.path(args$folder,'day.jpg'), file.path(args$folder,'day.jpg')))
