#!/bin/bash

echo "Converting TREC runs into MARCO format..."
bash ./tools/trec-to-marco.sh run-files

TREC_EVAL=../anserini/eval/trec_eval.9.0.4/trec_eval
MARCO_EVAL=../anserini/src/main/python/msmarco/msmarco_eval.py
for file in run-files/*.trec; do

  echo "======================"
  echo "$file"
  echo "======================"
  $TREC_EVAL qrels/qrels.dev.small.tsv -m recall.1000 -m map $file
  python3 $MARCO_EVAL qrels/qrels.dev.small.tsv $file".marco"
  echo ""

done
