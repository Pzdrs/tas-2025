from collections import namedtuple
import sys
from tabulate import tabulate
from tqdm import tqdm
import itertools
import logging

from utils import timeit

Deployment = namedtuple("Deployment", ["name", "memory", "cpu", "storage", "priority"])

ITEMS = {
    Deployment("Gitlab", 8192, 4, 100, 10),
    Deployment("Jellyfin", 4096, 2, 50, 7),
    Deployment("Nextcloud", 16384, 8, 200, 15),
    Deployment("Home Assistant", 2048, 1, 20, 5),
    Deployment("Homepage", 512, 1, 0.1, 3),
    Deployment("Node-RED", 1024, 1, 5, 4),
    Deployment("Plex", 4096, 2, 40, 8),
    Deployment("Immich", 6144, 4, 150, 11),
    Deployment("Paperless-ngx", 2048, 2, 30, 6),
    Deployment("Gitea", 2048, 2, 10, 9),
    Deployment("Minecraft Server", 4096, 4, 10, 6),
    Deployment("Mosquitto MQTT", 512, 1, 1, 4),
    Deployment("Vaultwarden", 1024, 1, 5, 10),
    Deployment("Grafana", 2048, 2, 10, 7),
    Deployment("Prometheus", 2048, 2, 20, 8),
    Deployment("Unifi Controller", 1024, 1, 5, 5),
    Deployment("Photoprism", 8192, 4, 200, 12),
    Deployment("Samba File Server", 1024, 1, 500, 14),
    Deployment("OpenVPN Server", 1024, 1, 2, 8),
    Deployment("MariaDB", 4096, 4, 50, 13),
    Deployment("Redis", 1024, 1, 1, 9),
    Deployment("Syncthing", 1024, 1, 5, 6),
    Deployment("Calibre-Web", 1536, 1, 20, 7),
    Deployment("MinIO", 4096, 4, 250, 12),
    Deployment("Portainer", 512, 1, 1, 8),
    Deployment("Traefik", 512, 1, 1, 9),
    Deployment("Zigbee2MQTT", 512, 1, 1, 5),
    Deployment("InfluxDB", 4096, 4, 30, 11),
    Deployment("PhotoStructure", 6144, 4, 200, 10),
    Deployment("FileBrowser", 1024, 1, 10, 6),
    Deployment("Wazuh Manager", 8192, 4, 30, 13),
}


@timeit
def knapsack(
    items: set[Deployment], capacity: tuple[float, float, float]
) -> tuple[int, set[Deployment]]:
    items_list = list(items)

    # different heuristics
    def score_memory(item: Deployment) -> float:
        return item.priority / (item.memory + 0.0001)

    def score_cpu(item: Deployment) -> float:
        return item.priority / (item.cpu + 0.0001)

    def score_storage(item: Deployment) -> float:
        return item.priority / (item.storage + 0.0001)

    def score_total(item: Deployment) -> float:
        return item.priority / (item.memory + item.cpu + item.storage + 0.0001)

    score_functions = [score_memory, score_cpu, score_storage, score_total]

    best_value = 0
    best_combination = set()

    with tqdm(
        total=len(score_functions) * len(items_list),
    ) as progress:
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

            # cross-check between different heuristics
            if total_value > best_value:
                best_value = total_value
                best_combination = set(chosen)

    return best_value, best_combination


@timeit
def knapsack_bf(
    items: set[Deployment], capacity: tuple[float, float, float]
) -> tuple[int, set[Deployment]]:
    best_value = 0
    best_combination = set()

    with tqdm(
        total=2 ** len(items),
    ) as progress:
        for r in range(len(items) + 1):
            for combination in itertools.combinations(items, r):
                logging.debug(
                    f"Trying combination: {', '.join([item.name for item in combination])}"
                )
                total_memory = sum(item.memory for item in combination)
                total_cpu = sum(item.cpu for item in combination)
                total_storage = sum(item.storage for item in combination)

                if all(
                    (
                        total_memory <= capacity[0],
                        total_cpu <= capacity[1],
                        total_storage <= capacity[2],
                    )
                ):
                    total_value = sum(item.priority for item in combination)
                    if total_value > best_value:
                        best_value = total_value
                        best_combination = combination

                progress.update(1)

    return best_value, best_combination


def run(alg_name, knapsack_func, items, capacity):
    print(f"Running {alg_name}")
    print("-" * (8 + len(alg_name)), end="\n\n")
    print(
        tabulate(
            [
                ["Set Size (n)", len(items)],
                ["Memory (MiB)", capacity[0]],
                ["CPU Cores", capacity[1]],
                ["Storage (GiB)", capacity[2]],
            ],
            tablefmt="grid",
        )
    )

    max_value, selected_items = knapsack_func(items, capacity)
    print(f"Max Value = {max_value}, Items = {selected_items}")
    print("\n\n")


def main():
    # MiB, CPU cores, GiB
    capacity = (16 * 1024, 4, 300)

    match sys.argv[1:2]:
        case ["bf"]:
            run("Brute Force", knapsack_bf, ITEMS, capacity)
        case ["greedy"]:
            run("Greedy", knapsack, ITEMS, capacity)
        case default:
            raise ValueError("Unknown algorithm %s" % default)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
