As mentioned in @intro, the first part of the assignment involved implementing a naive brute-force approach which is supposed to be awfully inefficient to really drive the point home about NP problems. The second part was to implement a more optimized heuristic algorithm to compare the results of both approaches.

== The problem

Let us also familiarize ourselves with the problem we are solving. Consider a set of application deployments, each with a priority value and resource requirements in three dimensions: memory, CPU, and storage. The goal is to select a subset of these deployments to maximize the total priority value without exceeding the available resources in any dimension.

#figure(
  ```python
  from collections import namedtuple

  Deployment = namedtuple("Deployment", [
      "name", "memory", "cpu", "storage", "priority"
  ])
  ```,
  caption: "Data structure for representing an application deployment",
)


== Brute-force approach

Coming up with a brute-force algorithm is fairly straightforward as it simply involves generating all possible combinations of items and checking which one yields the highest value without exceeding the knapsack's capacity in any dimension.

The implementation uses the `itertools.combinations` from Python's standard library to generate all possible combinations of items. For each combination, it calculates the total weight in each dimension and the total value. If the combination fits within the knapsack's capacity and has a higher value than the best found so far, it updates the best value and combination.

The previous steps are repeated for all possible combination lengths, from 1 to the total number of items.

The complete implementation of the brute-force approach is shown in @brute-force-implementation.

#figure(
  ```python
  def knapsack_bf(items, capacity):
      best_value = 0
      best_combination = set()

      for r in range(len(items) + 1):
          for combination in itertools.combinations(items, r):
              total_memory = sum(item.memory for item in combination)
              total_cpu = sum(item.cpu for item in combination)
              total_storage = sum(item.storage for item in combination)

              if all((
                  total_memory <= capacity[0],
                  total_cpu <= capacity[1],
                  total_storage <= capacity[2],
              )):
                  total_value = sum(item.priority for item in combination)
                  if total_value > best_value:
                      best_value = total_value
                      best_combination = combination

      return best_value, best_combination
  ```,
  caption: "Brute-force implementation (simplified)",
) <brute-force-implementation>

== Greedy heuristic

Prior to writing this, I had no understanding of the term _greedy_ in the context of algorithms, so I looked it up:

#quote(
  attribution: [Wikipedia],
  block: true,
)[
  A *greedy algorithm* is any algorithm that follows the problem-solving heuristic of making the locally optimal choice at each stage.
]

The term _heuristic_ was also a bigbrain term for me. My understanding is that it refers to an approach that is not guaranteed to be optimal or perfect, but is practical and sufficient for reaching an immediate goal. It is more of a method or strategy rather than a strict algorithm.

With all this new knowledge, I pieced together an algorithm that tries multiple different heuristics and picks the best result among them.

As showin in @scoring-functions, four distinct scoring functions were used to evaluate the items. They are pretty much just *value-to-cost* ratios, one for each of the constraints (memory, CPU, storage), and one that considers the total cost across all dimensions.

#figure(
  ```python
  def score_memory(item):
      return item.priority / item.memory

  def score_cpu(item):
      return item.priority / item.cpu

  def score_storage(item):
      return item.priority / item.storage

  def score_total(item):
      return item.priority / (item.memory + item.cpu + item.storage)
  ```,
  caption: "Scoring functions used in the greedy heuristic",
) <scoring-functions>

The greediness of the algorithm comes from sorting the items based on each scoring function and then iteratively adding them to the knapsack as long as they fit within the remaining capacity.

This process obviously does not guarantee an optimal solution, but by trying multiple scoring strategies, it increases the chances of finding a good approximation. This further adds to the greediness of the algorithm by continually seeking the best immediate gain through different perspectives.

The complete implementation of the greedy heuristic is shown in @greedy-implementation.

#figure(
  ```python
  def knapsack(items, capacity):
      items_list = list(items)

      score_functions = [
          score_memory,
          score_cpu,
          score_storage,
          score_total
      ]

      best_value = 0
      best_combination = set()

      for score_fn in score_functions:
          sorted_items = sorted(items_list, key=score_fn, reverse=True)

          total_memory = 0
          total_cpu = 0
          total_storage = 0
          chosen = []

          for item in sorted_items:
              if all(
                  (
                      total_memory + item.memory <= capacity[0],
                      total_cpu + item.cpu <= capacity[1],
                      total_storage + item.storage <= capacity[2],
                 )
             ):
                  chosen.append(item)
                  total_memory += item.memory
                  total_cpu += item.cpu
                  total_storage += item.storage

              progress.update(1)

          total_value = sum(i.priority for i in chosen)

          if total_value > best_value:
              best_value = total_value
              best_combination = set(chosen)

      return best_value, best_combination
  ```,
  caption: "Greedy heuristic implementation (simplified)",
) <greedy-implementation>
