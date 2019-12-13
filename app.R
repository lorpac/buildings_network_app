# install.packages("shiny", dependencies = TRUE)
# install.packages("reticulate", dependencies = TRUE)

library("shiny")
library("reticulate")
use_condaenv("cityenv", required = TRUE)
Building <- import("Building")
os <- import("os")

# B <- Building$Building()
# point_coords = NA


ui <- fluidPage(
  titlePanel("Buildings network"),
  
  fluidRow(
    column(6,
           verticalLayout(
             numericInput("lat", "Latitude", 45.745591),
             numericInput("long", "Longitude", 4.871167),
             actionButton("button", "Go!")
           )),
    column(
      6,
      textOutput(outputId = "coordinates"),
      imageOutput(outputId = "buildings")
    )
    
  ),
  
  fluidRow(
    column(3,
           "Merge buildings",
           imageOutput(outputId = "merged")),
    column(3,
           "Assign nodes",
           imageOutput(outputId = "nodes")),
    column(3,
           "Assign edges",
           imageOutput(outputId = "edges")),
    column(3,
           "Create the Buildings Network",
           imageOutput(outputId = "net")),
  ),
  
  hr(),
  p(
    "Having fun? Try our Jupyter notebook!",
    img(src = "GitHub_logo.png", alt = "Github_logo"),
    a(href = "https://github.com/lorpac/building-network", "lorpac/building-network")
  ),
  br(),
  p(
    "This app and the Python code ... ... ",
    strong("Is the code open source? Please cite blablabla")
  )
  
  
  
)

server <- function(input, output, session) {
  imgs_folder = os$path$join("www", ".temp")
  
  output$coordinates <-
    renderText({
      paste("Coordinates:",
            "(",
            paste(input$lat, input$long, sep = ", "),
            ")")
    })
  
  # point_coords <- reactive(c(input$lat, input$long))
  
  observeEvent(input$button, {
  
    B = Building$Building(point_coords = c(input$lat, input$long))
    
    cat("start downloading\n")
    B$download_buildings()
    cat("finished downloading\n")
    
    B$plot_buildings(imgs_folder = imgs_folder)
    
    output$buildings = renderImage({list(src = 'www/.temp/buildings.png', alt = 'Buildings')}, deleteFile = FALSE)
  
    cat("start merging\n")
    B$merge_and_convex()
    cat("finished merging\n")
    B$plot_merged_buildings(imgs_folder = imgs_folder)

    output$merged = renderImage({list(src = 'www/.temp/merged.png', alt = 'Merged buildings')}, deleteFile = FALSE)
  })
}

shinyApp(ui = ui, server = server)
