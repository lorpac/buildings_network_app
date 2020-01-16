# Building Network App

An R Shiny app that allows creating the Building Network of a 2km x 2km square area of any city, around a user-defined geographical point. 

## Requirements and installation
First, you need to install R (and RStudio).
The calculations are donw in Python. You need to install Python (version 3.x) and install the required packages (essentially, [OSMnx](https://github.com/gboeing/osmnx) with its dependencies, see below). 
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

In order to create the Building Network, simply choose the geographical coordinates of a point to be used as center of a 2km x 2km area by clicking on the map or by directly inserting the coordinates in the (Latitude, Longitude) boxes and click on the button "Go!".

## Retrieve the results

If "save results" is checked before running the analysis (that's the default behavior), you will find a copy of the produced pictures (buildings footprint, merged buildings, Buildings Network), together with a text file containing the values of the input coordinates, in a subdirectory of the  `results` folder, named from the day and time at which the analysis was run.

## Authors

- Lorenza Pacini - [lorpac](https://github.com/lorpac)
