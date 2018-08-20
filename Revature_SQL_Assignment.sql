-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.

-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.

-- 2.1 SELECT
-- Task – Select all records from the Employee table.
	SELECT * FROM employee;

-- Task – Select all records from the Employee table where last name is King.
	SELECT * FROM employee WHERE lastname = 'King';

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
	SELECT * FROM employee WHERE firstname='Andrew' AND reportsto IS NULL;

-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
	SELECT * FROM album ORDER BY title DESC;

-- Task – Select first name from Customer and sort result set in ascending order by city
	SELECT firstname FROM customer ORDER BY city ASC;

-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
	INSERT INTO genre (genreid, name) VALUES (26, 'K-Pop');
	INSERT INTO genre (genreid, name) VALUES (27, 'Techno');

-- Task – Insert two new records into Employee table
	INSERT INTO employee (employeeid, lastname, firstname, title, email) VALUES (9, 'Pham', 'Kevin', 'Intern', 'kevin@fake.com');
	INSERT INTO employee (employeeid, lastname, firstname, title, email) VALUES (10, 'Orgoth', 'Jerry', 'Intern', 'jerry@fake.com');

-- Task – Insert two new records into Customer table
	INSERT INTO customer (customerid, firstname, lastname, email) VALUES (60, 'Kevin', 'Pham', 'kevin@fake.com');
	INSERT INTO customer (customerid, firstname, lastname, email) VALUES (61, 'Mary', 'Apple', 'mary@fake.com');

-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
	UPDATE customer SET firstname='Robert', lastname='Walter' WHERE firstname='Aaron' AND lastname='Mitchell';

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
	UPDATE artist SET name='CCR' WHERE name='Creedence Clearwater Revival';

-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
	SELECT * FROM invoice WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
	SELECT * FROM invoice WHERE total BETWEEN 15 AND 50;

-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
	SELECT * FROM employee WHERE hiredate BETWEEN '01/06/2003' AND '01/03/2004';

-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
	ALTER TABLE invoice
	DROP CONSTRAINT fk_invoicecustomerid,
	ADD CONSTRAINT fk_invoicecustomerid
	   FOREIGN KEY (customerid)
	   REFERENCES customer(customerid)
	   ON DELETE CASCADE;

	ALTER TABLE invoiceline
	DROP CONSTRAINT fk_invoicelineinvoiceid,
	ADD CONSTRAINT fk_invoicelineinvoiceidid
	   FOREIGN KEY (invoiceid)
	   REFERENCES invoice(invoiceid)
	   ON DELETE CASCADE;

	DELETE FROM customer
	WHERE firstname = 'Robert' and lastname = 'Walter';
-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database

-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
	CREATE OR REPLACE FUNCTION getTIME()
	RETURNS TIME AS $$
	BEGIN
		RETURN current_time;
	END;
	$$ LANGUAGE plpgsql

	SELECT getTIME();
-- Task – create a function that returns the length of a mediatype from the mediatype table
	CREATE OR REPLACE FUNCTION get_media_length()
	RETURNS INTEGER AS $$
	DECLARE
	lengths INTEGER;
	BEGIN
		SELECT length(name) INTO lengths FROM mediatype WHERE mediatypeid = 2;
		RETURN lengths;
	END;
	$$ LANGUAGE plpgsql;

	select get_media_length();

-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
	CREATE OR REPLACE FUNCTION get_average()
	RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(total) FROM invoice;
	END;
	$$ LANGUAGE plpgsql

	select get_average();

-- Task – Create a function that returns the most expensive track
	CREATE OR REPLACE FUNCTION get_expensive_track()
	RETURNS NUMERIC AS $$
	BEGIN
		RETURN MAX(unitprice) from track;
	END;
	$$ LANGUAGE plpgsql

	select get_expensive_track();

-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
	CREATE OR REPLACE FUNCTION get_average_unitprice()
	RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(unitprice) FROM invoiceline;
	END;
	$$ LANGUAGE plpgsql

	select get_average_unitprice();
	
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
	CREATE OR REPLACE FUNCTION employee_after1968()
	RETURNS refcursor AS $$
	DECLARE
		curs refcursor;
	BEGIN
		OPEN curs for SELECT firstname, birthdate FROM employee WHERE birthdate >= '1969-01-01 00:00:00';
		RETURN curs;
	END;
	$$ LANGUAGE plpgsql

	select employee_after1968();
	FETCH ALL IN "<unnamed portal 1>";

-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.

-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
	CREATE OR REPLACE FUNCTION get_employee_name()
	RETURNS refcursor AS $$
	DECLARE
		curs refcursor;
	BEGIN
		OPEN curs for SELECT firstname, lastname FROM employee;
		RETURN curs;
	END;
	$$ LANGUAGE plpgsql

	select get_employee_name();
	FETCH ALL IN "<unnamed portal 1>";

-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
	CREATE OR REPLACE FUNCTION update_employee_address(employee_id integer, street character)
	returns void AS $$
	BEGIN
		UPDATE employee SET address = street WHERE employeeid = employee_id;
	END;
	$$ language plpgsql

	SELECT update_employee_address(9,'235 gaitskell lane');

-- Task – Create a stored procedure that returns the managers of an employee.
	CREATE OR REPLACE FUNCTION get_employee_manager(fname character, lname character)
	RETURNS refcursor AS $$
	DECLARE
	curs refcursor;
	BEGIN
		OPEN curs for SELECT b.firstname, b.lastname from employee a, employee b 
			WHERE a.reportsto = b.employeeid AND a.firstname = fname AND a.lastname = lname;
		RETURN curs;
	END;
	$$ language plpgsql

	SELECT get_employee_manager('Laura', 'Callahan');
	FETCH ALL IN "<unnamed portal 1>";
	
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
	CREATE OR REPLACE FUNCTION customer_company(fname CHARACTER, lname CHARACTER)
	RETURNS refcursor AS $$
	DECLARE
		curs refcursor;
	BEGIN
		OPEN curs for select firstname, lastname, company from customer where firstname = fname and lastname = lname;
		RETURN curs;
	END;
	$$ LANGUAGE plpgsql

	SELECT customer_company('Eduardo', 'Martins');
	FETCH ALL IN "<unnamed portal 1>";

-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
	CREATE OR REPLACE FUNCTION delete_invoice(
		cust_id integer,
		fname character,
		lname character,
		input_email character
	)
	RETURNS void AS $$
	BEGIN
		INSERT INTO customer (customerid, firstname, lastname, email) VALUES (cust_id, fname, lname, input_email);
	END;
	$$ LANGUAGE plpgsql

	SELECT insert_customer(61,'Bryan', 'Pham', 'bryan@fake.com');

-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
	CREATE OR REPLACE FUNCTION insert_customer(
		cust_id integer,
		fname character,
		lname character,
		input_email character
	)
	RETURNS void AS $$
	BEGIN
		INSERT INTO customer (customerid, firstname, lastname, email) VALUES (cust_id, fname, lname, input_email);
	END;
	$$ LANGUAGE plpgsql

	SELECT insert_customer(61,'Bryan', 'Pham', 'bryan@fake.com');
	

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.

-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
	CREATE OR REPLACE FUNCTION new_employee()
	RETURNS	TRIGGER AS $$
	BEGIN
		RAISE NOTICE 'Inserted New Employee';
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER new_employee_trigger
	  AFTER INSERT ON employee FOR EACH ROW EXECUTE PROCEDURE new_employee();
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
	CREATE OR REPLACE FUNCTION new_album()
	RETURNS	TRIGGER AS $$
	BEGIN
		RAISE NOTICE 'Inserted New album';
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER new_album_trigger
	  AFTER INSERT ON album FOR EACH ROW EXECUTE PROCEDURE new_employee();
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
	CREATE OR REPLACE FUNCTION delete_customer()
	RETURNS	TRIGGER AS $$
	BEGIN
		RAISE NOTICE 'Deleted Customer';
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER delete_customer_trigger
	  AFTER INSERT
	  ON album FOR EACH ROW EXECUTE PROCEDURE delete_customer();
-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
	CREATE OR REPLACE FUNCTION restrict_deletion()
	RETURNS TRIGGER AS $$
	BEGIN
		IF invoice.price > 50 THEN
			RAISE NOTICE 'Cannot delete an invoice greater than $50';
			RETURN OLD;
		END IF;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER restrict_deletion_trigger
	BEFORE DELETE ON invoice FOR EACH ROW EXECUTE PROCEDURE restrict_deletion();
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.

-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
	SELECT firstname, invoiceid FROM customer LEFT JOIN invoice ON customer.customerid = invoice.customerid;

-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
	SELECT customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total FROM customer FULL JOIN invoice ON customer.customerid = invoice.customerid;

-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
	SELECT name, title FROM album RIGHT JOIN artist ON album.artistid = artist.artistid;

-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
	SELECT * FROM album CROSS JOIN artist ORDER BY artist.name ASC;

-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
	SELECT * FROM employee a, employee b WHERE a.reportsto = b.reportsto;