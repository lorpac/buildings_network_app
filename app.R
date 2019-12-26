# install.packages("shiny", dependencies = TRUE)
# install.packages("reticulate", dependencies = TRUE)

library("shiny")
library("leaflet")

imgs_folder = "www/.temp"

ui <- fluidPage(
  titlePanel("Buildings network"),
  
  fluidRow(
    column(4, wellPanel(
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
      textOutput(outputId = "status"),
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
  
  output$buildings = renderImage({
    list(src = rv$download_src,
         alt = 'Buildings',
         height = '100%')
  }, deleteFile = FALSE)
  
  output$merged = renderImage({
    list(src = rv$merge_src,
         alt = 'Merged buildings',
         height = '70%')
  }, deleteFile = FALSE)
  
  output$nodes = renderImage({
    list(src = rv$nodes_src,
         alt = 'Nodes',
         height = '70%')
  }, deleteFile = FALSE)
  
  output$edges = renderImage({
    list(src = rv$edges_src,
         alt = 'Edges',
         height = '70%')
  }, deleteFile = FALSE)
  
  output$net = renderImage({
    list(src = rv$net_src,
         alt = 'Net',
         height = '70%')
  }, deleteFile = FALSE)
  
  rv$status = reactiveFileReader(100, session, "status", readLines)
  
  observeEvent(rv$status(), {
    status = strtoi(isolate({
      rv$status()
    }))
    
    output$status = renderText(rv$status_text)
    
    if (status == 0) {
      rv$download_src = "www/sb.png"
      rv$merge_src = "www/sb.png"
      rv$nodes_src = "www/sb.png"
      rv$edges_src = "www/sb.png"
      rv$net_src = "www/sb.png"
      rv$status_text = "Downloading buildings..."
    }
    
    if (status > 0) {
      rv$download_src = paste0(imgs_folder, "/buildings.png")
      rv$status_text = "Merging buildings..."
    }
    if (status > 1) {
      rv$merge_src = paste0(imgs_folder, "/merged.png")
      rv$status_text = "Assigning nodes..."
    }
    if (status > 2) {
      rv$nodes_src = paste0(imgs_folder, "/nodes.png")
      rv$status_text = "Assigning edges..."
    }
    if (status > 3) {
      rv$edges_src = paste0(imgs_folder, "/edges.png")
      rv$status_text = "Creating network..."
    }
    if (status > 4) {
      rv$net_src = paste0(imgs_folder, "/net.png")
      rv$status_text = "Finished."
      
      if (isolate(input$save)) {
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
      
      
    }
  }, ignoreInit = TRUE)
  
  
  observeEvent(input$button, {
    if (Sys.info()["sysname"] == "Windows")
    {
      args = c("/c",
               "run.ps1",
               "-lat",
               isolate(rv$lat),
               "-lng",
               isolate(rv$lng))
      system2("powershell", args, wait = FALSE)
    }
    
    else {
      args = c("run.sh",
               isolate(rv$lat),
               isolate(rv$lng))
      
      system2("bash", args, wait = FALSE)
    } # not working with wait=FALSE
    
    
    # args = c( "main.py",
    #          toString(isolate(rv$lat)),
    #          toString(isolate(rv$lng)))
    # system2(".env/bin/python", args, wait=TRUE) # can't execute binary file
    
    
    
  }, ignoreInit = TRUE)
}

onStop(function() {
  unlink(imgs_folder, recursive = TRUE)
})

shinyApp(ui = ui, server = server)
