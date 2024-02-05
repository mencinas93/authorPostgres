DROP TABLE IF EXISTS AuthorBookRelation CASCADE;
DROP TABLE IF EXISTS PublisherBookRelation CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS AuthorWithAgent CASCADE;
DROP TABLE IF EXISTS Author CASCADE;
DROP TABLE IF EXISTS Publisher CASCADE;

CREATE SCHEMA plain_relational;
CREATE SCHEMA extended_relational;
CREATE SCHEMA xml_json;

SET search_path TO plain_relational;


Create Table Publisher (
    publisher_name varchar(30) Primary key,
    address varchar(60) not null,
    country varchar(30) not null,
    CEO varchar(30) not null
);

Create Table Author(
    Author_ID integer Primary key,
    name Varchar(30) not null,
    age integer not null,
    country  varchar(30) not null
);

Create table AuthorWithAgent (
    Author_ID integer Primary key references Author(Author_ID),
    agent_name varchar(30) not null
);

Create table Book(
    isbn char(10) primary key,
    title varchar(30) not null,
    price double precision not null,
    year integer not null,
    publisher_name varchar(30),
    Foreign key (publisher_name) references Publisher(publisher_name)
);

Create table AuthorBookRelation(
    Author_ID integer references Author(Author_ID),
    Book_ISBN char(10) references book(isbn),
    primary key (Author_ID, Book_ISBN)
);

Create table PublisherBookRelation (
    publisher_name varchar(30) references Publisher(publisher_name),
    Book_ISBN char(10) references book(isbn),
    primary key (publisher_name, Book_ISBN)
);

SET search_path TO plain_relational;

INSERT INTO Publisher (publisher_name, address, country, CEO)
VALUES
    ('Learning Center', '760 Everton Street', 'USA', 'Sarah Encinas'),
    ('Book4Ever', '1200 Michigan Street', 'USA', 'Juan Martinez');

INSERT INTO Author (author_id, name, age, country)
VALUES
    (1, 'Sarah J. Maas', 30, 'USA'),
    (2, 'Rebecca Yarros', 24, 'USA'),
    (3, 'Stephen King', 35, 'Canada'),
    (4, 'John Jones', 57, 'USA'),
    (5, 'Michael Ellison', 68, 'USA');

INSERT INTO AuthorWithAgent (Author_ID, agent_name)
VALUES
    (1, 'James Madison'),
    (2, 'Angela Gallegos'),
    (3, 'Davonte Smith');


INSERT INTO Book (isbn, title, price, year, publisher_name)
VALUES
    ('1020011893', 'A Court of Thorns and Roses', 30.99, 2023, 'Learning Center'),
    ('1020011894', 'Iron Flame', 25.99, 2015, 'Book4Ever'),
    ('1020011895', 'Forth Wing', 27.99, 1998, 'Learning Center'),
    ('1020011896', 'Cresant City', 40.99, 2024, 'Book4Ever'),
    ('1020011897', 'Earth Dome', 41.99, 2017, 'Book4Ever');



INSERT INTO AuthorBookRelation (Author_ID, Book_ISBN)
VALUES
    (1, '1020011893'),
    (2, '1020011894'),
    (3, '1020011895'),
    (1, '1020011896'),
    (4, '1020011897'),
    (5, '1020011897');


INSERT INTO PublisherBookRelation (publisher_name, Book_ISBN)
VALUES
    ('Learning Center', '1020011893'),
    ('Book4Ever', '1020011894'),
    ('Learning Center', '1020011895'),
    ('Book4Ever', '1020011896'),
    ('Book4Ever', '1020011897');

SET search_path TO extended_relational;

CREATE TABLE all_data (
    id serial PRIMARY KEY,
    table_name VARCHAR(40) NOT NULL,
    author_name VARCHAR(30),
    age INTEGER,
    country VARCHAR(30),
    agent_name VARCHAR(30),
    address VARCHAR(60),
    CEO VARCHAR(30),
    isbn CHAR(10),
    title VARCHAR(30),
    price DOUBLE PRECISION,
    year INTEGER,
    publisher_name VARCHAR(30),
    author_id INTEGER,
    book_isbn CHAR(10),
    FOREIGN KEY (author_id) REFERENCES plain_relational.Author(Author_ID),
    FOREIGN KEY (book_isbn) REFERENCES plain_relational.Book(isbn)
);

SET search_path TO extended_relational;

INSERT INTO all_data (table_name,  publisher_name, address, country, CEO)
SELECT 'Publisher',  publisher_name, address, country, CEO FROM plain_relational.Publisher;



INSERT INTO all_data (table_name, author_id, author_name, age, country)
SELECT 'Author', author_id, name, age, country FROM plain_relational.author;


INSERT INTO all_data (table_name, author_name, age, country, agent_name)
SELECT 'AuthorWithAgent', A.name, A.age, A.country, AW.agent_name
FROM plain_relational.AuthorWithAgent AS AW
JOIN plain_relational.Author AS A ON AW.Author_ID = A.Author_ID;


INSERT INTO all_data (table_name, title, price, year, publisher_name, Book_ISBN)
SELECT 'Book', title, price, year, publisher_name, isbn FROM plain_relational.Book;


INSERT INTO all_data (table_name, Author_ID, Book_ISBN)
SELECT 'AuthorBookRelation', Author_ID, Book_ISBN FROM plain_relational.AuthorBookRelation;

INSERT INTO all_data (table_name, publisher_name, book_isbn)
SELECT 'PublisherBookRelation', publisher_name, Book_isbn FROM plain_relational.PublisherBookRelation;

SET search_path TO xml_json;

CREATE TABLE json_data (
    id serial PRIMARY KEY,
    data JSONB
);

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'publisher_name', publisher_name,
        'address', address,
        'country', country,
        'CEO', CEO
    ) AS data
FROM plain_relational.Publisher;

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'author_id', author_id,
        'name', name,
        'age', age,
        'country', country
    ) AS data
FROM plain_relational.author;

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'author_id', author_id,
        'agent_name', agent_name
    ) AS data
FROM plain_relational.AuthorWithAgent;

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'isbn', isbn,
        'title', title,
        'price', price,
        'year', year,
        'publisher_name', publisher_name
    ) AS data
FROM plain_relational.Book;

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'Author_ID', Author_ID,
        'Book_ISBN', Book_ISBN
    ) AS data
FROM plain_relational.AuthorBookRelation;

INSERT INTO json_data (data)
SELECT 
    jsonb_build_object(
        'publisher_name', publisher_name,
        'Book_ISBN', Book_ISBN
    ) AS data
FROM plain_relational.PublisherBookRelation;

Select A.name as author_name,
    avg(Book.price) AS Average_Book_Price,
    AW.agent_name
From plain_relational.Author as A
Join plain_relational.AuthorBookRelation AS ABR on 
A.Author_ID = ABR.Author_ID
Join plain_relational.Book as Book on ABR.Book_ISBN = book.isbn
left Join
    plain_relational.AuthorWithAgent as AW on A.Author_ID = AW.author_Id
group by 
    A.Author_ID, AW.agent_name;

SELECT
    B.title AS book_title,
    COUNT(A.Author_ID) AS number_of_authors_under_25
FROM
    plain_relational.Book AS B
JOIN
    plain_relational.AuthorBookRelation AS ABR ON B.isbn = ABR.Book_ISBN
JOIN
    plain_relational.Author AS A ON ABR.Author_ID = A.Author_ID
WHERE
    A.age < 25
GROUP BY
    B.title;


SELECT
    P.publisher_name as publisher_name_for_2015_Publish,
    B.title AS book_title
FROM
    plain_relational.Publisher AS P
JOIN
    plain_relational.Book AS B ON P.publisher_name = B.publisher_name
WHERE
    B.year = 2015;


SELECT DISTINCT
    A1.name AS author1_name,
    A2.name AS author2_name
FROM
    plain_relational.AuthorBookRelation AS ABR1
JOIN
    plain_relational.Author AS A1 ON ABR1.Author_ID = A1.Author_ID
JOIN
    plain_relational.AuthorBookRelation AS ABR2 ON ABR1.Book_ISBN = ABR2.Book_ISBN
JOIN
    plain_relational.Author AS A2 ON ABR2.Author_ID = A2.Author_ID
WHERE
    A1.Author_ID < A2.Author_ID;


/* extended relational */


SELECT 
    A.author_name,
    AVG(B.price) AS average_book_price,
	AW.agent_name
FROM 
    extended_relational.all_data A
LEFT JOIN
    extended_relational.all_data AB ON A.author_id = AB.author_id AND AB.table_name = 'AuthorBookRelation'
LEFT JOIN
    extended_relational.all_data B ON AB.book_isbn = B.book_isbn AND B.table_name = 'Book'
LEFT JOIN
    extended_relational.all_data AW ON A.author_name = AW.author_name AND AW.table_name = 'AuthorWithAgent'
WHERE 
    A.table_name = 'Author'
GROUP BY
    A.author_name,  AW.agent_name;


SELECT
    B.title AS book_title,
    COUNT(A.Author_ID) AS number_of_authors_under_25
FROM
    extended_relational.all_data ABR
JOIN
    extended_relational.all_data A ON ABR.author_id = A.author_id AND A.table_name = 'Author'
JOIN
    extended_relational.all_data B ON ABR.book_isbn = B.book_isbn AND B.table_name = 'Book'
WHERE
    A.age < 25
GROUP BY
    B.title;


SELECT
    PBR.publisher_name,
    B.title AS book_title_in_2015
FROM
    extended_relational.all_data B
JOIN
    extended_relational.all_data PBR ON B.publisher_name = PBR.publisher_name AND PBR.table_name = 'Publisher'
WHERE
    B.year = 2015;



SELECT DISTINCT
    A1.author_name AS author1_name,
    A2.author_name AS author2_name
FROM
    extended_relational.all_data AS ABR1
JOIN
    extended_relational.all_data AS ABR2 ON ABR1.book_isbn = ABR2.book_isbn AND ABR1.author_id < ABR2.author_id
JOIN
    extended_relational.all_data AS A1 ON ABR1.author_id = A1.author_id AND A1.table_name = 'Author'
JOIN
    extended_relational.all_data AS A2 ON ABR2.author_id = A2.author_id AND A2.table_name = 'Author'
WHERE
    ABR1.table_name = 'AuthorBookRelation'
    AND ABR2.table_name = 'AuthorBookRelation';

