# install.packages("devtools")
# devtools::install_github("rstudio/reticulate")

library("reticulate")

use_condaenv("cityenv", required = TRUE)


py_run_file("buildings_network.py", convert = FALSE)
# source_python("buildings_network.py", convert = FALSE)

point_coords <- c(45.745591, 4.871167)

py$B = py$Building(point_coords=point_coords)

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



