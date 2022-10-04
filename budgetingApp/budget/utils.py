import plaid
from plaid.api import plaid_api

import os

PLAID_CLIENT_ID = os.getenv('PLAID_CLIENT_ID')
PLAID_PUBLIC_KEY = os.getenv('PLAID_PUBLIC_KEY')
PLAID_SECRET = os.getenv('PLAID_SECRET')
PLAID_URI = os.getenv('PLAID_REDIRECT_URI')
PLAID_ENV = plaid.Environment.Sandbox,

config = plaid.Configuration(
        host=PLAID_ENV,
        api_key={
            'clientId': PLAID_CLIENT_ID,
            'secret': PLAID_SECRET
            }
        )

api_client = plaid.ApiClient(config)
client = plaid_api.PlaidApi(api_client)

def apiClient():
    return client

def env():
    return {
        'PLAID_CLIENT_ID': PLAID_CLIENT_ID,
        'PLAID_PUBLIC_KEY': PLAID_PUBLIC_KEY,
        'PLAID_URI': PLAID_URI,
        'PLAID_ENV': PLAID_ENV
    }
