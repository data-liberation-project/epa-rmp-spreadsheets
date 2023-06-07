.read sql/views.sql
.headers on
.mode csv

.output data/output/facilities.csv
SELECT * FROM Facilities;

.output data/output/submissions.csv
SELECT * FROM Submissions;

.output data/output/accidents.csv
SELECT * FROM Accidents;

.output data/output/accidents-with-duplicates.csv
SELECT * FROM AccidentEntries;

.output data/output/naics-codes.csv
SELECT
    NAICS_CODE AS NAICSCode,
    NAICS_DESCRIPTION AS Description
FROM tlkpNAICS;
