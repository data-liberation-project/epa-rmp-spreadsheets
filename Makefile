.PHONY: data changes
SHELL := /bin/bash

data:
	sqlite3 < sql/export.sql

changes:
ifndef CHANGES_SUBDIR
	# Should be set to data/changes/YYYY-MM
	$(error CHANGES_SUBDIR is undefined)
endif
	csv-diff <(git show HEAD:data/output/facilities.csv) data/output/facilities.csv --key EPAFacilityID --json > $(CHANGES_SUBDIR)/facilities.json
	csv-diff <(git show HEAD:data/output/submissions.csv) data/output/submissions.csv --key SubmissionID --json > $(CHANGES_SUBDIR)/submissions.json
	csv-diff <(git show HEAD:data/output/accidents.csv) data/output/accidents.csv --key AccidentHistoryID --json > $(CHANGES_SUBDIR)/accidents.json
	csv-diff <(git show HEAD:data/output/accidents-with-duplicates.csv) data/output/accidents-with-duplicates.csv --key AccidentHistoryID --json > $(CHANGES_SUBDIR)/accidents-with-duplicates.json
	csv-diff <(git show HEAD:data/output/naics-codes.csv) data/output/naics-codes.csv --key NAICSCode --json > $(CHANGES_SUBDIR)/naics-codes.json
