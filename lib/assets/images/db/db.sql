CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    membername VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    postition VARCHAR(50),
    memberaddress TEXT,
    dateofbirth DATE,
    occupation VARCHAR(50),
    otherskills TEXT,
    profilepicture VARCHAR(255),
    emergencycontactname VARCHAR(100),
    emergencycontactphone VARCHAR(20),
    emergencycontactrelationship VARCHAR(50),
    join_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES members(id),
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50),
    assessment VARCHAR(50) REFERENCES assessment(description),
);

CREATE TABLE IF NOT EXISTS assessment (
    id SERIAL PRIMARY KEY,
    description VRCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
);

CREATE TABLE IF NOT EXISTS turnout (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    location VARCHAR(255),
    organizer_id INTEGER REFERENCES members(id),
    status VARCHAR(20) DEFAULT 'upcoming'
    attendance VARCHAR(20)
);



CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES members(id),
    date DATE NOT NULL,
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    status VARCHAR(20) DEFAULT 'present'
);


late final String host = dotenv.env['DB_HOST'] ?? 'localhost';
  late final int port = (dotenv.env['DB_PORT'] ?? '5432') as int;
  late final String dbName = dotenv.env['DB_NAME'] ?? 'societas';
  late final String dbUser = dotenv.env['DB_USER'] ?? 'societas_user';
  late final String dbPassword = dotenv.env['DATABASE_URL] ?? '';

   import 'package:flutter/services.dart' show rootBundle;