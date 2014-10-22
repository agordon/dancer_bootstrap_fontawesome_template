#!/usr/bin/Rscript --vanilla

#the first and only argument should be the file with the temperature data
args <- commandArgs(TRUE);

temp = read.csv(args[1],header=F);
temp = temp[rev(1:dim(temp)[1]),];
day_count = 1;

while (dim(temp)[2] > 0) {
	print(dim(temp));
	if (dim(temp)[1] >= 1440) {
		# this_day = temp[c((dim(temp)[1]-1440):dim(temp)[1]),];
		# temp = temp[-c((dim(temp)[1]-1440):dim(temp)[1]),];
		this_day = temp[1:1440,];
		temp = temp[-c(1:1440),];
	} else {
		this_day = temp;
		temp = temp[-c(1:dim(temp)[1])];
	}
	print(dim(this_day));

	svg(sprintf('day%02d.svg',day_count));
	par(bty='n', mgp=c(1.5,0.5,0));
	plot(this_day[,2],ylim=c(32,85),typ='l',col='green',ylab='Temperature',xlab='Time');
	lines(this_day[,3],col='red');

	mylims <- par("usr");

	relay_on_y = c(mylims[3],mylims[4],mylims[4],mylims[3]);

	for (i in 1:dim(this_day)[1]) {
		if (this_day[i,4]) {
			polygon(c(i-0.5,i+0.5,i+0.5,i-0.5),relay_on_y,col=rgb(0.25,0.25,0.25,0.25),density=NA);
		}
	}

	lines(this_day[,2],col='green',lwd=3);
	
	lines(mylims[1:2],c(32,32),col=rgb(0.83,0.94,1,0.75),lwd=3);

	graphics.off();

	day_count = day_count + 1;
}
