As it usually is with brute-force algorithms, the time complexity grows exponentially with the number of items, or more formally:

#align(center)[
  $"Time(n)" = O(2^n)$, where $n = |S|$ is the cardinality of the input item set $S$
]

This is because all possible combinations of items need to be evaluated to ensure the optimal solution is found. With each additional item, the number of possible combinations doubles. For example, running the algorithm over a set of 22 items results in a runtime of \~8 seconds, while increasing the set to 23 items results in a runtime of \~16 seconds, and 24 items leads to \~32 seconds, and so on.

In contrast, the greedy heuristic has a logarithmic time complexity:

#align(center)[
  $"Time(n)" = O(n * log n)$, where $n = |S|$ is the cardinality of the input item set $S$
]

More specifically, the time complexity for our particular implementation is $O(4 * n * log n)$, since it evaluates four different scoring functions, each requiring a single pass through the list of items to sort them and another pass to select items based on the sorted order. However, in Big O notation, constant factors are disregarded @bigo-constant-factors, so it simplifies to $O(n * log n)$.

The time complexities of the two approaches are illustrated in @alg-time-complexity-graph, where the exponential growth of the brute-force method is clearly contrasted with the logarithmic growth of the greedy heuristic.

#figure(
  image("../assets/bf-vs-greedy-time-complexity.png", width: 135%),
  caption: [Exponential vs. logarithmic runtime behaviour of BF and greedy knapsack algorithms.],
) <alg-time-complexity-graph>

As indicated by the vastly different scales of the two y-axes, the brute-force method becomes computationally infeasible even for moderately large input sizes. In contrast, the greedy heuristic maintains low and predictable running times as the number of items increases, making it suitable for practical use in real-world scenarios.

== Determining the maximum input size for a sub-hour runtime

One of the requirements of the assignment was to determine the maximum input size that allows the algorithms to find the optimal solution within one hour.

This is quite simple for the brute-force approach, as we can employ empirical measurements to extrapolate the maximum input size - a set of 31 items can be processed in under an hour, while a set of 32 items exceeds the time limit (also confirmed by doing the math in @bf-calc).

For the optimized algorithm though is so much more performant that the input set (which has to be filled manually) would be unreasonably large to create. Therefore, coming up with a simple mathematical formula to estimate the maximum input size is more appropriate.

A runtime for a given input size $n$ can be expressed as:

#align(center)[
  $ "Time(n)" = "Iter(n)" / "IPS" $
]

Where $"Iter(n)"$ is the number of iterations the algorithm performs for input size $n$, so pretty much just the time complexity - $2^n$ for brute-force and $4n$ for greedy. The $"IPS"$ variable is the number of iterations the system can perform per second (or the throughput).

The included progress bar feature of the implementation provides an $"ops/sec"$ value allowing us to estimate the $"IPS"$ values for my system (a 2024 M4 MacBook Pro):

#align(center)[
  $ "IPS(Brute-force)" #sym.approx 600,000 $
  $ "IPS(Greedy)" #sym.approx 1,200,000 $
]

A sub-hour runtime (3600 seconds) means:

#align(center)[
  $ "Iter(n)" <= 3600 #sym.dot "IPS" $
]

=== Brute-force <bf-calc>

Considering $"Iter(n)" = 2^n$, start with the inequality:

#align(center)[$ 2^n <= 3600 #sym.dot "IPS" $]

Take the base-2 logarithm of both sides:

#align(center)[$ n <= log_2(3600 #sym.dot "IPS") $]

Substitute $"IPS" = 600000$:

#align(center)[
  $ n <= log_2(3600 #sym.dot 600000) $
]

Compute the value:

#align(center)[
  $ n <= log_2(2160000000) $
]

Which evaluates to:

#align(center)[
  $ n <= 31.008384… $
]

Since $n$ must be an integer:

#align(center)[
  $ n_max^"(brute)" = floor(31.008384…) = bold(31) $
]

=== Greedy

Considering $"Iter(n)" = 4n * log_2 n$, start with the inequality:

#align(center)[$ 4n * log_2 n <= 3600 #sym.dot "IPS" $]

Substitute $"IPS" = 1200000$:

#align(center)[
$ 4n * log_2 n <= 3600 #sym.dot 1200000 $
]

Simplify the right-hand side:

#align(center)[
$ 4n * log_2 n <= 4320000000 $
]

Divide both sides by $4$:

#align(center)[
$ n * log_2 n <= 1080000000 $
]

This inequality cannot be solved analytically for $n$, so we approximate numerically.
Testing values shows that the bound is reached for approximately:

#align(center)[
$ n #sym.approx 4 #sym.dot 10^7 $
]

Thus:

#align(center)[
$ n_max^"(greedy)" #sym.approx bold(40000000) $
]