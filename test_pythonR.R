# install.packages("devtools")
# devtools::install_github("rstudio/reticulate")

library("reticulate")

use_condaenv("cityenv", required = TRUE)


# py_run_file("Building.py", convert = FALSE)
# source_python("Building.py", convert = FALSE)

Building <- import("Building", convert=FALSE)
# Building <- Building$Building

point_coords <- c(45.745591, 4.871167)

py$B <- py$Building(point_coords=point_coords)

py$B$download_buildings()
py$B$plot_buildings()
py$B$merge_and_convex()
py$B$plot_merged_buildings()
py$B$assign_nodes()
py$B$plot_nodes()
py$B$assign_edges_weights()
py$B$plot_edges()
py$B$assign_network()
py$B$plot_net()



