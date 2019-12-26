# Building Network App

An R Sshiny app that allows creating the Building Network of a 2km x 2km square area of any city, around a user-defined geographical point. 

## Requirements and installation
First, you need to install R (and RStudio).
The calculations are donw in Python. You need to install Python (version 3.x) and install the required packages (essentially, OSMnx with its dependencies, see below). 
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

### In MacOS or Linux:

In MacOS or Linux, the app uses a Python virtual environment .env. First, you need to create the virtual environment and activate it:

```
pip install virtualenv
python -m venv .env
source .env/bin/activate
```

and then, install OSMnx and it dependencies using pip:

```
pip install -r requirements.txt
```




