#!/usr/bin/Rscript --vanilla

#Two parameters are expected:
#	-1st: file with data
#	-2nd: folder to put images
args <- commandArgs(TRUE);

if (length(args) != 2) {
	print("Expected two parameters: data file and target folder");
	quit();
}

temp = read.csv(args[1],header=T);
temp = temp[rev(1:dim(temp)[1]),];
day_count = ceiling(dim(temp)[1]/1440);

days_to_plot = 10;

while (dim(temp)[2] > 0 && days_to_plot > 0) {
	if (dim(temp)[1] >= 1440) {
		this_day = temp[1:1440,];
		temp = temp[-c(1:1440),];
	} else {
		this_day = temp;
	}
	
	plot_width = 10*(dim(this_day)[1]/1440);
	if (plot_width < 1) {
		plot_width = 1;
	}
	
	svg_file = sprintf('%s/day%04d.svg',args[2], day_count); 
	jpg_file = sprintf('%s/day%04d.jpg',args[2], day_count); 

	svg(sprintf('%s/day%04d.svg',args[2], day_count),width=plot_width);
	par(bty='n', mgp=c(1.5,0.5,0),mar=c(2.5,2.5,0,0));
	plot(this_day$Freezer_temp,ylim=c(32,100),typ='l',col='green',
		 ylab='Temperature (\u00B0F)',xlab='Time (min ago)');

	mylims <- par("usr");

	relay_on_y = c(mylims[3],mylims[4],mylims[4],mylims[3]);
	
	for (i in 1:dim(this_day)[1]) {
		if (!is.na(this_day$Relay[i]) && this_day$Relay[i]) {
			polygon(c(i-0.5,i-0.5,i+0.5,i+0.5),relay_on_y,col=rgb(0.25,0.25,0.25,0.25),density=NA);
		}
	}

	lines(c(0,dim(this_day)[1]),c(32,32),col=rgb(0.83,0.94,1,0.75),lwd=3);
	lines(this_day$Target_temp,col='blue',lwd=3);
	lines(this_day$Freezer_temp,col='green',lwd=3);
	lines(this_day$Outside_Temp,col='red',lwd=3);

	graphics.off();
	
	system(sprintf('convert -strip -interlace Plane -quality 85%% %s %s', svg_file, jpg_file));
	system(sprintf('chmod a+wrx %s %s', svg_file, jpg_file));

	day_count = day_count - 1;
	
	#for some reason the while loop isn't working with longer data sets, this
	#is my hacky fix

	if (dim(temp)[1] == dim(this_day)[1]) {
		break;
	}

	days_to_plot = days_to_plot - 1;
}
