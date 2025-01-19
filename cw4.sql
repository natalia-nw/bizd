--1
CREATE OR REPLACE FUNCTION get_job_name(job_id IN VARCHAR2)
RETURN VARCHAR2 IS
    job_name VARCHAR2(50);
BEGIN
    SELECT job_title INTO job_name FROM jobs WHERE job_id = job_id;
    RETURN job_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Job ID not found.');
END;

--2
CREATE OR REPLACE FUNCTION annual_salary(emp_id IN NUMBER)
RETURN NUMBER IS
    salary NUMBER;
    commission NUMBER;
BEGIN
    SELECT salary, NVL(commission_pct, 0) INTO salary, commission
    FROM employees WHERE employee_id = emp_id;
    RETURN (salary * 12) + (salary * commission);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee ID not found.');
END;

--3
CREATE OR REPLACE FUNCTION extract_area_code(phone_number IN VARCHAR2)
RETURN VARCHAR2 IS
    area_code VARCHAR2(10);
BEGIN
    area_code := REGEXP_SUBSTR(phone_number, '\((\d+)\)', 1, 1, NULL, 1);
    RETURN area_code;
END;

--4
CREATE OR REPLACE FUNCTION capitalize_first_last(input_str IN VARCHAR2)
RETURN VARCHAR2 IS
    result_str VARCHAR2(100);
BEGIN
    result_str := UPPER(SUBSTR(input_str, 1, 1)) || 
                  LOWER(SUBSTR(input_str, 2, LENGTH(input_str) - 2)) || 
                  UPPER(SUBSTR(input_str, -1, 1));
    RETURN result_str;
END;

--5 
CREATE OR REPLACE FUNCTION pesel_to_date(pesel IN VARCHAR2)
RETURN DATE IS
    birth_date DATE;
    year_part VARCHAR2(4);
    month_part VARCHAR2(2);
    day_part VARCHAR2(2);
BEGIN
    year_part := CASE
                    WHEN SUBSTR(pesel, 3, 1) IN ('2', '3') THEN '20' || SUBSTR(pesel, 1, 2)
                    ELSE '19' || SUBSTR(pesel, 1, 2)
                 END;
    month_part := TO_CHAR(MOD(SUBSTR(pesel, 3, 2), 20), '00');
    day_part := SUBSTR(pesel, 5, 2);
    birth_date := TO_DATE(year_part || '-' || month_part || '-' || day_part, 'YYYY-MM-DD');
    RETURN birth_date;
END;

--6
CREATE OR REPLACE FUNCTION employees_departments_in_country(country_name IN VARCHAR2)
RETURN VARCHAR2 IS
    emp_count NUMBER;
    dept_count NUMBER;
BEGIN
    SELECT COUNT(e.employee_id), COUNT(DISTINCT d.department_id)
    INTO emp_count, dept_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = country_name;
    RETURN 'Employees: ' || emp_count || ', Departments: ' || dept_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Country not found.');
END;



--1
CREATE TABLE archiwum_departmentow (
    id NUMBER,
    nazwa VARCHAR2(50),
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER archiwum_departmentow_trigger
AFTER DELETE ON departments
FOR EACH ROW
BEGIN
    INSERT INTO archiwum_departmentow VALUES (
        :OLD.department_id,
        :OLD.department_name,
        SYSDATE,
        (SELECT first_name || ' ' || last_name FROM employees WHERE employee_id = :OLD.manager_id)
    );
END;

--2
CREATE TABLE zlodziej (
    id NUMBER,
    username VARCHAR2(50),
    czas_zmiany DATE
);

CREATE OR REPLACE TRIGGER zlodziej_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary NOT BETWEEN 2000 AND 26000 THEN
        INSERT INTO zlodziej VALUES (:NEW.employee_id, USER, SYSDATE);
        RAISE_APPLICATION_ERROR(-20004, 'Salary out of range.');
    END IF;
END;

--3
CREATE SEQUENCE emp_seq START WITH 1000 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER emp_auto_increment
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.employee_id := emp_seq.NEXTVAL;
END;

--4
CREATE OR REPLACE TRIGGER prevent_job_grades_modification
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20005, 'Operation not allowed on JOB_GRADES table.');
END;

--5
CREATE OR REPLACE TRIGGER prevent_salary_change
BEFORE UPDATE ON jobs
FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;
