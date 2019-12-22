# install.packages("shiny", dependencies = TRUE)
# install.packages("reticulate", dependencies = TRUE)

library("shiny")
library("reticulate")
library("leaflet")
use_condaenv("cityenv", required = TRUE)
Building <- import("Building")
os <- import("os")
shutil <- import("shutil")

# B <- Building$Building()
# point_coords = NA

imgs_folder = os$path$join("www", ".temp")


ui <- fluidPage(
  titlePanel("Buildings network"),
  
  fluidRow(column(4, wellPanel(
    verticalLayout(fluidRow(
      column(8,
             verticalLayout(
               numericInput("lat", "Latitude", 45.745591),
               numericInput("long", "Longitude", 4.871167)
             )),
      column(
        2,
        verticalLayout(actionButton("button", "Go!")),
        checkboxInput("save", "Save results", TRUE)
      )
    ),
    leafletOutput("map"))
  )),
  column(
    4,
    textOutput(outputId = "coordinates"),
    imageOutput(outputId = "buildings")
  )),
  
  
  fluidRow(
    column(
      3,
      "Merge buildings",
      imageOutput(outputId = "merged")
    ),
    column(
      3,
      "Assign nodes",
      imageOutput(outputId = "nodes")
    ),
    column(
      3,
      "Assign edges",
      imageOutput(outputId = "edges")
    ),
    column(
      3,
      "Create the Buildings Network",
      imageOutput(outputId = "net")
    )
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
  
  output$coordinates <-
    renderText({
      paste("Coordinates:",
            "(",
            paste(rv$lat, rv$lng, sep = ", "),
            ")")
    })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      setView(lng = rv$lng,
              lat = rv$lat,
              zoom = 15) %>%
      # addCircleMarkers( ~ longitude, ~ latitude)
      addMarkers(lng = rv$lng,
                 lat = rv$lat) %>%
      # addRectangles(lng1 = rv$lng - 0.01,
      #               lat1 = rv$lat - 0.01,
      #               lng2 = rv$lng + 0.01,
      #               lat2 = rv$lat + 0.01) %>%
      addScaleBar()
  })
  
  observeEvent(input$map_click, {
    click = input$map_click
    rv$lat <- click$lat
    rv$lng <- click$lng
    updateTextInput(session, "lat", value = rv$lat)
    updateTextInput(session, "long", value = rv$lng)
    # leafletProxy('map') %>% setView(lat = input$map_center$lat, lng = input$map_center$lng, zoom = input$map_zoom) # avoid re-centering
  })
  
  rv <- reactiveValues()
  rv$download_src = "www/sb.png"
  rv$merge_src = "www/sb.png"
  rv$nodes_src = "www/sb.png"
  rv$edges_src = "www/sb.png"
  rv$net_src = "www/sb.png"
  rv$lat <- isolate({
    input$lat
  })
  rv$lng <- isolate({
    input$long
  })
  
  
  download <- reactive({
    rv$B$download_buildings()
    rv$B$plot_buildings(imgs_folder = imgs_folder)
    rv$download_src = 'www/.temp/buildings.png'
    rv$download_src
    system2("Rscript", "download.R", wait = FALSE)
  })
  
  merge <- reactive({
    rv$B$merge_and_convex()
    rv$B$plot_merged_buildings(imgs_folder = imgs_folder)
    rv$merge_src = 'www/.temp/merged.png'
    system2("Rscript", "merge.R", wait = FALSE)
  })
  
  assign_nodes <- reactive({
    rv$B$assign_nodes()
    rv$B$plot_nodes(imgs_folder = imgs_folder)
    rv$nodes_src = 'www/.temp/nodes.png'
  })
  
  assign_edges <- reactive({
    rv$B$assign_edges_weights()
    rv$B$plot_edges(imgs_folder = imgs_folder)
    rv$edges_src = 'www/.temp/edges.png'
  })
  
  assign_net <- reactive({
    rv$B$assign_network()
    rv$B$plot_net(imgs_folder = imgs_folder)
    rv$net_src = 'www/.temp/net.png'
  })
  
  
  output$buildings = renderImage({
    list(src = rv$download_src,
         alt = 'Buildings', height = '100%')
  }, deleteFile = FALSE)
  
  output$merged = renderImage({
    list(src = rv$merge_src,
         alt = 'Merged buildings', height = '70%')
  }, deleteFile = FALSE)
  
  output$nodes = renderImage({
    list(src = rv$nodes_src,
         alt = 'Nodes', height = '70%')
  }, deleteFile = FALSE)
  
  output$edges = renderImage({
    list(src = rv$edges_src,
         alt = 'Edges', height = '70%')
  }, deleteFile = FALSE)
  
  output$net = renderImage({
    list(src = rv$net_src,
         alt = 'Net', height = '70%')
  }, deleteFile = FALSE)
  
  observeEvent(input$button, {
    
    rv$download_src = "www/sb.png"
    rv$merge_src = "www/sb.png"
    rv$nodes_src = "www/sb.png"
    rv$edges_src = "www/sb.png"
    rv$net_src = "www/sb.png"
    
    withProgress(value = 0, message = "Creating Buildings Network", {
      rv$B = Building$Building(point_coords = c(input$lat, input$long))
      
      incProgress(detail = "Downloading...")
      download()
      
      incProgress(detail = "Merging...")
      merge()

      incProgress(detail = "Assigning nodes..")
      assign_nodes()

      incProgress(detail = "Assigning edges..")
      assign_edges()

      incProgress(detail = "Creating network...")
      assign_net()

    })
    
    if (isolate(input$save)) {
      # os$makedirs("results", exist_ok = TRUE)
      
      date <- Sys.Date()
      time <- format(Sys.time(), "%Hh%Mm%Ss")
      
      destination_folder = file.path("results", paste0(date,
                                                       "-",
                                                       time))
      
      dir.create(destination_folder, recursive = TRUE)
      
      
      file_list <- list.files(imgs_folder)
      
      for (f in file_list) {
        file.copy(file.path(imgs_folder, f), destination_folder)
      }
      
      cat(
        paste(input$lat, input$long, sep = "\n"),
        file = file.path(destination_folder, "coords.txt")
      )
      
    }
    # else {
    #   os$remove(imgs_folder)
    # }
    
  }, ignoreInit = TRUE)
  
  
  
  
}

# onStop(function() {os$remove(imgs_folder)})

shinyApp(ui = ui, server = server)

# os$remove(imgs_folder)
