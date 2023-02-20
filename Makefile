.PHONY: data

data:
	sqlite3 < sql/export.sql
