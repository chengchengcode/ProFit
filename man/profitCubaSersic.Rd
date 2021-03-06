\name{profitSersic}
\alias{profitSersic}
\alias{profitCubaSersic}
\alias{profitRadialSersic}
\alias{Sersic}
\alias{sersic}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Sersic Profile Specific Functions
}
\description{
Useful functions related to the Sersic profile. \code{profitCubaSersic} computes the exact 2D pixel integrals for a given Sersic model image. This is very slow compared to \code{\link{profitMakeModel}}, but it is useful for checking model creation tuning (i.e. the degree to which speed can be increased without overly harming accuracy). Tests with this function were used to tune \code{\link{profitMakeModel}}. \code{profitRadialSersic} computes the 1D radial flux intensity of the Sersic profile along the major axis of the profile.
}
\usage{
profitCubaSersic(xcen = dim[1]/2, ycen = dim[2]/2, mag = 15, re = 1, nser = 4, ang = 0,
axrat = 1, box = 0, dim = c(25, 25), rel.tol=1e-3, abs.tol= 1e-10)
profitRadialSersic(r = 1, mag = 15, re = 1, nser = 4, ang = 0, axrat = 1, box = 0)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{xcen}{
Scalar; x centre of the 2D Sersic profile (can be fractional pixel positions).
}
  \item{ycen}{
Scalar; y centre of the 2D Sersic profile (can be fractional pixel positions).
}
  \item{r}{
Vector; the radius along the major axis at which to evalutate the flux intensity.  
}
  \item{mag}{
Scalar; total magnitude of the 2D Sersic profile. Converted to flux using flux=10^(-0.4*(mag-magzero)).
}
  \item{re}{
Scalar; effective radius of the Sersic profile.
}
  \item{nser}{
Scalar; Sersic index of the Sersic profile.
}
  \item{ang}{
Scalar; the orientation of the major axis of the Sersic profile in degrees. When plotted as an R image the angle (theta) has the convention that 0= | (vertical), 45= \, 90= - (horizontal), 135= /, 180= | (vertical). Values outside the range 0 <= ang <= 180 are allowed, but these get recomputed as ang = ang.
}
  \item{axrat}{
Scalar; axial ratio of the Sersic profile defined as minor-axis/major-axis, i.e. 1 is a circle and 0 is a line.
}
  \item{box}{
Scalar; the boxiness of the Sersic profile that traces contours of iso-flux, defined such that r[mod]=(x^(2+box)+y^(2+box))^(1/(2+box)). When box=0 the iso-flux contours will be normal ellipses, but modifications between -1<box<1 will produce visually boxy distortions. Negative values have a pin-cushion effect, whereas positive values have a barrel effect (the major and minor axes staying fixed in all cases).
}
  \item{dim}{
Scalar; the dimensions of the image to be generated. Typically this should be c(Nx,Ny). If length 1 then the value will be replicated for both dimenions.
}
  \item{rel.tol}{
Scalar; the requested relative accuracy. Default, 0.001.
}
  \item{abs.tol}{
Scalar; the requested absolute accuracy. The algorithm stops when either the relative or the absolute accuracies are met. Default, near 1e-10.  
}
}
\details{
This function uses the Cuba package to make an accurate (but expensive) cubature integral. This function was written to test the accuracy of ProFit Sersic models generated by \code{\link{profitMakeModel}}.

By ProFit convention the bottom-left part of the bottom-left pixel when plotting the image matrix is c(0,0) and the top-right part of the bottom-left pixel is c(1,1), i.e. the mid-point of pixels are half integer values in x and y.

To confuse things a bit, when R plots an image of a matrix it is transposed and re-ordered vertically to how it appears if you print the matrix directly to screen, i.e. compare print(matrix(1:4,2,2)) and image(matrix(1:4,2,2)). The lowest value (1) is top-left when printed but bottom-left when displayed using image (the red pixel). Both are "correct": the issue is whether you consider the first element of a matrix to be the Cartesian x position (movement in x) or a row element (movement in y). Matrices in maths are always written top-left first where the first argument refers to row number, but images by convention are accessed in a Cartesian sense. Hence [3,4] in a maths matrix means 3 down and 4 right from the top-left, but 3 right and 4 up from the bottom-left in an image.
}
\value{
\code{profitCubaSersic}:
Matrix; contains the flux values of the specified model image. Dimensions \option{dim}.

\code{profitRadialSersic}:
Vector; same length as input \option{r}, specifying the flux intensity of the profile along the major axis.
}
\references{
Sersic J. L., 1963, Boletin de la Asociacion Argentina de Astronomia La Plata Argentina, 6, 41
}
\author{
Aaron Robotham
}

\seealso{
\code{\link{profitMakeModel}}, \code{\link{profitMoffat}}, \code{\link{profitFerrer}}, \code{\link{profitCoreSersic}}, \code{\link{profitKing}}
}
\examples{
model = list(
  sersic = list(
    xcen = 10,
    ycen = 10,
    mag = 15,
    re = 2,
    nser = 4,
    ang = 30,
    axrat = 0.5,
    box = 0
	)
)

dim=c(20,20)

tempExact=profitCubaSersic(xcen=model$sersic$xcen, ycen=model$sersic$ycen,
mag=model$sersic$mag, re=model$sersic$re, nser=model$sersic$nser, ang=model$sersic$ang,
axrat=model$sersic$axrat, box=model$sersic$box, dim=dim)
tempProFit=profitMakeModel(model, dim=dim)$z

#The relative differences between the exact and approximate ProFit model image.
#This is scaled to show 1\% differences as extremes:
magimage((tempExact-tempProFit)/tempExact, magmap=FALSE, zlim=c(-0.01,0.01))
#They differ by no more the 1\% in flux for any pixel, and in general much less than that:
hist((tempExact-tempProFit)/tempExact)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ cubature }
\keyword{ sersic }% __ONLY ONE__ keyword per line
