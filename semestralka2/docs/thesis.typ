#import "template/template.typ": *

#show: tultemplate2.with(
  faculty: "fm",
  document: "sp",
  lang: "en",
  title: (
    cs: [Řešení vícerozměrného batohu: Metoda hrubé síly a greedy heuristiky],
    en: [Solving the Multidimensional Knapsack Problem: Brute-Force Search and Greedy Heuristics],
  ),
  keywords: none,
  abstract: none,
  title_pages: none,
  acknowledgement: none,
  author: "Bc. Petr Boháč",
  citations: "citations.bib",
)

= Introduction <intro>

#include "chapters/introduction.typ"

= Implementation <implementation>

#include "chapters/implementation.typ"

= Results <results>

#include "chapters/results.typ"

= Conclusion <conclusion>

#include "chapters/conclusion.typ"

