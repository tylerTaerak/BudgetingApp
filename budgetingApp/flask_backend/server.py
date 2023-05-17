# source /Users/tnappy/node_projects/quickstart/python/bin/activate
# Read env vars from .env file
from plaid.model.products import Products
from plaid.model.country_code import CountryCode
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.transactions_sync_request import TransactionsSyncRequest
from plaid.model.transactions_get_request import TransactionsGetRequest
from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
from plaid.model.accounts_balance_get_request import AccountsBalanceGetRequest
from plaid.api import plaid_api
from flask import Flask
from flask import request
from flask import jsonify
import datetime
import plaid
import os
import json
import time
from dotenv import load_dotenv
load_dotenv()
app = Flask(__name__)

# Fill in your Plaid API keys - https://dashboard.plaid.com/account/keys
PLAID_CLIENT_ID = os.getenv('PLAID_CLIENT_ID')
PLAID_SECRET = os.getenv('PLAID_SECRET')
# Use 'sandbox' to test with Plaid's Sandbox environment (username: user_good,
# password: pass_good)
# Use `development` to test with live users and credentials and `production`
# to go live
PLAID_ENV = os.getenv('PLAID_ENV', 'sandbox')
# PLAID_PRODUCTS is a comma-separated list of products to use when initializing
# Link. Note that this list must contain 'assets' in order for the app to be
# able to create and retrieve asset reports.
PLAID_PRODUCTS = os.getenv('PLAID_PRODUCTS', 'transactions').split(',')

# PLAID_COUNTRY_CODES is a comma-separated list of countries for which users
# will be able to select institutions from.
PLAID_COUNTRY_CODES = os.getenv('PLAID_COUNTRY_CODES', 'US').split(',')


def empty_to_none(field):
    value = os.getenv(field)
    if value is None or len(value) == 0:
        return None
    return value


host = plaid.Environment.Sandbox

if PLAID_ENV == 'sandbox':
    host = plaid.Environment.Sandbox

if PLAID_ENV == 'development':
    host = plaid.Environment.Development

if PLAID_ENV == 'production':
    host = plaid.Environment.Production

# Parameters used for the OAuth redirect Link flow.
#
# Set PLAID_REDIRECT_URI to 'http://localhost:3000/'
# The OAuth redirect flow requires an endpoint on the developer's website
# that the bank website should redirect to. You will need to configure
# this redirect URI for your client ID through the Plaid developer dashboard
# at https://dashboard.plaid.com/team/api.
PLAID_REDIRECT_URI = empty_to_none('PLAID_REDIRECT_URI')

configuration = plaid.Configuration(
    host=host,
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
        'plaidVersion': '2020-09-14'
    }
)

api_client = plaid.ApiClient(configuration)
client = plaid_api.PlaidApi(api_client)

products = []
for product in PLAID_PRODUCTS:
    products.append(Products(product))


# Use local persistent storage to store access_tokens
try:
    with open('./.access_token', 'r') as handle:
        access_token = []
        for line in handle:
            access_token.append(line)
except FileNotFoundError:
    access_token = None


# no database this time around; save buckets to file regularly,
# load on startup in system memory
try:
    with open('./buckets.json', 'r') as handle:
        buckets = json.load(handle)
        buckets = buckets['buckets']
except FileNotFoundError:
    buckets = {"spending": [{"name": "Other", "type": "spending",
                             "maxAmount": 1.00, "currAmount": 0.00,
                             "transactions": []}],
               "savings": [{"name": "General", "type": "savings",
                            "maxAmount": 1.00, "currAmount": 0.00,
                            "transactions": []
                            }]
               }


# function to write bucket objects to file
def write_buckets_to_file():
    bucket_obj = json.dumps(buckets, indent=2)
    with open('./buckets.json', 'w') as handle:
        handle.write(bucket_obj)


# this is just a helper function, commenting out for now, once the app is
# finished delete completely
def pretty_print_response(response):
    print(json.dumps(response, indent=2, sort_keys=True, default=str))


def format_error(e):
    response = json.loads(e.body)
    return {'error': {'status_code': e.status, 'display_message':
                      response['error_message'],
                      'error_code': response['error_code'],
                      'error_type': response['error_type']}}


# This is the main function for the backend, where it collects
# all of the required information for the application and sends
# it. It is largely adapted from the Plaid API quickstart project
# code.
@app.route('/budget/get_all_info', methods=['GET'])
def get_info():

    response = dict()
    transactions = None  # we're gonna be working with these later

    try:
        # do transaction request stuff with Plaid API

        # get transactions for the current month
        today = datetime.date.today()

        response['transactions'] = []
        response['balances'] = {}
        for token in access_token:
            # do transaction request stuff with Plaid API
            transactions = TransactionsGetRequest(
                    access_token=token,
                    start_date=today.replace(day=1),
                    end_date=today,
                    options=TransactionsGetRequestOptions(
                        include_personal_finance_category=True
                        )
                    )
            transactions = client.transactions_get(transactions).to_dict()
            response['transactions'] += transactions['transactions']

            # do balance request stuff with Plaid API
            balanceRequest = AccountsBalanceGetRequest(
                    access_token=token
                    )

            balances = client.accounts_balance_get(balanceRequest)
            response['balances'] = balances.to_dict()

    except plaid.ApiException as e:
        error_response = format_error(e)
        return jsonify(error_response)

    for bucket in buckets['spending']:
        local_transactions = [t for t in
                              response['transactions']
                              if bucket['name'] in t['category']]

        bucket['currAmount'] = 0
        bucket['transactions'] = []

        for t in local_transactions:
            bucket['currAmount'] += t['amount']
            bucket['transactions'].append(t)

    response['buckets'] = buckets

    categories = client.categories_get({})
    with open('categories', 'w') as handle:
        handle.write(json.dumps(categories.to_dict()))

    return jsonify(response)


@app.route('/budget/add_bucket', methods=['POST'])
def add_bucket(request):
    buckets['type'].append(request.body)


@app.route('/budget/get_buckets', methods=['GET'])
def get_buckets():
    bucketJson = {'buckets': buckets}
    return jsonify(bucketJson)


"""
<section>
This section has all of the calls required to get a link token and exchange it
for a full access token
"""


@app.route('/budget/link', methods=['GET'])
def create_link_token():
    try:
        request = LinkTokenCreateRequest(
            products=products,
            client_name="Conley Budgeting",
            country_codes=list(map(lambda x:
                                   CountryCode(x), PLAID_COUNTRY_CODES)),
            language='en',
            user=LinkTokenCreateRequestUser(
                client_user_id=str(time.time())
            )
        )
        '''
        if PLAID_REDIRECT_URI!=None:
            print(PLAID_REDIRECT_URI)
            request['redirect_uri']=PLAID_REDIRECT_URI
        '''

    # create link token
        response = client.link_token_create(request)
        return jsonify(response.to_dict())
    except plaid.ApiException as e:
        print(e)
        return json.loads(e.body)


# Exchange token flow - exchange a Link public_token for
# an API access_token
# https://plaid.com/docs/#exchange-token-flow

@app.route('/budget/exchange_tokens', methods=['POST'])
def get_access_token():
    request_data = request.get_json()  # convert to just json data
    global access_token
    global item_id
    global transfer_id
    public_token = request_data['public_token']
    try:
        exchange_request = ItemPublicTokenExchangeRequest(
            public_token=public_token)
        exchange_response = client.item_public_token_exchange(exchange_request)
        access_token.append(exchange_response['access_token'])

        # write newly retrieved access token to file
        with open("./.access_token", "w") as handle:
            handle.write("\n".join(access_token))

        item_id = exchange_response['item_id']
        return jsonify(exchange_response.to_dict())
    except plaid.ApiException as e:
        return json.loads(e.body)


"""
</section>
"""


if __name__ == '__main__':
    app.run(port=os.getenv('PORT', 9090))
