# Building Network App

An R Shiny app that allows creating the Building Network of a 2km x 2km square area of any city, around a user-defined geographical point. 

## Requirements and installation
First, you need to install R (and RStudio). The following R packages have to be installed:
- shiny
- leaflet
- comprehenr
- markdown

You can istall them by typing 

``
install.packages("shiny", dependencies = TRUE)
install.packages("leaflet", dependencies = TRUE)
install.packages("comprehenr", dependencies = TRUE)
``

in the R console.

The calculations are done in Python. You need to install Python (version 3.x) and install the required packages (essentially, [OSMnx](https://github.com/gboeing/osmnx) with its dependencies, see below). 
### Installation on Windows
Due to geopandas installation requirement, installing with conda is required on Windows.

In Windows, it is assumed that you are working in a conda virtual environment named cityenv . In order to do so, run:

```
conda env create -n cityenv
conda activate cityenv
conda install pip
```

Install OSMnx dependencies:

```
conda install geopandas
conda install descartes
conda install matplotlib
conda install networkx
conda install numpy
conda install pandas
conda install requests
conda install rtree
conda install shapely
```

and install OSMnx:

```
pip install osmnx
```
please note that [rtree](https://pypi.org/project/Rtree/) requires the [libspatialindex](https://libspatialindex.org/) library. If you don't have it installed, please follow the instructions [here](https://github.com/libspatialindex/libspatialindex/wiki/1.-Getting-Started).


### In MacOS or Linux:

In MacOS or Linux, the app uses a Python virtual environment .env. First, you need to create the virtual environment and activate it:

```
pip install virtualenv
python2 -m venv .env
source .env/bin/activate
```

and then, install OSMnx and it dependencies using pip:

```
pip install -r requirements.txt
```
please note that the dependency [rtree](https://pypi.org/project/Rtree/) requires the [libspatialindex](https://libspatialindex.org/) library. If you don't have it installed, please follow the instructions [here](https://github.com/libspatialindex/libspatialindex/wiki/1.-Getting-Started).

## Create your Building Network

- Run app.R, RStudio  will launch.
- Click **run App**. It is then advised to open the app in your browser (click **Open in browser**).
-  You can give your job a name using the **Job name** field. The default job name is *BuildingsNetwork*.
- Move the blue square in the map to select the area of interest and click the button **Run**. Alternatively, you can directly insert the geographical coordinates of the center of your are of interest in the (Latitude, Longitude) boxes and click the button **Run**. The area used for the creation of the Buildings Network is a 2km x 2km square.

## Retrieve the results

- If **Save results** is checked before running the analysis (that's the default behavior), you will find a copy of the produced pictures (buildings footprint, merged buildings, Buildings Network, colored network), together with a text file containing the values of the input coordinates (center of the square area), in a subdirectory of the  `results/` folder, named from the job name and the day and time at which the analysis was run.
- You can also download the results by clicking on **Download** once the calculation has finished.

## Author

Lorenza Pacini - [lorpac](https://github.com/lorpac)

### Known issues (work in progress!)

- The blue square in the map is deformed at latitudes far from the European latitude. However, this does not impact the shape of the area that is actually considered for the creation of the Buildings Network, it remains a 2km x 2km squared area centered around the center of the (deformed) square.
- On Linux, the results are plotted only when the whole computation has finished. 
