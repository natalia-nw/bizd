CREATE TABLE REGIONS(region_id INT PRIMARY KEY, region_name VARCHAR(50) NOT NULL);

CREATE TABLE COUNTRIES(country_id INT PRIMARY KEY, country_name VARCHAR(50) NOT NULL, 
region_id INT, FOREIGN KEY(region_id) REFERENCES REGIONS(region_id) ON DELETE CASCADE);

CREATE TABLE LOCATIONS(location_id INT PRIMARY KEY, street_adress VARCHAR(50) NOT NULL,
postal_code VARCHAR(50) NOT NULL, city VARCHAR(50) NOT NULL, state_province VARCHAR(50), 
country_id INT, FOREIGN KEY(country_id) REFERENCES COUNTRIES(country_id) ON DELETE CASCADE);

CREATE TABLE DEPARTMENTS(department_id INT PRIMARY KEY, department_name VARCHAR(50) NOT NULL,
manager_id INT, location_id INT, FOREIGN KEY(location_id) REFERENCES LOCATIONS(location_id) ON DELETE CASCADE);

CREATE TABLE JOB_HISTORY(employee_id INT NOT NULL, start_date DATE NOT NULL, 
end_date DATE, job_id INT, department_id INT, 
FOREIGN KEY(department_id) REFERENCES DEPARTMENTS(department_id) ON DELETE CASCADE,
CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date));

CREATE TABLE JOBS(job_id INT PRIMARY KEY, job_title VARCHAR(50) NOT NULL, 
min_salary DECIMAL(10,2), max_salary DECIMAL(10,2));

CREATE TABLE EMPLOYEES(employee_id INT PRIMARY KEY, first_name VARCHAR(50), 
last_name VARCHAR(50), email VARCHAR(50), phone_number VARCHAR(50), hire_date DATE, 
job_id INT, FOREIGN KEY(job_id) REFERENCES JOBS(job_id) ON DELETE CASCADE, 
salary INT, commission_pct VARCHAR(50), manager_id INT, department_id INT);

ALTER TABLE JOB_HISTORY ADD FOREIGN KEY (job_id) REFERENCES JOBS(job_id) ON DELETE CASCADE;

ALTER TABLE EMPLOYEES ADD FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id) ON DELETE CASCADE;

ALTER TABLE EMPLOYEES ADD FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id) ON DELETE CASCADE;

ALTER TABLE DEPARTMENTS ADD FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id);

ALTER TABLE JOBS ADD CONSTRAINT chk_salary CHECK (max_salary >= min_salary+2000);
