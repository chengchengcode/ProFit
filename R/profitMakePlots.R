#This function creates a color scale for use with the image()
#function. Input parameters should be consistent with those
#used in the corresponding image plot. The "axis.pos" argument
#defines the side of the axis. The "add.axis" argument defines
#whether the axis is added (default: TRUE)or not (FALSE).
.profitImageScale <- function(z, zlim, col = heat.colors(12),
  breaks, axis.pos=1, axis.padj=0, add.axis=TRUE, axis.tck = 0, ...){
  if(!missing(breaks)){
    if(length(breaks) != (length(col)+1)){stop("must have one more break than colour")}
  }
  if(missing(breaks) & !missing(zlim)){
    breaks <- seq(zlim[1], zlim[2], length.out=(length(col)+1)) 
  }
  if(missing(breaks) & missing(zlim)){
    zlim <- range(z, na.rm=TRUE)
    zlim[2] <- zlim[2]+c(zlim[2]-zlim[1])*(1E-3)#adds a bit to the range in both directions
    zlim[1] <- zlim[1]-c(zlim[2]-zlim[1])*(1E-3)
    breaks <- seq(zlim[1], zlim[2], length.out=(length(col)+1))
  }
  poly <- vector(mode="list", length(col))
  for(i in seq(poly)){
    poly[[i]] <- c(breaks[i], breaks[i+1], breaks[i+1], breaks[i])
  }
  if(axis.pos %in% c(1,3)){ylim<-c(0,1); xlim<-range(breaks)}
  if(axis.pos %in% c(2,4)){ylim<-range(breaks); xlim<-c(0,1)}
  plot(1,1,t="n",ylim=ylim, xlim=xlim, axes=FALSE, xlab="", ylab="", xaxs="i", yaxs="i", ...)  
  for(i in seq(poly)){
    if(axis.pos %in% c(1,3)){
      polygon(poly[[i]], c(0,0,1,1), col=col[i], border=NA)
    }
    if(axis.pos %in% c(2,4)){
      polygon(c(0,0,1,1), poly[[i]], col=col[i], border=NA)
    }
  }
  box()
  if(add.axis) {axis(axis.pos, padj=axis.padj, tck=axis.tck)}
}

profitMakePlots <- function(image, modelimage, region, sigma, errischisq = FALSE,
  cmap = rev(colorRampPalette(brewer.pal(9,'RdYlBu'))(100)), 
  errcmap = rev(c("#B00000",colorRampPalette(brewer.pal(9,'RdYlBu'))(100)[2:99],"#0000B0")),
  plotchisq=FALSE, dofs) {
  residual = image - modelimage
  error=sigma
  
  parmar = par("mar")
  
  if(!plotchisq)
  {
    par(mar=c(0,0,0,0),oma=c(4.1,4.1,1.1,1.1))
    layout(cbind(1,2,3,4))
    
    tempmap=magmap(image,lo=0,hi=1)$datalim
    tempmap=max(abs(tempmap))
    
    magimage(image,stretchscale=1/median(abs(image[image>0])),lo=-tempmap,hi=tempmap,type='num',zlim=c(0,1),col=cmap,xlab='x/pix',ylab='y/pix')
    if(missing(region)==FALSE & all(region)==FALSE){
      tempcon=magimage(1-region,add=T,magmap=F,zlim=c(0,1),col=NA)#hsv(s=0,alpha=0.5)
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
    }
    legend('topleft',legend='Data')
    
    magimage(modelimage,stretchscale=1/median(abs(image[image>0])),lo=-tempmap,hi=tempmap,type='num',zlim=c(0,1),col=cmap,xlab='x/pix')
    if(missing(region)==FALSE & all(region)==FALSE){
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
      legend('topleft',legend='Model')
    }
    
    magimage(residual,stretchscale=1/median(abs(image[image>0])),lo=-tempmap,hi=tempmap,type='num',zlim=c(0,1),col=errcmap,xlab='x/pix')
    if(missing(region)==FALSE & all(region)==FALSE){
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
      legend('topleft',legend='Data-Model')
    }
    
    diff=residual[region]/error[region]
    hist(diff[!is.na(diff)],main='',breaks=100,axes=FALSE)
    magaxis(1,xlab='Sigma offset / Cnts')
    abline(v=0,lty=2,col='red')
    legend('topleft',legend='(Data-Model)/Sigma')
  }
  else
  {
    maxsigma = 5
    if(missing(dofs)){ndofs=0}else{ndofs = length(dofs)}
    if(ndofs>0) stopifnot(length(dofs) <= 2)

    parmar2=c(1.5,2,0.5,0)
    par(mar=parmar2)

    layout(rbind(c(1,2,3,5),c(7,8,4,6)),widths=c(0.31,0.31,0.31,0.07),heights=c(0.5,0.5))
    
    medimg = median(abs(image[region]))/2
    maximg = max(abs(image[region]))
    
    zlims = c(0,1)
    stretch="asinh"
    stretchscale = 1/medimg
    
    magimage(image,stretchscale=stretchscale,stretch=stretch,lo=-maximg,hi=maximg,zlim=zlims,type='num',col=cmap)
    if(missing(region)==FALSE & all(region)==FALSE){
      tempcon=magimage(1-region,add=T,magmap=F,zlim=c(0,1),col=NA)#hsv(s=0,alpha=0.5)
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
    }
    legend('topleft',legend='Data')
    
    magimage(modelimage,stretchscale=stretchscale,stretch=stretch,lo=-maximg,hi=maximg,zlim=zlims,type='num',col=cmap)
    if(missing(region)==FALSE & all(region)==FALSE){
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
    }
    legend('topleft',legend='Model')
    
    magimage(residual,stretchscale=stretchscale,stretch=stretch,lo=-maximg,hi=maximg,zlim=zlims,type='num',col=cmap)
    if(missing(region)==FALSE & all(region)==FALSE){
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
    }
    legend('topleft',legend='Data-Model')
      
    errsign = (-1)^(image > modelimage)
    if(!errischisq)
    {
      error = residual/error
    } else {
      error = errsign*sqrt(abs(error))
    }
    errmap = error
    error = error[region]
    maxerr = max(abs(error))
    stretcherr = 1/median(abs(error))
    errmap[!region & (errmap>maxerr)] = maxerr
    minerr = -maxerr
    errmap[!region & (errmap<minerr)] = minerr
    errmap[errmap > maxsigma] = maxsigma
    errmap[errmap < -maxsigma] = -maxsigma
    magimage(errmap,magmap=FALSE,zlim=c(-maxsigma,maxsigma),col=errcmap)
    if(missing(region)==FALSE & all(region)==FALSE){
      contour(tempcon,add=T,drawlabels = F,levels=1,col='darkgreen')
      legend('topleft',legend=bquote(chi*"=(Data-Model)"/sigma))
    }
    
    par(mar=parmar2 + c(0,0,0,1))
    pady=1
    breaks = seq(-maximg,maximg, length.out=length(cmap)+1)
    .profitImageScale(zlim=range(residuals), col=cmap, breaks = breaks, axis.pos=2, axis.padj=pady)
    breaks = seq(-maxsigma, maxsigma, length.out=length(cmap)+1)
    .profitImageScale(zlim=c(-maxsigma,maxsigma), col=errcmap, breaks = breaks, axis.pos=2, axis.padj=pady)
    
    par(mar=parmar2)
    ndat = sum(region)
    dx = 0.1
    xlims = c(-4,4)
    x = seq(xlims[1],xlims[2],dx)
    y = hist(error,breaks=c(-(maxerr+dx),x,maxerr+dx),plot=FALSE)$count[2:length(x)]/ndat/dx
    ylim = c(min(y[y>0]),0.5)
    y[y<=0] = ylim[1]-1
    
    vardata = var(error)
    tdof=2*vardata/(vardata-1)
    tdof=interval(tdof,0,Inf)
  
    magplot(x[1:(length(x)-1)]+dx,y, xlim=xlims, ylim=ylim, xlab="",ylab="", xaxs="i", type="s",log="y")
    lines(x, dnorm(x), col="blue", xaxs="i")
    lines(x, dt(x,tdof), col="red", xaxs="i")
    
    labs = c(expression(chi),bquote(norm(1)),bquote(Student-T(.(signif(tdof,5)))))
    cols = c("black","blue","red")
    ltys = c(1,1,1)
    legend("bottom",legend=labs,col=cols,lty=ltys)    
  
    error = log10(error^2)
    xr = range(error)
    xlims = c(-3,min(2,max(xr)))
    x = seq(xlims[1],xlims[2],dx)
    dxbin = 10^x[2:length(x)]-10^x[1:(length(x)-1)]
    y = hist(error,breaks=c(xr[1]-dx,x,xr[2]+dx), plot=FALSE)$count[2:length(x)]
    y = y/sum(y)/dxbin
    ylim = c(min(y[y>0]),10)
    y[y<=0] = ylim[1]-1
  magplot(x[1:(length(x)-1)]+dx, y, xlim=xlims,ylim=ylim, xlab="",ylab="", xaxs="i", type="s",log="y")
    xp=10^x
    lines(x, dchisq(xp,1), col="blue", xaxs="i")
    #lines(x, dt(xp,1), col="red", xaxs="i")
    labs = c(bquote(chi^2),expression(chi^2*(1)))
    cols = c("black","blue")
    if(ndofs > 0){
      dofcols = c("red","darkgreen")
      for(i in 1:length(dofs)){
        dofstr = sprintf("%.3e",dofs[i])
        lines(x, dchisq(xp,dofs[i]), col=dofcols[i], xaxs="i")
        labs = c(labs,bquote(chi^2 (.(dofstr))))
        ltys = c(ltys,1)
        cols = c(cols, dofcols[i])
      }
    }
    abline(v=0,lty=2,col='red')
    legend("bottomleft",legend=labs,col=cols,lty=ltys)
  }
  par(mar=parmar)
}