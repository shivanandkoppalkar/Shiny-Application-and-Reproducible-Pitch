library(shiny)
library(UsingR)
data(camp)
shinyServer(
  function(input, output) {
    camp.spline1 <- reactive({smooth.spline(x = camp, spar = input$spar1)})
    camp.spline2 <- reactive({smooth.spline(x = camp - camp.spline1()$y, spar = input$spar2)})
    output$splinePlot1 <- renderPlot({
      par(plt = c(0.2,0.90,0.1,0.95))
      plot.default(x = camp, main = 'Annual Tree Ring Increment',
                   xlim = input$xrange,
                   type = 'p', pch = 1)
      lines(camp.spline1(), col = 2, lwd = 3)
    })
    output$splinePlot2 <- renderPlot({
      par(plt = c(0.2,0.90,0.2,0.95))
      plot.default(x = camp - camp.spline1()$y,
                   xlab = 'Year',
                   xlim = input$xrange,
                   type = 'p', pch = 1,
                   ylab = "Detrended Data")
      lines(camp.spline2(), col = 4, lwd = 3)
    })
    output$residuals1 <- renderPlot({
      par(plt = c(0.2,0.90,0.2,0.95))
      hist(x = camp - camp.spline1()$y, 
           main = "Residuals after first smoothing",
           xlab = "Residual tree ring increment (mm)")
    })
    output$residSum1 <- renderText({
      paste("Sum of first spline residuals = ",
      format(sum(abs(camp - camp.spline1()$y)), digits = 2))
      })
    output$residuals2 <- renderPlot({
      par(plt = c(0.2,0.90,0.2,0.95))
      hist(x = camp - camp.spline1()$y - camp.spline2()$y, 
           main = "Residuals after second smoothing",
           xlab = "Residual tree ring increment (mm)")
    })
    output$residSum2 <- renderText({
      paste("Second spline residuals = ",
          format(sum(abs(camp - camp.spline1()$y - camp.spline2()$y)), digits = 2))
    })
    output$residSum3 <- renderText({
      paste("Some of both spline residuals = ",
            format(sum(sum(abs(camp - camp.spline1()$y)),sum(abs(camp - camp.spline1()$y - camp.spline2()$y))), digits = 2))
    })
  }
)
