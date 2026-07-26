assessment_ilos <- function() {
  c(
    "Discuss the requirements for success in effective species conservation by integrating theory and case studies.",
    "Diagnose and solve biodiversity problems by applying fundamental principles from population and community ecology, genetics and ecosystem science.",
    "Evaluate the causes of uncertainty and controversy in the development of strategies for species conservation.",
    "Communicate a conservation problem to scientific peers and relevant stakeholders."
  )
}

assessment_criteria <- function() {
  data.frame(
    criterion = paste0("C", 1:4),
    marks = c(5L, 6L, 8L, 6L),
    assessment_criteria = c(
      "Describe the uses and limitations of simulation modelling in conservation decision-making.",
      "Model stochastic processes and causes of threat.",
      "Undertake scenario testing to compare the relative effectiveness of alternative management options.",
      "Translate simulation results and communicate them as conservation recommendations."
    ),
    stringsAsFactors = FALSE
  )
}
