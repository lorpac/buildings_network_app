# install.packages("devtools")
# devtools::install_github("rstudio/reticulate")

library("reticulate")

use_condaenv("cityenv", required = TRUE)


py_run_file("buildings_network.py", convert = FALSE)
# source_python("buildings_network.py", convert = FALSE)

point_coords <- c(45.745591, 4.871167)
distance <- 1000
distance_threshold <- 30
B <- py$buildings_from_point(point_coords, distance=distance)
py$plot_buildings(B) # something wrong here because of B object type

# py$test_plot()


