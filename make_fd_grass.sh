# GRASS commands for creating flow direction file
#
# July 2, 2020 JRS
# Using command-line only. I haven't managed to get the GRASS GUI to work on my computer.

# Crop the VICGlobal DEM to a more convenient (smaller) extent
gdalwarp -te -112.3125 35.5625 -105.625 43.4375 /home/jschap/Documents/ESSD/distrib_cal/rout/elev.tif /home/jschap/Documents/ESSD/distrib_cal/rout/elev_ucrb_crop.tif --overwrite

# Create flow direction file -------------------------------------------

grass78 -c --text /home/jschap/Documents/grassdata/ucrb

r.in.gdal /hdd/ESSD/data/colo_mask.tif out=ucrb_mask
v.in.ogr /hdd/ESSD/data/bb.shp out=bb
r.in.gdal /home/jschap/Documents/ESSD/distrib_cal/rout/elev.tif out=vg_dem

g.region -p raster=ucrb_mask
r.mask ucrb_mask

d.mon wx0
d.rast ucrb_mask
d.vect bb
d.rast vg_dem

r.watershed -sab elev=vg_dem threshold=500 accum=ucrb_flowacc drain=ucrb_flowdir stream=ucrb_stream basin=ucrb_basin --overwrite
r.to.vect in=ucrb_basin out=ucrb_basinv type=area
r.to.vect in=ucrb_stream out=ucrb_streamv type=line

d.vect ucrb_streamv
d.vect ucrb_basinv

# Flow direction corrections ---------------------------------------------

WKDIR=/home/jschap/Documents/ESSD/distrib_cal/rout/

# Write out flow direction file
r.out.gdal in=ucrb_flowdir out=${WKDIR}flowdir.tif

# ogr2ogr -clipsrc -112.3125 35.5625 -105.625 43.4375 ${WKDIR}ucrb_rivers_ob.shp /hdd/Data/USA_Rivers_and_Streams/us_rivers.shp

# River centerlines from the Andreadis et al. dataset
ogr2ogr -clipsrc -112.3125 35.5625 -105.625 43.4375 ${WKDIR}ucrb_rivers_ka.shp /hdd/Data/Rivers/namerica/narivs.shp

r.mask -r

# Select rivers wider than 50 m in R -------------------------------------
#
# Get river centerlines for rivers wider than 100m
# bb <- readOGR("/hdd/ESSD/data/bb.shp")
# plot(bb, main = "UCRB")
# riv_ka <- readOGR("/home/jschap/Documents/ESSD/distrib_cal/rout/ucrb_rivers_ka.shp")

# riv_ka_100 <- riv_ka[riv_ka$WIDTH>=100,]
# plot(riv_ka_100, add=TRUE)

# riv_ka_50 <- riv_ka[riv_ka$WIDTH>=50,]
# plot(riv_ka_50, add=TRUE)

# writeOGR(riv_ka_50, 
#          dsn = "/home/jschap/Documents/ESSD/distrib_cal/rout/ucrb_riv_ka_50m.shp",
#          layer = "riv",
#          driver = "ESRI Shapefile")

# This thins out the dataset to make it more manageable.

# Lees Ferry gage ---------------------------------------------

# Latitude  36°51'51.60", Longitude 111°35'16.34" NAD83
# Drainage area 111,800  square miles
# latd=36.86433
# lond=-111.5879
# A=289560.9 km^2

# Flow direction toolkit ----------------------------------------------
#
# Use the FlowDirectionToolkit to get a good match between the flow direction file and the true basin extent

# Flow direction file: /home/jschap/Documents/ESSD/distrib_cal/rout/flowdir.tif
# Basin boundary file: /hdd/ESSD/data/bb.shp
# Gage location file: /home/jschap/Documents/ESSD/distrib_cal/rout/gage_loc.txt
# River file: /home/jschap/Documents/ESSD/distrib_cal/rout/ucrb_riv_ka_50m.shp

# v.in.ogr in=${WKDIR}ucrb_rivers_ob.shp out=ucrb_rivers_ob

# Revised flow directions
r.in.gdal in=/home/jschap/Documents/ESSD/distrib_cal/rout/flowdir2_grass.tif out=fd2

# Calculate upstream area
# working gauge location (not exact): -110.75	36.75
r.water.outlet input=fd2 coordinates=-110.716,36.8440 output=basin2 --o

r.in.gdal in=/home/jschap/Documents/ESSD/distrib_cal/rout/flowdir3_grass.tif out=fd3
r.water.outlet input=fd3 coordinates=-110.716,36.8440 output=basin3 --o
d.mon wx0
d.vect bb
r.to.vect in=basin3 out=basin3v type=area
d.vect basin3v color=yellow

v.out.ogr input=basin3v output=/home/jschap/Documents/ESSD/distrib_cal/rout/basin3.shp format=ESRI_Shapefile


ogr2ogr in=/hdd/Data/USA_Rivers_and_Streams/us_rivers.shp out=ucrb_rivers_ob.shp
v.in.ogr in=/hdd/Data/USA_Rivers_and_Streams/us_rivers.shp out=us_rivers

r.water.outlet --overwrite input=ucrb_flowdir coordinates=$X,$Y output=ucrb_watershed
r.null ucrb_watershed setnull=0
r.to.vect in=ucrb_watershed out=ucrb_watershedv type=area

# Basin area (calculated in R) is 250580 km^2. 
# Perhaps it's OK to scale by 289560/250580 (1.15)
