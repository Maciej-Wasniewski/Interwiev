CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_day DATE NOT NULL,
    CONSTRAINT check_birth_day CHECK (birth_day <= CURRENT_DATE)
);