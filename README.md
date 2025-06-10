# Introduction

The analysis summarizes review scores for employees, based on feedback from peers, managers, and direct reports.

Key findings include:
- Users tend to rate themselves higher than others do, suggesting a perception gap.
- The behaviour "Listens to feedback about their impact on others" consistently received lower ratings, highlighting a common development area.
- Some users participated in multiple review cycles; scores were aggregated to ensure each individual is represented fairly.

# Answers to Assessment Questions

## Design choices:
For layout, I chose a clean and simple structure with a sidebar for filters and a main panel with tabs for visual outputs and a data table. I have added a summary of findings in the main panel to gain some initial insights into the review analysis. This allows users to easily interact with the data without feeling overwhelmed.

For interactivity, the app responds dynamically to the user’s selections — first my prompting the user to select atleast one population group, then enabling drilldown into individual employees and review relationships. Interactive Plotly charts and DataTables make the insights more accessible and engaging.

In terms of maintainability, I structured the app using reactive expressions and modular UI components (e.g., dynamically generated selectors). This makes it easy to adapt the app if new data fields or visualizations are added later. The code is also separated clearly between UI and server logic.

## Extensions:
Next, I would add trend analysis — for example, how an individual’s ratings change over time across review cycles. This could help visualize personal growth or areas needing further support. I would also add additional filters or plots to evaluate the scores against parameters such as gender, ethnicity and sexuality.

## Clarifying stakeholder needs:
Before comparing self vs. peer reviews, I would ask:

- Are there clear guidelines or expectations about how users should rate themselves (i.e., are they encouraged to be self-critical, honest, aspirational)?
- Is the peer group consistent across review cycles, or does it vary? Variations could affect comparability.
- Are there specific behaviours or themes the stakeholders are most interested in when looking at gaps between self and others?
