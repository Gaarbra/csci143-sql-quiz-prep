-- DataLemur example rows (from each problem page)
CREATE TABLE pages (page_id INTEGER, page_name TEXT);
INSERT INTO pages VALUES (20001, 'SQL Solutions'), (20045, 'Brain Exercises'), (20701, 'Tips for Data Analysts');
CREATE TABLE page_likes (user_id INTEGER, page_id INTEGER, liked_date TIMESTAMP);
INSERT INTO page_likes VALUES (111, 20001, '2022-04-08 00:00:00'), (121, 20045, '2022-03-12 00:00:00'), (156, 20001, '2022-07-25 00:00:00');
CREATE TABLE viewership (user_id INTEGER, device_type TEXT, view_time TIMESTAMP);
INSERT INTO viewership VALUES (123, 'tablet', '2022-01-02 00:00:00'), (125, 'laptop', '2022-01-07 00:00:00'), (128, 'laptop', '2022-02-09 00:00:00'), (129, 'phone', '2022-02-09 00:00:00'), (145, 'tablet', '2022-02-24 00:00:00');
CREATE TABLE transactions (user_id INTEGER, spend REAL, transaction_date TIMESTAMP);
INSERT INTO transactions VALUES (111, 100.50, '2022-01-08 12:00:00'), (111, 55.00, '2022-01-10 12:00:00'), (121, 36.00, '2022-01-18 12:00:00'), (145, 24.99, '2022-01-26 12:00:00'), (111, 89.60, '2022-02-05 12:00:00');
CREATE TABLE tweets (tweet_id INTEGER, user_id INTEGER, msg TEXT, tweet_date TIMESTAMP);
INSERT INTO tweets VALUES (214252, 111, 'Am considering taking Tesla private at $420.', '2021-12-30 00:00:00'), (739252, 111, 'Despite the constant negative press covfefe', '2022-01-01 00:00:00'), (846402, 111, 'Following @NickSinghTech on Twitter changed my life!', '2022-02-14 00:00:00'), (241425, 254, 'If the salary is so competitive why won''t you tell me what it is?', '2022-03-01 00:00:00'), (231574, 148, 'I no longer have a manager. I can''t be managed', '2022-03-23 00:00:00');
