shinyUI(fluidPage(
  titlePanel("Investigating time scales of variability in tree ring data"),
  h4('This Shiny App allows you to detrend a long term time series of tree ring data with a smoothing spline and visualise the residuals. A second smoothing spline is fitted to the residuals. Set the time frame you wish to visualise and the the smoothing spline parameters with the sliders. Have the temporal scales of tree ring increment variability changed in the the past 5000 years?'),
  fluidRow(
    column(3,
           wellPanel(
             h3("Plot Parameters"),
             h4("Set Timeframe"),
             sliderInput('xrange', 'Enter Range of Years', value = c(-3435,1969), min = -3435, max = 1969, step = 1),
             h4("Set Spline Smoothing Parameters"),
             sliderInput('spar1', 'Red Spline - raw data', value = 0.75, min = -1, max = 1.5, step = 0.01),
             sliderInput('spar2', 'Blue Spline - detrended data', value = 0.75, min = -1, max = 1.5, step = 0.01)
  ),
  wellPanel(
    h3("Spline Fit Statistics"),
    textOutput('residSum1'),
    textOutput('residSum2'),
    textOutput('residSum3')
  )
  ),
  column(9,
      plotOutput('splinePlot1', width = '100%', height = "150px"),
      plotOutput('residuals1', width = '100%', height = "150px"),
      plotOutput('splinePlot2', width = '100%', height = "150px"),
      plotOutput('residuals2', width = '100%', height = "150px")
    )
  )
))
