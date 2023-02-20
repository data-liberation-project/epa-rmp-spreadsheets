.read sql/views.sql
.headers on
.mode csv

.output data/output/facilities.csv
SELECT * FROM Facilities;

.output data/output/submissions.csv
SELECT * FROM Submissions;

.output data/output/accidents.csv
SELECT * FROM Accidents;
