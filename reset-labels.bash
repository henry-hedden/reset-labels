#!/bin/bash

# Reset issue labels to GitHub defaults

############################## Terminal Output ##############################

read -p "GitHub user: " USR
read -sp "GitHub password: " PASS
echo
read -p "GitHub repo: " REPO
URL="https://api.github.com/repos/$REPO/labels"
read -p "Are you sure you want to delete all labels in $REPO? (Y/N): " WARNING
if [[ $WARNING =~ ^[nN][oO]?$ ]]; then
  exit 0
fi

echo -e "\n\nDeleting old labels\n"
curl -su "$USR:$PASS" "$URL?page=1&per_page=100"  | jq -c .[] \
     | while read oldLabel; do
  oldName=$(echo $oldLabel | jq .name)
  oldUrl=$(echo $oldLabel | jq -r .url)
  echo Deleting old label $oldName...
  curl -su "$USR:$PASS" -X DELETE "$oldUrl" | jq
done

echo -e "\nCreating New Labels\n"
jq -c .[] < default-labels.json | while read label_data; do
  newName=$(echo $label_data | jq .name)
  newUrl=$(echo $label_data | jq -r .url)
  newData=$(echo $label_data | jq -c '{name, color, description}')
  echo Creating label $newName...
  curl -sH "Accept: application/vnd.github.symmetra-preview+json" \
       -u "$USR:$PASS" -X POST -d "$newData" "$URL" | jq
done

echo -e "\nDone\n"

