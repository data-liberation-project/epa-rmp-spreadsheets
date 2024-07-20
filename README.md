# EPA RMP Spreadsheets

🌐 [View on Google Sheets](https://docs.google.com/spreadsheets/d/170UIeg_sweeqGWVQrjHWY-HNRqEPE9axbEroSEr4C3M/edit)

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

- [`data/output/accidents.csv`](data/output/accidents.csv): One row per accident reported, *with obvious duplicates removed*. Due to reporting requirements, facilities may report the same accident in multiple submissions over time. This causes duplicate accidents to appear in the raw data.
    - The Data Liberation Project has attempted to remove these duplicates, using a simple rule: If two accidents are reported in the same submission, they are *not duplicates* of one another; otherwise, all reports of accidents on the *same day at the same facility* are considered to reference the same event, and only the most recent submission’s version of the accident report is retained.
    - Cross-checking the results against [public accounting by the EPA](https://www.regulations.gov/document/EPA-HQ-OLEM-2022-0174-0065), and spot-checking the results internally, suggests that this is a robust approach. Weaknesses include potentially double-counting (a) accidents for which a facility has changed the date between submissions, (b) accidents that a facility has reported twice in the same submission (of which there appear to be just one or two likely instances).

- [`data/output/accidents-with-duplicates.csv`](data/output/accidents-with-duplicates.csv): One row per accident listed in the raw data, *including duplicates* (see note directly above).

### Data dictionaries

The [`data/dictionaries/`](data/dictionaries/) directory contains a data dictionary for each of the output files, explaining the columns.

### Changes files

The [`data/changes/`](data/changes/) directory contains one subdirectory per RMP data-update, with each subdirectory named `YYYY-MM` after the year and month of the Data Liberation Project received the updated data from the EPA.

Each subdirectory contains one file per file in the `data/output/` directory, but suffixed with `.json` instead of `.csv`. Each of these JSON files contains the output of `csv-diff --json old-file.csv new-file.csv --id [...]`, run using the [`csv-diff`](https://github.com/simonw/csv-diff) command-line tool. (See the [`Makefile`](Makefile) for specifics.) They indicate the rows added, removed, and changed between the older and newer data.

## Local Development

### Copy the RMP SQLite file into `data/raw/`

- If the `data/raw/` directory does not already exist, create it.
- Download `RMPData.sqlite` from [this Google Drive folder](https://drive.google.com/drive/folders/1TtbkJ_OFHTiJa6GPedTma3fR6im-6xHX).
- Copy or move that file into `data/raw/`.


### Regenerate the data

`make data` will regenerate the output data from the SQL files above.

## Licensing

This repository's code is available under the [MIT License terms](https://opensource.org/license/mit/). The data files are available under Creative Commons' [CC BY-SA 4.0 license terms](https://creativecommons.org/licenses/by-sa/4.0/).


## Questions / suggestions?

File them as an issue in this repository or email Jeremy at jsvine@gmail.com. 
