CREATE DATABASE IF NOT EXISTS drapp;

USE drapp;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users(name,email)
VALUES
('Kalyani','kalyani@test.com'),
('Admin','admin@test.com');