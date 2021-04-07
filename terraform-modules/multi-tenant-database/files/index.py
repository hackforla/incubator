import os

def lambda_handler(event, context):
  print('hello world')

  print(os.getenv('FOO'))

  return {
    "db_host":event['db_host'],
    "db_password":event['db_password'],
  }
