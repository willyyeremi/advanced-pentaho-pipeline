#!/bin/bash

# Argumen pertama adalah path repo
REPO_PATH="$1"

# Argumen kedua: nama source/table untuk test (contoh: raw.customer_dim)
TARGET_SOURCE="$2"

# Pindah ke folder dbt_test
cd "$REPO_PATH/dbt_test"

# Aktifkan virtual environment
# . (source) wajib supaya environment tetap di shell ini
source "./venv/Scripts/activate"

# Jalankan dbt test
dbt test --select "source:$TARGET_SOURCE"