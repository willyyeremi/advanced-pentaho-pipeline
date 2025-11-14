@echo off

@REM Argumen pertama adalah path repo
set "REPO_PATH=%~1"

REM Argumen kedua adalah nama source/table untuk test
set "TARGET_SOURCE=%~2"

@REM Pindah ke folder dbt_test
cd /d "%REPO_PATH%\dbt_test"

@REM Aktifkan virtual environment
call "venv\Scripts\activate.bat"

@REM Jalankan DBT Test
dbt test --select "source:%TARGET_SOURCE%"