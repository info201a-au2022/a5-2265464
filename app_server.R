library("dplyr")
library("tidyr")
library("ggplot2")
library("plotly")

data <- read.csv("https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv",
  stringsAsFactors = FALSE
)
data <- data %>%
  select(
    "country", "year", "ghg_per_capita", "co2_including_luc_per_capita",
    "methane_per_capita", "nitrous_oxide_per_capita"
  )

ghg_latest_data <- data %>%
  select("country", "year", "ghg_per_capita") %>%
  drop_na() %>%
  filter(year == max(year, na.rm = TRUE))
ghg_latest_year <- max(ghg_latest_data$year, na.rm = TRUE)

avg_ghg <- round(mean(ghg_latest_data$ghg_per_capita, na.rm = TRUE), 3)

max_ghg <- ghg_latest_data %>%
  filter(ghg_per_capita == max(ghg_per_capita, na.rm = TRUE)) %>%
  pull(ghg_per_capita)
max_ghg_country <- ghg_latest_data %>%
  filter(ghg_per_capita == max(ghg_per_capita, na.rm = TRUE)) %>%
  pull(country)

min_ghg <- ghg_latest_data %>%
  filter(ghg_per_capita == min(ghg_per_capita, na.rm = TRUE)) %>%
  pull(ghg_per_capita)
min_ghg_country <- ghg_latest_data %>%
  filter(ghg_per_capita == min(ghg_per_capita, na.rm = TRUE)) %>%
  pull(country)

server <- function(input, output, session) {
  updateSelectizeInput(session,
    inputId = "country",
    choices = data$country,
    selected = c("United States", "United Kingdom", "China", "India"),
    server = TRUE
  )
  output$chart <- renderPlotly({
    if (is.null(input$country)) {
      empty_plot <- plotly_empty(type = "scatter", mode = "markers") %>%
        config(displayModeBar = FALSE) %>%
        layout(title = "No country selected")
      return(empty_plot)
    }
    if (input$gas == "co2_including_luc_per_capita") {
      updateSliderInput(session,
        inputId = "year",
        min = 1850
      )
    } else {
      updateSliderInput(session,
        inputId = "year",
        min = 1990
      )
    }
    filtered_data <- data %>%
      filter(country %in% input$country) %>%
      filter(year >= input$year[1] & year <= input$year[2])
    line_chart <- ggplot(filtered_data) +
      aes(x = year, y = get(input$gas), ymin = 0, color = country) +
      geom_line() +
      labs(x = "Year", y = "Tonnes per Person") +
      scale_color_discrete(name = "Country")
    if (input$gas == "ghg_per_capita") {
      line_chart <- line_chart +
        labs(title = "Per Capita Total Greenhouse Gas Emissions Over Time")
    } else if (input$gas == "co2_including_luc_per_capita") {
      line_chart <- line_chart +
        labs(title = "Per Capita Carbon Dioxide Emissions Over Time")
    } else if (input$gas == "methane_per_capita") {
      line_chart <- line_chart +
        labs(title = "Per Capita Methane Emissions Over Time")
    } else if (input$gas == "nitrous_oxide_per_capita") {
      line_chart <- line_chart +
        labs(title = "Per Capita Nitrous Oxide Emissions Over Time")
    }
    line_chart <- ggplotly(line_chart,
      tooltip = c("year", "get(input$gas)", "country")
    )
    return(line_chart)
  })
}
