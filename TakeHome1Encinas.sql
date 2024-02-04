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
    (2, 'Rebecca Yarros', 25, 'USA'),
    (3, 'Stephen King', 35, 'Canada');

INSERT INTO AuthorWithAgent (Author_ID, agent_name)
VALUES
    (1, 'James Madison'),
    (2, 'Angela Gallegos'),
    (3, 'Davonte Smith');


INSERT INTO Book (isbn, title, price, year, publisher_name)
VALUES
    ('1020011893', 'A Court of Thorns and Roses', 30.99, 2023, 'Learning Center'),
    ('1020011894', 'Iron Flame', 25.99, 2013, 'Book4Ever'),
    ('1020011895', 'Forth Wing', 27.99, 1998, 'Learning Center'),
    ('1020011896', 'Cresant City', 40.99, 2024, 'Book4Ever');



INSERT INTO AuthorBookRelation (Author_ID, Book_ISBN)
VALUES
    (1, '1020011893'),
    (2, '1020011894'),
    (3, '1020011895'),
    (1, '1020011896');


INSERT INTO PublisherBookRelation (publisher_name, Book_ISBN)
VALUES
    ('Learning Center', '1020011893'),
    ('Book4Ever', '1020011894'),
    ('Learning Center', '1020011895'),
    ('Book4Ever', '1020011896');

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
