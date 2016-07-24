#!/usr/bin/Rscript --vanilla

#One parameter ais expected:
#	-1st: folder to put images
args <- commandArgs(TRUE);

if (length(args) != 1) {
	print("Expected one parameter: a target folder");
	quit();
}

dir.create(args[1], showWarnings = FALSE)

library(ggplot2)
library(BerginskiRMisc)
library(grid)

temp = read.csv('last_week.csv');
temp$Time = seq(along=temp$Time,from=7,to=0);

#missing values throw an error with ggplot, replacing missing vals with 0
temp$Relay[is.na(temp$Relay)] = 0;
temp$Relay = temp$Relay * temp$Time;

lineWidth = temp$Time[1] - temp$Time[2]

tempPlot = ggplot(temp,aes(x=Time)) + 
  geom_vline(aes(xintercept = Relay),size=0.1,alpha=0.25) +
  geom_line(aes(y=Target_temp,color="Target"),alpha=0.5) +
  geom_line(aes(y=Freezer_temp,color="Freezer"),alpha=0.9) +
  geom_line(aes(y=Outside_Temp,color="Outside"),alpha=0.9) + 
  scale_color_brewer("",type = "qual",palette = "Dark2") +
  ylab('Temperature (°F)') +
  theme_berginski() +
  coord_cartesian(ylim=c(30,100)) +
  scale_x_continuous("Time (days ago",breaks = c(0:7)) +
  theme(text = element_text(size=6))

ggsave(file.path(args[1],'week.jpg'),tempPlot,width=4.25,height=2)

tempDay = subset(temp, Time < 1);
tempDay$Time = seq(along=tempDay$Time,from=24,to=0)
tempDay$Relay = tempDay$Relay * 24;

tempPlotDay = tempPlot %+% tempDay;
tempPlotDay = tempPlotDay + 
  scale_x_continuous("Time (hours ago)", breaks = c(0:24))

ggsave(file.path(args[1],'day.jpg'),tempPlotDay,width=4.25,height=2)
