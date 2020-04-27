from collections import defaultdict
import sys

timing_data = defaultdict(list)
with open(sys.argv[1]) as f:
  for line in f:
    data = line.strip().split("\t")
    # Skip headers
    if data[3] == "qid" and data[4] == "usec":
      continue
    key = " ".join(x for x in data[0:3])
    timing_data[key].append(float(0.001 * int(data[4])))

for key in timing_data:
  data = sorted(timing_data[key])
  median = data[int(len(data)/2)]
  mean = sum(data) / len(data)
  p99 = data[int(99 * len(data) / 100)]
  print(key + ",mean," + str(mean))
  print(key + ",median," + str(median))
  print(key + ",p99," + str(p99))

