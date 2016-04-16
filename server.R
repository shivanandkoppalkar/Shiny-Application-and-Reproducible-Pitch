library(shiny)
library(HistData)
data(GaltonFamilies)
library(dplyr)
library(ggplot2)

# converting in centimeters
gf <- GaltonFamilies
gf <- gf %>% mutate(father=father*2.54,
                    mother=mother*2.54,
                    childHeight=childHeight*2.54)

# linear model
regmod <- lm(childHeight ~ father + mother + gender, data=gf)

shinyServer(function(input, output) {
  output$parentsText <- renderText({
    paste("When the father's height is",
          strong(round(input$inFh, 1)),
          "cm, and mother's is",
          strong(round(input$inMh, 1)),
          "cm, then:")
  })
  output$prediction <- renderText({
    df <- data.frame(father=input$inFh,
                     mother=input$inMh,
                     gender=factor(input$inGen, levels=levels(gf$gender)))
    ch <- predict(regmod, newdata=df)
    sord <- ifelse(
      input$inGen=="female",
      "Daugther",
      "Son"
    )
    paste0(em(strong(sord)),
           "'s predicted height would be approximately ",
           em(strong(round(ch))),
           " cm"
    )
  })
  output$barsPlot <- renderPlot({
    sord <- ifelse(
      input$inGen=="female",
      "Daugther",
      "Son"
    )
    df <- data.frame(father=input$inFh,
                     mother=input$inMh,
                     gender=factor(input$inGen, levels=levels(gf$gender)))
    ch <- predict(regmod, newdata=df)
    yvals <- c("Father", sord, "Mother")
    df <- data.frame(
      x = factor(yvals, levels = yvals, ordered = TRUE),
      y = c(input$inFh, ch, input$inMh),
      colors = c("pink", "orange", "blue")
    )
    ggplot(df, aes(x=x, y=y, color=colors, fill=colors)) +
      geom_bar(stat="identity", width=0.5) +
      xlab("") +
      ylab("Height (cm)") +
      theme_minimal() +
      theme(legend.position="none")
  })
})