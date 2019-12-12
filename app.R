# install.packages("shiny", dependencies = TRUE)
# install.packages("reticulate", dependencies = TRUE)

library("shiny")

# ui <- fluidPage(
#   numericInput(inputId = "n",
#                "Sample size", value = 25),
#   plotOutput(outputId = "hist")
# )
# server <- function(input, output) {
#   output$hist <- renderPlot({
#     hist(rnorm(input$n))
#   })
# }

ui <- fluidPage(
  
  titlePanel("Buildings network"),
  
  fluidRow(
    column(6,
      verticalLayout(
        numericInput("lat", "Latitude", 45.745591),
        numericInput("long", "Longitude", 4.871167)
      )
      ),
     column(6,
            textOutput(outputId = "coordinates")
     )
      
  ),
  
  fluidRow(
    column(3,
           "Merge buildings",
           imageOutput("merge")
           ),
    column(3,
           "Assign nodes",
           imageOutput("nodes")
           ),
    column(3,
           "Assign edges",
           imageOutput("edges")
    ),
    column(3,
           "Create the Buildings Network",
           imageOutput("net")
           ),
  ),
  
  hr(),
  p(
    "Having fun? Try our Jupyter notebook!",
    img(scr="GitHub_logo.png", alt="Github_logo"),
    a(href="https://github.com/lorpac/building-network", "lorpac/building-network")
  ),
  br(),
  p(
    "This app and the Python code ... ... ", strong("Is the code open source? Please cite blablabla")
  )
            
    
  
)

server <- function(input, output) {
  output$coordinates <- renderText({paste("Coordinates:", "(", paste(input$lat, input$long, sep = ", "), ")")})
  # output$merge <- renderImage()
  # output$nodes <- renderImage()
  # output$edges <- renderImage()
  # output$net <- renderImage()
}



shinyApp(ui = ui, server = server)
