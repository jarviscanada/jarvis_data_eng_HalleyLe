# Introduction

This project aims to develop a SQL relational database for a newly established city club. The database comprises three key tables, housing data related to club members, facilities, and bookings. This database can be used to conduct data analysis through SQL queries to gain insights into customer dynamics and the demand for various facilities within the club.

The codes below illustrate how three tables are created in DDL (Data Definition Language), each with its attributes, data types and constraints, as well as specified primary keys and foreign keys to define their relationships. The following queries are examples of how the club can utilize data to answer business questions.

# SQL Queries

###### Table Setup (DDL)
```sql
CREATE TABLE cd.members (
    memid INT NOT NULL,
    surname VARCHAR(200) NOT NULL,
    firstname VARCHAR(200) NOT NULL,
    address VARCHAR(300) NOT NULL,
    zipcode INT NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    recommendedby INT,
    joindate TIMESTAMP NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT members_recommendedby_fk FOREIGN KEY (recommendedby) REFERENCES cd.members(memid) ON DELETE SET NULL 
);

CREATE TABLE cd.facilities (
    facid INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL,
    CONSTRAINT facs_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings (
    bookid INT NOT NULL,
    facid INT NOT NULL,
    memid INT NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INT NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (bookid),
    CONSTRAINT bookings_memid_fk FOREIGN KEY (memid) REFERENCES cd.members(memid),
    CONSTRAINT facs_facid_fk FOREIGN KEY (facid) REFERENCES cd.facilities(facid)
);
```

###### Question 1: 
Add a new spa into the `facilities` table.
```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);
```

###### Question 2: 
Add a new spa into the `facilities` table and automatically generate the value for the next `facid`, instead of specifying it as a constant.
```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT (SELECT MAX(facid) FROM cd.facilities) + 1, 'Spa', 20, 30, 100000, 800;
```

###### Question 3: 
Update the initial outlay of the second tennis court, which was 10000 rather than 8000.
```sql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```

###### Question 4:
Update the price of the second tennis court so that it costs 10% more than the first one.
```sql
UPDATE cd.facilities AS f
SET
    membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
    guestcost = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE f.facid = 1; 
```

###### Question 5:
Delete all bookings from the `cd.bookings` table.
```sql
DELETE FROM cd.bookings;
```

###### Question 6:
Remove member 37, who has never made a booking, from the `cd.members` table.
```sql
DELETE FROM cd.members
WHERE memid = 37;
```

###### Question 7:
Return facid, facility name, member cost, and monthly maintenance of the facilities  that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost.
```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND membercost < monthlymaintenance/50; 
```

###### Question 8:
Return a list of all facilities with the word 'Tennis' in their name.
```sql
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%'; 
```

###### Question 9:
Retrieve the details of facilities with ID 1 and 5 without using the `OR` operator.
```sql
SELECT *
FROM cd.facilities
WHERE facid IN (1,5);
```

###### Question 10:
Return the memid, surname, firstname, and joindate of the members who joined after the start of September 2012.
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-08-31'; 
```

###### Question 11:
Create a combined list of all surnames and all facility names.
```sql
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities; 
```

###### Question 12:
Return a list of the start times for bookings by members named 'David Farrell'.
```sql
SELECT starttime
FROM cd.members AS m
LEFT JOIN cd.bookings AS b
ON m.memid = b.memid
WHERE firstname = 'David' AND surname = 'Farrell'; 
```

###### Question 13:
Return a list of start time and facility name pairings for the date '2012-09-21', ordered by the time.
```sql
SELECT b.starttime AS start, f.name AS name
FROM cd.bookings AS b
LEFT JOIN cd.facilities AS f
ON b.facid = f.facid
WHERE f.name IN ('Tennis Court 1', 'Tennis Court 2') AND
    b.starttime >= '2012-09-21' AND
    b.starttime < '2012-09-22'
ORDER BY b.starttime;
```

###### Question 14:
Return a list of all members, including the individual who recommended them (if any).
```sql
SELECT m1.firstname AS memfname,
       m1.surname AS memsname,
       m2.firstname AS recfname,
       m2.surname AS recsname
FROM cd.members AS m1
LEFT JOIN cd.members AS m2
ON m2.memid = m1.recommendedby
ORDER BY m1.surname, m1.firstname
```

###### Question 15:
Return a list of all members who have recommended another member with no duplicates in the list. Order the result by surname and firstname.
```sql
SELECT m2.firstname AS firstname, m2.surname AS surname
FROM (
    SELECT DISTINCT(recommendedby)
    FROM cd.members AS m1
    WHERE m1.recommendedby IS NOT NULL
    ) AS m1
LEFT JOIN cd.members AS m2
ON m1.recommendedby = m2.memid
ORDER BY surname, firstname;
```

###### Question 16:
Return  a list of all members, including the individual who recommended them (if any), without using any joins and no duplicates.
```sql
SELECT DISTINCT(mem.firstname || ' ' || mem.surname) AS member,
    (SELECT ref.firstname || ' ' || ref.surname AS recommender
    FROM cd.members AS ref
    WHERE mem.recommendedby = ref.memid)
FROM cd.members AS mem
ORDER BY member; 
```

###### Question 17:
Return a count of the number of recommendations each member has made, ordered by member ID.
```sql
SELECT recommendedby, COUNT(recommendedby) AS count
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

###### Question 18:
Return a list of facility id with corresponding slots booked, ordered by facility id.
```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

###### Question 19:
Return a list of facility id with corresponding slots booked in September 2012, sorted by the number of slots.
```sql
SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);
```

###### Question 20:
Return a list of facility id with corresponding slots booked per month in 2012, sorted by the id and month
```sql
SELECT facid, EXTRACT(MONTH FROM starttime) AS month, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, month
ORDER BY facid, month
```

###### Question 21:
Print the total number of members (including guests) who have made at least one booking.
```sql
SELECT COUNT(DISTINCT memid)
FROM cd.bookings;
```

###### Question 22:
Produce a list of each member name, id, and their first booking after September 1st 2012, ordered by member ID.
```sql
SELECT DISTINCT m.surname, m.firstname, m.memid, MIN(b.starttime)
FROM cd.members AS m
LEFT JOIN cd.bookings AS b
ON m.memid = b.memid
WHERE b.starttime >= '2012-09-01'
GROUP BY m.memid
ORDER BY m.memid;
```

###### Question 23:
Return a list of all member names, with each row containing the total member count, ordered by join date..
```sql
SELECT COUNT(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;
```

###### Question 24:
Create an increasing numbered list of members (including guests), ordered by join date.
```sql
SELECT ROW_NUMBER() OVER (ORDER BY joindate),
    firstname, surname
FROM cd.members;
```

###### Question 25:
Display the facility id that has the highest number of slots booked.
```sql
SELECT facid, SUM(slots) AS total
FROM cd.bookings
GROUP BY facid
ORDER BY total DESC
LIMIT 1
```

###### Question 26:
Display the names of all members, formatted as 'Surname, Firstname'.
```sql
SELECT surname || ', ' || firstname
FROM cd.members;
```

###### Question 27:
Return all the member ID and telephone number that contain parentheses, sorted by member ID.
```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone ~ '[()]';
```

###### Question 28:
Count the number of members whose surname starts with each letter of the alphabet, sorted by the letter.
```sql
SELECT SUBSTRING(surname,1,1) AS letter, COUNT(*)
FROM cd.members
GROUP BY letter
ORDER BY letter;
```
EOF
