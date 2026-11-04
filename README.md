# CSCI143 SQL quiz prep

Interactive prep for Mike Izbicki's CSCI143 SQL quizzes (topics 04 to 06 and the `sql_quiz` repo). Every query runs live on **real Postgres and real SQLite side by side** in your browser, so you can check a hand-trace against both engines and see exactly where they disagree.

## Open it

Download `index.html` and open it in Chrome, Firefox or Safari. It needs an internet connection the first time, to download the two engines (about 4 MB) from jsDelivr:

- [PGlite](https://pglite.dev): Postgres 18 compiled to WebAssembly
- [sql.js](https://sql.js.org): SQLite compiled to WebAssembly

Nothing you type is sent anywhere. To host it, turn on GitHub Pages for this repo (Settings, Pages, deploy from the `main` branch root) and open the link it gives you.

## What's inside

| Part | What you can do |
| --- | --- |
| The tables you're given | His `create_tables.sql` code for quizzes 1 and 2, exactly as it appears on the quiz, with live grids |
| Postgres vs SQLite | Every difference that changes a quiz answer; click a row to run its example on both engines |
| How a query runs | Step through FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY and watch which rows survive each line |
| Join explorer | Pick tables and a join type (cross, inner, left, right, full); hover a row to see its partners; the count explains itself |
| Anti-join explorer | Trace each session row through NOT IN, NOT EXISTS, LEFT JOIN ... IS NULL and IN, and see why one NULL returns 0 rows |
| Recursive CTE explorer | Pick a seed message, walk up or down the conversation tree round by round, and compare UNION with UNION ALL |
| Window playground | Running sums (RANGE vs ROWS), PARTITION BY, row_number, rank, dense_rank, lag, lead and frames |
| Byte calculator (Quiz 3) | Edit columns, types and values; see the Postgres layout with padding and the SQLite record size, then check against real Postgres |
| DataLemur walkthroughs | Page With No Likes, Laptop vs Mobile, Histogram of Tweets and User's Third Transaction, traced step by step on their example data |
| Practice tracker | 49 free DataLemur and LeetCode problems grouped by quiz pattern, with tick boxes saved in your browser |

Every editable example also has a Ctrl+Enter shortcut, and **Reset tables** rebuilds everything from his CREATE TABLE code if you change the data.

## Files

```
index.html                         the interactive guide (one self-contained file)
practice.md                        the practice list as a checklist
sql/quiz1_create_tables.sql        his quiz 1 tables (basket_a, basket_b)
sql/quiz2_create_tables.sql        his quiz 2 tables (session, message, price)
sql/datalemur_example_tables.sql   DataLemur example rows used in the walkthroughs
sql/examples.sql                   every example from index.html with the real output from psql and sqlite3
```

To run the examples outside the browser:

```sh
cd sql
psql -f quiz1_create_tables.sql -f quiz2_create_tables.sql -f datalemur_example_tables.sql
cat quiz1_create_tables.sql quiz2_create_tables.sql datalemur_example_tables.sql | sqlite3 prep.db
```

Or use the docker-compose setups in his repo (`quiz1/`, `quiz2/` on the `quiz3` branch of `mikeizbicki/sql_quiz`), which start both engines.

## How it was checked

Every query output on the page was run on native Postgres 16 and SQLite 3.45 as well as on the in-browser engines, and they agree. The join, anti-join and recursive explorers compute their counts in the page; each of their combinations (20 joins, 8 anti-joins, 76 recursive walks) was checked against both engines. The byte calculator's six presets match `pg_column_size` in Postgres and `dbstat` in sqlite3.

## Sources

- [mikeizbicki/cmc-csci143](https://github.com/mikeizbicki/cmc-csci143), topics 04 (SQL I), 05 (SQL II) and 06 (schema design)
- [mikeizbicki/sql_quiz](https://github.com/mikeizbicki/sql_quiz), branches `quiz1`, `quiz2` and `quiz3`
- DataLemur problem pages for the example rows
