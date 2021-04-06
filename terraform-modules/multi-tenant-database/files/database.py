from sqlalchemy import create_engine
from sqlalchemy import exc

new_db = "mid_prod"
db_owner = "mid_prod_owner"
db_user = "mid_prod_appuser"
new_password = "lol"
new_schema = f"{new_db}_schema"


root_db_user = "postgres"
root_db_password = ""
db_host = "incubator-prod-database.ckkyjlg5wpvd.us-west-1.rds.amazonaws.com"
database_url = f"postgresql://{root_db_user}:{root_db_password}@{db_host}:5432/"

engine = create_engine(database_url+"postgres", isolation_level="AUTOCOMMIT")

sql_create_db_owner = f"""
-- Create the schema owner
CREATE USER {db_owner} WITH PASSWORD '{new_password}';
-- Assign the new role to postgres/root
GRANT {db_owner} TO postgres;
"""
try: # Catch exception if user already exists
  engine.execute(sql_create_db_owner)
except exc.SQLAlchemyError:
  pass

# Create database must be in it's own execution
sql_create_db = f"CREATE DATABASE {new_db};"
try: # Catch exception if DB already exists
  engine.execute(sql_create_db)
except exc.SQLAlchemyError:
  pass


# Connect to new database
engine = create_engine(database_url+f"{new_db}", isolation_level="AUTOCOMMIT")

# Create new schema and search_path
sql_new_schema = f"""
-- Create new schema for new DB
CREATE SCHEMA {new_db} AUTHORIZATION {db_owner};
-- Set search_path for the new user
ALTER ROLE {db_owner} SET search_path TO {new_db};
"""
try: # Catch exception if schema already exists
  engine.execute(sql_new_schema)
except exc.SQLAlchemyError:
  pass


sql_create_db_user = f"""
-- Create an db_user that will only have DML privileges on apps
CREATE USER {db_user} WITH PASSWORD '{new_password}';
-- Set the search_path for the api_user to be apps
ALTER ROLE {db_user} SET search_path TO {new_db};
"""
try: # Catch exception if user already exists
  engine.execute(sql_create_db_user)
except exc.SQLAlchemyError:
  pass


# Connect to new DB as new DB owner
new_db_conn = f"postgresql://{db_owner}:{new_password}@{db_host}:5432/"
engine = create_engine(database_url+f"{new_db}", isolation_level="AUTOCOMMIT")
sql_grant_db_user = f"""
-- Grant privileges for user to list objects
GRANT USAGE ON SCHEMA apps TO api_user;

-- Grant privileges for user to existing tables and sequences
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA {new_db} TO {db_user};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA disclosures TO {db_user};

-- Grant privileges for user on all future tables and sequences in apps by default
ALTER DEFAULT PRIVILEGES IN SCHEMA {new_db} GRANT ALL PRIVILEGES ON TABLES TO {db_user};
ALTER DEFAULT PRIVILEGES IN SCHEMA disclosures GRANT ALL PRIVILEGES ON SEQUENCES TO {db_user};
"""
try: # Catch exception if user already exists
  engine.execute(sql_grant_db_user)
except exc.SQLAlchemyError:
  pass



# Revoke access to disallow changes from other users
sql_revoke = f"""
-- Remove ability for all users to do everything in public schema
REVOKE ALL ON SCHEMA public FROM public;
-- Ensure users can list down objects in public schema
GRANT USAGE ON SCHEMA public TO public;
"""
engine.execute(sql_revoke)
