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
    column(
      6,
      verticalLayout(
        numericInput("lat", "Latitude", 45.745591),
        numericInput("long", "Longitude", 4.871167),
        actionButton("button", "Go!"),
        verbatimTextOutput(outputId = "status")
      )
    ),
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
           imageOutput(outputId = "net"))
  ),
  
  hr(),
  p(
    "Having fun? Try our Jupyter notebook!",
    img(
      src = "GitHub_logo.png",
      alt = "Github_logo",
      width = "32px",
      height = "32px"
    ),
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
  
  rv = reactiveValues()
  rv$status = "Ready"
  rv$B = NA
  
  output$coordinates <-
    renderText({
      paste("Coordinates:",
            "(",
            paste(input$lat, input$long, sep = ", "),
            ")")
    })
  
  output$status <- renderPrint(rv$status)
  
  observeEvent(input$button, {
    rv$status = "Start"
    
    rv$B = Building$Building(point_coords = c(input$lat, input$long))
    
    rv$status = "Downloading..."
    cat("start downloading\n")
    rv$B$download_buildings()
    cat("finished downloading\n")
    
    rv$B$plot_buildings(imgs_folder = imgs_folder)
    
    output$buildings = renderImage({
      list(src = 'www/.temp/buildings.png',
           alt = 'Buildings',
           height = '100%')
    }, deleteFile = FALSE)
    rv$status = "Downloaded"
    
    rv$status = "Merging..."
    cat("start merging\n")
    rv$B$merge_and_convex()
    cat("finished merging\n")
    rv$B$plot_merged_buildings(imgs_folder = imgs_folder)
    
    output$merged = renderImage({
      list(src = 'www/.temp/merged.png',
           alt = 'Merged buildings',
           height = '70%')
    }, deleteFile = FALSE)
    
    rv$status = "Merged"
    
    rv$status = "Assigning nodes..."
    cat("Assigning nodes...\n")
    rv$B$assign_nodes()
    cat("nodes assigned\n")
    rv$B$plot_nodes(imgs_folder = imgs_folder)
    
    output$nodes = renderImage({
      list(src = 'www/.temp/nodes.png',
           alt = 'Nodes',
           height = '70%')
    }, deleteFile = FALSE)
    
    rv$status = "Nodes assigned"
    
    
    rv$status = "Assigning edges..."
    cat("assigning edges...\n")
    rv$B$assign_edges_weights()
    cat("edges assigned\n")
    rv$B$plot_edges(imgs_folder = imgs_folder)
    
    output$edges = renderImage({
      list(src = 'www/.temp/edges.png',
           alt = 'Edges',
           height = '70%')
    }, deleteFile = FALSE)
    
    rv$status = "Edges assigned"
    
    rv$status = "Creating network..."
    cat("creating network\n")
    rv$B$assign_network()
    cat("network created\n")
    rv$B$plot_net(imgs_folder = imgs_folder)
    
    output$net = renderImage({
      list(src = 'www/.temp/net.png',
           alt = 'Edges',
           height = '70%')
    }, deleteFile = FALSE)
    
    rv$status = "Ready"
    
  })
  
  
}

shinyApp(ui = ui, server = server)
