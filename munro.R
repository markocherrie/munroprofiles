#key<-readline("Enter api key:") 

# actually just downloaded from here : http://www.hills-database.co.uk/
data<-read.csv("data/DoBIH_v15.5.csv")
munros<-data[data$M==1,]

# take points equidistant from location of munro, east to west?
# let's do one
munro1<-munros[18,]

# function
library(sp)
library(maptools)

coordsCENT = cbind(munro1$Xcoord, munro1$Ycoord)
coordsWEST = cbind(munro1$Xcoord-3000, munro1$Ycoord)
coordsEAST = cbind(munro1$Xcoord+3000, munro1$Ycoord)

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
  
## 
library(elevatr)

df_elev <-get_elev_point(pointelevation_wgs, prj='+proj=longlat +datum=WGS84',src = "mapzen", api_key=key)
df_elev<-as.data.frame(df_elev)

#plot(df_elev$elevation, type="l")

library(plotly)

p <- plot_ly(x = ~df_elev$x, y = ~df_elev$elevation, type = 'scatter', mode = 'lines', fill = 'tozeroy') %>%
  layout( title = paste0(munro1$Name,", ", round(mean(df_elev$y,rm=T),2), "°"),
          xaxis = list(title = 'Longitude'),
          yaxis = list(title = 'Elevation (m)'))
p

# routes from http://www.haroldstreet.org.uk/routes/?filter=munro&area=scotland&page=7


# raster example
munropoint<-data.frame(x=munro1$Xcoord, y=munro1$Ycoord)

#dataw<-as.data.frame(rbind(coordsEAST, coordsWEST))
#colnames(dataw)<-c("x", "y")
munropointsp = SpatialPoints(dataw)

munropointsp = SpatialPoints(munropoint)
munropointsp@proj4string = CRS(bng)
munropolygon<-gBuffer(munropointsp, 1000, byid=T)
# reproject data to Mercator coordinate system
#munropolygon = spTransform(munropolygon, CRS(wgs84))


elevation <- get_elev_raster(munropolygon, z = 12,prj=bng, api_key = key)
#plot(elevation)

#if too jaggy
elevation <- disaggregate(elevation, 5)
elevation <- focal(elevation, w=matrix(1, 5, 5), mean)

##
#install.packages("rasterVis")
library(rasterVis)
plot3D(elevation)   # note: 3D not 3d


