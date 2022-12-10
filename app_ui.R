library("shiny")
library("shinythemes")
library("plotly")

source("app_server.R")

intro_tab <- tabPanel(
  "Introduction",
  fluidPage(
    h1("Trends in Greenhouse Gas Emissions"),
    p(
      "This website was designed to present greenhouse gas emissions data compiled by",
      a("Our World In Data", href = " https://ourworldindata.org/co2-and-other-greenhouse-gas-emissions", .noWS = c("after")), ".",
      "In the interactive visualization page, by specifying a greenhouse gas, selecting one or more countries, and setting a time horizon, users could see from the line chart how emissions of each greenhouse gas have changed over the years in different countries.",
      "We hope that general people could learn about the influence of human activities on the global environment and that researchers and government officials could reflect on current climate policies."
    ),
    h2("Variables and Measures"),
    p(
      "To understand emissions of different greenhouse gases in countries of different populations, we focus on analyzing",
      strong("per capita total greenhouse gas emissions", .noWS = c("after")), ",", strong("per capita carbon dioxide emissions", .noWS = c("after")), ",",
      strong("per capita methane emissions", .noWS = c("after")), ", and", strong("per capita nitrous oxide emissions", .noWS = c("after")), ".",
      "These variables represent the average annual emissions, including land-use change, in tonnes per person for a country. The CO₂ emissions account for production-based (territorial) emissions. The non-CO₂ gas emissions are measured in CO₂ equivalents."
    ),
    h2("Summary Information"),
    p(paste0(
      "In ", ghg_latest_year, ", the latest year for which total greenhouse gas emissions data are available, ",
      "the global average per capita total greenhouse gas emissions were ", avg_ghg, " tonnes of CO₂ equivalents. ",
      "Out of all countries, ", max_ghg_country, " produced the largest per capita total greenhouse gas emissions, ", max_ghg, " tonnes of CO₂ equivalents; ",
      min_ghg_country, " produced the lowest per capita total greenhouse gas emissions, ", min_ghg, " tonnes of CO₂ equivalents."
    )),
  )
)

chart_sidebar <- sidebarPanel(
  selectInput(
    inputId = "gas",
    label = "Greenhouse Gas",
    choices = list(
      "Total Greenhouse Gases" = "ghg_per_capita",
      "Carbon Dioxide" = "co2_including_luc_per_capita",
      "Methane" = "methane_per_capita",
      "Nitrous Oxide" = "nitrous_oxide_per_capita"
    ),
    selected = "ghg_per_capita"
  ),
  selectizeInput(
    inputId = "country",
    label = "Type to add a country",
    choices = NULL,
    multiple = TRUE,
  ),
  sliderInput(
    inputId = "year",
    label = "Time Horizon",
    min = 1850,
    max = 2021,
    value = c(1850, 2021),
    sep = ""
  )
)

chart_main <- mainPanel(
  plotlyOutput(outputId = "chart"),
  p(
    "Carbon dioxide (CO₂) is the most dominant greenhouse gas in our world, but other greenhouse gases, such as methane (CH₄) and nitrous oxide (N₂O), also need attention.",
    "Furthermore, greenhouse gas emissions of different countries are of interest.",
    "This chart allows users to discover the trend in total greenhouse gas emissions and three major greenhouse gas emissions across the world."
  ),
  p(
    "In general, there was no obvious difference in the trend of emissions by gas, but CO₂ did account for the majority of greenhouse gases.",
    "In the comparison of emissions by country, developed countries produced significantly more considerable per capita greenhouse gas emissions, especially prior to 2010.",
    "This might be due to their mature industrial production.",
    "However, from 1990 to 2019, developed countries, such as the United States and the United Kingdom, had decreasing greenhouse gas emissions.",
    "In contrast, developing countries, such as China and India, had increasing greenhouse gas emissions.",
    "This might be because developed countries have implemented policies to reduce emissions while developing countries have promoted manufacturing."
  )
)

chart_tab <- tabPanel(
  "Interactive Visualization",
  sidebarLayout(
    chart_sidebar,
    chart_main
  )
)

ui <- navbarPage(
  theme = shinytheme("readable"),
  "Greenhouse Gas Emissions",
  intro_tab,
  chart_tab
)
