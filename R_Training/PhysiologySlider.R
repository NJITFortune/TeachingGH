library(ggplot2)
library(pracma)
library(tuneR)
library(signal)
library(R.matlab)
library(grid)
library(shiny)

tmp <- readMat("/Users/eric/Documents/Code/NSB2022/MatlabManual/old/pUNITsv6.mat")
#tmp <- readMat("/Users/eric/Documents/Code/NSB2022/MatlabManual/old/ELL_Envelopes_4.mat")

# The EOD recording
EOD <- as.numeric(unlist(tmp$Ch1[9]))
#EOD = t(EOD)
# Sampling interval for EOD
EOD_dt <- as.numeric(unlist(tmp$Ch1[3]))
# Generate a time vector for EOD
time_EOD = seq(EOD_dt, length(EOD)*EOD_dt, EOD_dt)

# The AM recording
AM <- as.numeric(unlist(tmp$Ch3[9])) 
# Sampling interval for AM
AM_dt <- as.numeric(unlist(tmp$Ch3[3])) 
# Generate a time vector for AM
time_AM = seq(AM_dt, length(AM)*AM_dt, AM_dt)

# The membrane potential values
vm <- as.numeric(unlist(tmp$Ch5[9]))
# The sampling interval
vm_dt <- as.numeric(unlist(tmp$Ch5[3]))

plotPhys = data.frame(time_AM, AM) 

# SHINY SELECT RANGE
ui <- basicPage(
  mainPanel(plotOutput("plot")),                            # THE PLOT
  
  sliderInput("bb_x", "Time:",
              min=0, max=max(time_AM), value=range(time_AM),
              step=0.5, animate=TRUE),                      # THE SLIDER
  
  actionButton("myBtn", "Close Window")                     # CLOSE BUTTON
) # End UI

server <- function(input, output) {
  
  # Plot window
  output$plot <- renderPlot({
    
    rng <<- input$bb_x # the double arrow makes this a universal variable
    
    ggplot(data=plotPhys) +
      geom_line(colour = "Blue", show.legend = FALSE, aes(x = time_AM, y = AM)) +
      xlab("Time, S") +
      ylab("Vm, mV") +
      ggtitle("Neurophysiology: black original, blue filtered") +
      xlim(rng) # Adjusts xlim
  }) 
  
  # Slider Action
  output$range <- renderPrint({ input$slider2 }) 
  
  # Button Action
  observe({
    if(input$myBtn > 0){
      stopApp(7)
    }
  }) 
  
} # End server
shinyApp(ui, server)
