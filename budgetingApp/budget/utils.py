import plaid
from plaid.api import plaid_api

config = plaid.Configuration(
        host=plaid.Environment.Sandbox,
        api_key={
            'clientId': 'asdf',
            'secret': 'asdfasg'
            }
        )

api_client = plaid.ApiClient(config)
client = plaid_api.PlaidApi(api_client)
