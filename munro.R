# scrape locations of munros

# actually just downloaded from here : http://www.hills-database.co.uk/
data<-read.csv("data/DoBIH_v15.5.csv")
munros<-data[data$M==1,]

# take points equidistant from location of munro, east to west?
# let's do one
munro1<-munros[2,]

# function
library(sp)
library(maptools)

coordsCENT = cbind(munro1$Xcoord, munro1$Ycoord)
coordsWEST = cbind(munro1$Xcoord-1500, munro1$Ycoord)
coordsEAST = cbind(munro1$Xcoord+1500, munro1$Ycoord)

dataw<-as.data.frame(rbind(coordsEAST, coordsWEST))
colnames(dataw)<-c("east", "north")

s=data.frame(x=dataw$east,y=dataw$north) 
coordinates(s)=~x+y 
L = SpatialLines(list(Lines(list(Line(coordinates(s))),"X"))) 
#plot(L) 


wgs84 = '+proj=longlat +datum=WGS84'
bng = '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs'

library(rgeos)
numOfPoints  <-  gLength(L) / 4
pointelevation<-spsample(L, n = numOfPoints, type = "regular")
pointelevation@proj4string = CRS(bng)

# reproject data to Mercator coordinate system
pointelevation_wgs = spTransform(pointelevation, CRS(wgs84))
pointelevation_wgs<-as.data.frame(pointelevation_wgs)
  
## mapzen-t7vaRHo
library(elevatr)

df_elev <-get_elev_point(pointelevation_wgs, prj='+proj=longlat +datum=WGS84',src = "mapzen", api_key="mapzen-t7vaRHo")
plot(df_elev$elevation, type="l")

# Create polyline of points

# upload DEM model

# extract values of DEM along polyline

# plot result