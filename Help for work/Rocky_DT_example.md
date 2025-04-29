for HOST in *
do
  cd "$HOST"
  SBOM="${HOST}_latest.json"
  echo ""
  echo -e "${YELLOW}RUN for [${HOST}]${NC}"
  if [[ -f "${SRC_DIR}${HOST}/tmp/installed_deb" ]]
  then
    SRC_NAME="${SRC_DIR}${HOST}/tmp/installed_deb"
    KEY="deb"
  elif [[ -f "${SRC_DIR}${HOST}/tmp/installed_rh" ]]
  then
    SRC_NAME="${SRC_DIR}${HOST}/tmp/installed_rh"
    KEY="rh"
  elif [[ -f "${SRC_DIR}${HOST}/tmp/installed_ubu" ]]
  then
    SRC_NAME="${SRC_DIR}${HOST}/tmp/installed_ubu"
    KEY="ubu"
  else
    echo -e "${RED}For ${HOST} packages file does not exists or has an invalid name${NC}"
    cd "$SRC_DIR"
    continue
  fi

  DST_NAME="${DST_DIR}${HOST}"
  mv "$SRC_NAME" "$DST_NAME"
  echo "Packages list for ${HOST} moved to /home/ksb/bom_gen/"
  cd /home/ksb/bom_gen/
  chmod 640 "$HOST"
  echo "Starting SBOM generation..."
  python3 bom_gen.py "$HOST" "$KEY"
  cd "${HOST}_dir/"
  echo "Starting SBOM uploading to DT..."
  curl -X "POST" "${API_URL}" \
       -H 'Content-Type: multipart/form-data' \
       -H 'X-Api-Key: тут ключик' \
       -F "autoCreate=true" \
       -F "projectName=${HOST}" \
       -F "bom=@${SBOM}"
  echo -e " - ${GREEN}SBOM uploaded to DT${NC}"
  cd "$SRC_DIR"
done