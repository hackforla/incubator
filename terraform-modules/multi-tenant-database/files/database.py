from sqlalchemy import create_engine
from sqlalchemy import exc

def lambda_handler(event, context):
  environment  = event["environment"]
  new_db       = f"{event['new_db']}_{environment}"
  db_owner     = f"{event['new_db_user']}_{environment}"
  new_password = event["new_db_password"]
  new_schema   = f"{new_db}_schema"


  root_db_user = event["root_db_username"]
  root_db_password = event["root_db_password"]
  db_host = event["db_host"]
  database_url = f"postgresql://{root_db_user}:{root_db_password}@{db_host}/"

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

  # Revoke access to disallow changes from other users
  sql_revoke = f"""
  -- Remove ability for all users to do everything in public schema
  REVOKE ALL ON SCHEMA public FROM public;
  -- Ensure users can list down objects in public schema
  GRANT USAGE ON SCHEMA public TO public;
  """
  engine.execute(sql_revoke)

  return event