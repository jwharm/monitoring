#!/bin/bash
build=$(curl -s https://openqa.opensuse.org/group_overview/1.json | jq -e -r '[ .build_results[] | .build ][0]')

echo "Found build ${build}"

failed_jobs=$(curl -s "https://openqa.opensuse.org/tests/overview.json?distri=aeon&version=Tumbleweed&build=${build}&groupid=1" | \
jq -e -r '
  .results[][]?.Installer? 
  | .[][] 
  | select(type == "object") 
  | select(.overall == "failed")
  | "https://openqa.opensuse.org/tests/\(.jobid)"
')

if [[ ! -z "${failed_jobs[@]}" ]]; then
  echo "Failed jobs found:"
  for job in $failed_jobs; do
    echo -e "\t => ${job}"
  done
  exit 1
fi

