import math
from matplotlib import pyplot as plt

SIZE = 35
IPS = 600_000
IPS_GREEDY = 1_200_000

x = range(1, SIZE)
brute_force = [(2**i) / IPS for i in x]
optimized = [(4 * i * math.log(i)) / IPS_GREEDY for i in x]

fig, ax1 = plt.subplots()

ax1.plot(x, brute_force, color="tab:red", label="Brute-force approach O(2^n)")
ax1.set_ylabel("Seconds", color="tab:red")
ax1.tick_params(axis="y", labelcolor="tab:red")

ax2 = ax1.twinx()

ax2.plot(x, optimized, color="tab:blue", label="Greedy approach O(n * log n)")
ax2.set_ylabel("Seconds", color="tab:blue")
ax2.tick_params(axis="y", labelcolor="tab:blue")

ax1.set_xlabel("Size of the initial set")
plt.title(
    "Brute-force vs greedy multidimensional knapsack problem (MacBook Pro M4, 2024)"
)

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
plt.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

plt.tight_layout()
plt.show()
