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
        checkboxInput("save", "Save results", TRUE)
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
  
  session$onSessionEnded(stopApp) # stop app when closing browser tab
  
  imgs_folder = os$path$join("www", ".temp")
  
  output$coordinates <-
    renderText({
      paste("Coordinates:",
            "(",
            paste(input$lat, input$long, sep = ", "),
            ")")
    })
  
  rv <- reactiveValues()
  rv$download_num = 0
  rv$merge_num = 0
  rv$nodes_num = 0
  rv$edges_num = 0
  rv$net_num = 0
  rv$n_run = 0
  
  download <- reactive({
    rv$B$download_buildings()
    rv$B$plot_buildings(imgs_folder = imgs_folder)
    rv$download_num = rv$download_num + 1
  })
  
  merge <- reactive({
    rv$B$merge_and_convex()
    rv$B$plot_merged_buildings(imgs_folder = imgs_folder)
    rv$merge_num = rv$merge_num + 1
  })
  
  assign_nodes <- reactive({
    rv$B$assign_nodes()
    rv$B$plot_nodes(imgs_folder = imgs_folder)
    rv$nodes_num = rv$nodes_num + 1
  })
  
  assign_edges <- reactive({
    rv$B$assign_edges_weights()
    rv$B$plot_edges(imgs_folder = imgs_folder)
    rv$edges_num = rv$edges_num + 1
  })
  
  assign_net <- reactive({
    rv$B$assign_network()
    rv$B$plot_net(imgs_folder = imgs_folder)
    rv$net_num = rv$net_num + 1
  })
  
  

  render_building <- reactive({output$buildings = renderImage({
    list(src = 'www/.temp/buildings.png',
         alt = 'Buildings',
         height = '100%')
  }, deleteFile = FALSE)})

  
  render_merged <- reactive({  output$merged = renderImage({
      list(src = 'www/.temp/merged.png',
           alt = 'Merged buildings',
           height = '70%')
    }, deleteFile = FALSE)})
  

  render_nodes <- reactive({output$nodes = renderImage({
    list(src = 'www/.temp/nodes.png',
         alt = 'Nodes',
         height = '70%')
  }, deleteFile = FALSE)})
  
  render_edges <- reactive({output$edges = renderImage({
    list(src = 'www/.temp/edges.png',
         alt = 'Edges',
         height = '70%')
  }, deleteFile = FALSE)})
  
  render_net <- reactive({output$net = renderImage({
    list(src = 'www/.temp/net.png',
         alt = 'Edges',
         height = '70%')
  }, deleteFile = FALSE)})
  
  observeEvent(input$button, {
    withProgress(value = 0, message = "Creating Buildings Network", {
      
      rv$B = Building$Building(point_coords = c(input$lat, input$long))
      
      incProgress(detail = "Downloading...")
      download()
      render_building()
      
      incProgress(detail = "Merging...")
      merge()
      render_merged()
      
      incProgress(detail = "Assigning nodes..")
      assign_nodes()
      render_nodes()
      
      incProgress(detail = "Assigning edges..")
      assign_edges()
      render_edges()
      
      incProgress(detail = "Creating network...")
      assign_net()
      render_net()
      
      rv$n_run <- rv$n_run + 1
      
    })
  })
  
  observeEvent(rv$n_run, {
    if (isolate(input$save)) {
      os$makedirs("results", exist_ok = TRUE)
      
      date <- Sys.Date()
      time <- format(Sys.time(), "%Hh%Mm%Ss")
      coords <- isolate(paste("Lat_", input$lat, "Lon_", input$long))
      
      destination_folder = paste(date,
                                 "-",
                                 time,
                                 "-",
                                 coords)
      os$rename(imgs_folder,
                os$path$join("results", destination_folder))
    }
    else {
      os$remove(results_folder)
    }
    
  }, ignoreInit = TRUE)
  
  
}

shinyApp(ui = ui, server = server)
