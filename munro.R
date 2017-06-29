# scrape locations of munros

# actually just downloaded from here : http://www.hills-database.co.uk/
data<-read.csv("data/DoBIH_v15.5.csv")
munros<-data[data$M==1,]

# take points equidistant from location of munro, east to west?
# let's do one
munro1<-munros[1,]



# Create polyline of points

# upload DEM model

# extract values of DEM along polyline

# plot result