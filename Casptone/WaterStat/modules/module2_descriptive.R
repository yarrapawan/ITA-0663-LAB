# Module 2 — Exploratory & Descriptive Statistical Analysis
# Calculates descriptive statistics and explores distributions, correlations,
# and relationships between water-quality parameters using all major chart types.

module2DescriptiveUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "module-header mb-3 p-3 bg-white rounded shadow-sm border-start border-4 border-info",
      div(class = "d-flex justify-content-between align-items-center flex-wrap gap-2",
        div(
          h4(class = "mb-1 text-info fw-bold", icon("chart-pie", class = "me-2"), "Module 2: Exploratory & Descriptive Statistical Analysis"),
          p(class = "text-muted mb-0 small",
            "Calculates statistical moments (mean, median, variance, SD, quartiles, skewness), visualizes KDE, violin, and bivariate scatter plots, standardizes Z-scores, and tests Pearson/Spearman correlation significance.")
        ),
        span(class = "badge bg-info-subtle text-info fw-bold px-3 py-2 border", icon("chart-line", class = "me-1"), "Exploratory Analytics")
      )
    ),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(width = 280,
        h6(class = "fw-bold text-dark", icon("sliders"), " Visual & Filter Controls"),
        div(class = "small text-muted mb-2", textOutput(ns("dataset_status"))),
        checkboxGroupInput(ns("groups"), "Filter Potability Groups:", c("Non-potable", "Potable"), selected = c("Non-potable", "Potable")),
        hr(),
        selectInput(ns("param"), "Select Water Parameter:", WQ_PARAMS, selected = "pH"),
        uiOutput(ns("range_slider_ui")),
        hr(),
        h6(class = "fw-bold text-dark", icon("arrows-split-up-and-left"), " Bivariate Pair"),
        selectInput(ns("x_var"), "X Parameter:", WQ_PARAMS, selected = "pH"),
        selectInput(ns("y_var"), "Y Parameter:", WQ_PARAMS, selected = "Hardness"),
        hr(),
        h6(class = "fw-bold text-dark", icon("calculator"), " Correlation Method"),
        radioButtons(ns("cor_method"), NULL, c("Pearson (Linear)" = "pearson", "Spearman (Rank)" = "spearman"), inline = TRUE)
      ),
      navset_card_tab(
        id = ns("tabs"),
        nav_panel(
          title = tagList(icon("chart-area"), " Univariate Distributions"),
          div(class = "d-flex justify-content-between align-items-center mb-2 p-2 bg-light rounded",
            radioButtons(ns("chart_type"), "Select Distribution Chart Type:",
              c("Histogram" = "hist", "Kernel Density" = "density", "Box Plot" = "box", "Violin Plot" = "violin"),
              inline = TRUE)
          ),
          plotlyOutput(ns("plot_univariate"), height = "440px"),
          uiOutput(ns("param_metric_cards"))
        ),
        nav_panel(
          title = tagList(icon("chart-line"), " Bivariate Relationships"),
          plotlyOutput(ns("plot_bivariate"), height = "400px"),
          div(class = "alert alert-secondary mt-2 py-2 small", verbatimTextOutput(ns("bivariate_stats"))),
          h6(class = "fw-bold mt-3 text-secondary", icon("object-group"), " Group Comparison of Selected Parameter"),
          plotlyOutput(ns("plot_group_box"), height = "300px")
        ),
        nav_panel(
          title = tagList(icon("layer-group"), " Comparative Multi-Parameter"),
          p(class = "small text-muted", "Standardized Z-scores permit direct side-by-side comparison of all 9 parameters irrespective of their measurement units."),
          plotlyOutput(ns("plot_multi_compare"), height = "420px"),
          hr(),
          h6(class = "fw-bold text-secondary", icon("chart-simple"), " Parameter Mean Comparisons (Mean ± Standard Error)"),
          plotlyOutput(ns("plot_means_facet"), height = "450px")
        ),
        nav_panel(
          title = tagList(icon("border-all"), " Correlation Heatmap & Matrix"),
          div(class = "alert alert-info py-2 small mb-2",
            icon("circle-info"), " Note: Correlation evaluates statistical association between parameters; it does NOT imply direct physical causation."),
          plotlyOutput(ns("plot_heatmap_cor"), height = "440px"),
          hr(),
          h6(class = "fw-bold text-secondary", icon("table-cells"), " Pairwise Correlation Coefficients & Significance (alpha = 0.05)"),
          DTOutput(ns("table_pairwise_cor"))
        ),
        nav_panel(
          title = tagList(icon("table-list"), " Descriptive Statistics Tables"),
          selectizeInput(ns("desc_vars"), "Select Parameters for Statistics Table:", WQ_PARAMS, selected = WQ_PARAMS, multiple = TRUE),
          card(card_header(icon("calculator"), " Overall Descriptive Statistics (All Samples)"), DTOutput(ns("table_desc"))),
          card(card_header(icon("users"), " Descriptive Statistics Partitioned by Potability Class"), DTOutput(ns("table_group_desc")))
        )
      )
    )
  )
}

module2DescriptiveServer <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$dataset_status <- renderText({
      if (is.null(state$raw)) "Status: No dataset loaded" else paste("Dataset:", state$source)
    })

    output$range_slider_ui <- renderUI({
      need_valid(state)
      x <- state$data[[input$param]]
      req(any(!is.na(x)))
      lo <- floor(min(x, na.rm = TRUE))
      hi <- ceiling(max(x, na.rm = TRUE))
      if (lo == hi) { lo <- lo - 1; hi <- hi + 1 }
      sliderInput(ns("param_range"), paste("Filter", input$param, "Range:"), lo, hi, c(lo, hi))
    })

    filtered_df <- reactive({
      need_valid(state)
      d <- add_group(state$data)
      if (isTRUE(state$validation$has_target)) {
        validate(need(length(input$groups) > 0, "Please select at least one potability group."))
        d <- d[d$Group %in% input$groups | is.na(d$Group), ]
      }
      r <- input$param_range
      if (!is.null(r) && length(r) == 2 && input$param %in% names(d)) {
        x <- d[[input$param]]
        val_min <- min(x, na.rm = TRUE)
        val_max <- max(x, na.rm = TRUE)
        if (r[1] <= val_max && r[2] >= val_min) {
          d <- d[is.na(x) | (x >= r[1] & x <= r[2]), ]
        }
      }
      validate(need(nrow(d) > 5, "Too few observations available under current filter settings."))
      d
    })

    target_df <- reactive({
      need_target(state)
      filtered_df()
    })

    # Univariate Chart
    output$plot_univariate <- renderPlotly({
      d <- filtered_df()
      p_name <- input$param
      g <- switch(input$chart_type,
        "hist" = plot_hist(d, p_name),
        "density" = plot_density(d, p_name),
        "box" = plot_box(d, p_name),
        "violin" = plot_violin(d, p_name),
        plot_hist(d, p_name)
      )
      safe_run(ggplotly(g), "Distribution Plot")
    })

    output$param_metric_cards <- renderUI({
      d <- filtered_df()
      x <- na.omit(d[[input$param]])
      if (!length(x)) return(NULL)
      sk_val <- if (length(x) >= 3 && sd(x) > 0) round(psych::skew(x), 3) else "N/A"
      layout_columns(
        col_widths = c(2, 2, 2, 2, 2, 2),
        value_box("Mean", round(mean(x), 2), theme = "primary"),
        value_box("Median", round(median(x), 2), theme = "info"),
        value_box("Std Dev", round(sd(x), 2), theme = "light"),
        value_box("Min", round(min(x), 2), theme = "light"),
        value_box("Max", round(max(x), 2), theme = "light"),
        value_box("Skewness", sk_val, theme = "warning")
      )
    })

    # Bivariate Chart
    output$plot_bivariate <- renderPlotly({
      d <- filtered_df()
      safe_run(ggplotly(plot_scatter(d, input$x_var, input$y_var)), "Bivariate Scatter Plot")
    })

    output$bivariate_stats <- renderText({
      d <- filtered_df()
      ok <- complete.cases(d[[input$x_var]], d[[input$y_var]])
      validate(need(sum(ok) > 3 && input$x_var != input$y_var, "Please choose two distinct parameters with complete cases."))
      x_vals <- d[[input$x_var]][ok]
      y_vals <- d[[input$y_var]][ok]
      validate(need(sd(x_vals) > 0 && sd(y_vals) > 0, "Correlation requires variation in both selected parameters."))
      ct <- tryCatch(cor.test(x_vals, y_vals, method = input$cor_method), error = function(e) NULL)
      validate(need(!is.null(ct), "Correlation test could not be evaluated."))
      sprintf("%s Correlation: r = %.4f (p-value = %.4g, n = %d observations).\nStatistical inference: %s association. Correlation indicates relationship, not physical cause.",
        toupper(input$cor_method), ct$estimate, ct$p.value, sum(ok),
        if (ct$p.value < 0.05) "Statistically significant" else "No statistically significant")
    })

    output$plot_group_box <- renderPlotly({
      d <- target_df()
      safe_run(ggplotly(plot_box(d, input$param)), "Group Boxplot")
    })

    # Comparative Multi-Parameter Charts
    output$plot_multi_compare <- renderPlotly({
      d <- target_df()
      safe_run(ggplotly(plot_compare_all(d)), "Multi-parameter Standardized Plot")
    })

    output$plot_means_facet <- renderPlotly({
      d <- target_df()
      safe_run(ggplotly(plot_means_barchart(d)), "Means Comparison Bar Chart")
    })

    # Heatmap & Correlations
    output$plot_heatmap_cor <- renderPlotly({
      d <- filtered_df()
      cm <- cor_matrix(d, input$cor_method)
      safe_run(ggplotly(plot_heatmap(cm)), "Correlation Heatmap")
    })

    output$table_pairwise_cor <- renderDT({
      d <- filtered_df()
      ctable <- safe_run(cor_table(d, input$cor_method), "Correlation Table")
      datatable(ctable, rownames = FALSE, filter = "top", options = list(pageLength = 10, scrollX = TRUE))
    })

    # Descriptive Statistics Tables
    output$table_desc <- renderDT({
      need_valid(state)
      vars <- if (length(input$desc_vars)) input$desc_vars else WQ_PARAMS
      stats <- safe_run(describe_stats(state$data, vars), "Descriptive Statistics")
      datatable(stats, rownames = FALSE, options = list(dom = "t", scrollX = TRUE))
    })

    output$table_group_desc <- renderDT({
      need_target(state)
      gstats <- safe_run(group_stats(state$data), "Group Statistics")
      datatable(gstats, rownames = FALSE, options = list(pageLength = 18, scrollX = TRUE))
    })
  })
}
