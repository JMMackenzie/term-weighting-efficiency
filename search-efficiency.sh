#!/bin/bash

echo "Running all algorithms across all collections, using both stopped and unstopped query logs for k = 1000..."
for algo in ranked_or maxscore wand block_max_wand; do 
  for collection in original-u original-p deepct-u deepct-p; do
    for query in unstopped stopped; do
  
      if [ "$collection" == "original-u" ] || [ "$collection" == "original-p" ]; then
        ./pisa/build/bin/queries --encoding block_simdbp \
                                 --index data/indexes/pisa-index/$collection".block_simdbp.idx" \
                                 --wand data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                 --terms data/indexes/pisa-canonical/$collection.termlex \
                                 --algorithm $algo \
                                 -k 1000 \
                                 --queries data/queries/$query".qry" \
                                 --scorer bm25 \
                                 --bm25-k1 0.82 \
                                 --bm25-b 0.68 \
                                 --extract | awk -v algo="$algo" -v collection="$collection" -v query="$query" '{print algo"\t"collection"\t"query"\t"$0}' >> timings/all.tsv

      elif [ "$collection" == "deepct-u" ] || [ "$collection" == "deepct-p" ]; then
        ./pisa/build/bin/queries --encoding block_simdbp \
                                 --index data/indexes/pisa-index/$collection".block_simdbp.idx" \
                                 --wand data/indexes/pisa-index/$collection.fixed-40.bm25.bmw \
                                 --terms data/indexes/pisa-canonical/$collection.termlex \
                                 --algorithm $algo \
                                 -k 1000 \
                                 --queries data/queries/$query".qry" \
                                 --scorer bm25 \
                                 --bm25-k1 8.0 \
                                 --bm25-b 0.90 \
                                 --extract | awk -v algo="$algo" -v collection="$collection" -v query="$query" '{print algo"\t"collection"\t"query"\t"$0}' >> timings/all.tsv

      fi
    done
  done
done
echo "Done."
