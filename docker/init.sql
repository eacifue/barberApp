-- Create role
CREATE ROLE barberia_user WITH LOGIN PASSWORD 'Barberia123!';

-- Grant privileges
ALTER ROLE barberia_user CREATEDB;
