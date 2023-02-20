# EPA RMP Spreadsheets

🌐 [View on Google Sheets](TK)

This repository aims to create a simple set of spreadsheets extracted from [the EPA's Risk Management Program database, obtained by the Data Liberation Project via FOIA](https://docs.google.com/document/d/1jrLXtv0knnACiPXJ1ZRFXR1GaPWCHJWWjin4rsthFbQ/edit).

## Structure

### SQL

The [`sql/`](sql/) directory contains two files, each with SQLite commands:

- [`sql/views.sql`](sql/views.sql) defines a series of SQL views based on the raw data.
- [`sql/export.sql`](sql/export.sql) exports the top-level views (`Facilities`, `Submissions`, and `Accidents`) to CSV files in [`data/output/`](data/output/)

### Output files

The [`data/output/`](data/output/) directory contains three files, each the result of the SQL commands above:

- [`data/output/facilities.csv`](data/output/facilities.csv): One row per facility in the RMP database, providing its name, state, city, latest-listed owners/operator, number of submissions, date of latest RMP submission (by latest EPA-validation date), chemicals reported in latest submission, number of accidents reported in latest submission, and chemicals involved in those accidents.

- [`data/output/submissions.csv`](data/output/submissions.csv): One row per RMP submission (rather than one row per facility), with similar information as above.

- [`data/output/accidents.csv`](data/output/accidents.csv): One row per accident reported in a submission; due to reporting requirements, there can be duplications across submissions.

### Data dictionaries

The [`data/dictionaries/`](data/dictionaries/) directory contains a data dictionary for each of the output files, explaining the columns.

## Local Development

### Copy the main RMP SQLite files into `data/raw/`

- If the `data/raw/` directory does not already exist, create it.
- Download `RMPData.sqlite` and `RMPFac.sqlite` from [this Google Drive folder](https://drive.google.com/drive/folders/15mfQyTLvEywzQa_C0tBtWzrPE7ZawA7I).
- Copy those two files into `data/raw/`.

### Regenerate the data

`make data` will regenerate the output data from the SQL files above.

## Licensing

This repository's code is available under the [MIT License terms](https://opensource.org/license/mit/). The data files are available under Creative Commons' [CC BY-SA 4.0 license terms](https://creativecommons.org/licenses/by-sa/4.0/).


## Questions / suggestions?

File them as an issue in this repository or email Jeremy at jsvine@gmail.com. 
