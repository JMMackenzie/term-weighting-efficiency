#!/bin/bash

for f in $1/*; do
  awk -F"	" '{print $1"	"$3"	"$4+1}' $f > $f".marco"
done
