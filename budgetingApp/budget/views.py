
from django.http import HttpResponse
from django.shortcuts import render

import plaid
from plaid.model.auth_get_request import AuthGetRequest
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.transactions_sync_request import TransactionsSyncRequest
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser

from budget.models import *
import budget.utils as utils


plaid_client = utils.apiClient()
access_token = None


def index(request):
    return render(request, 'index.html', {'plaid_public_key': utils.PLAID_PUBLIC_KEY,
                                            'plaid_environment': utils.PLAID_ENV})


def getAccounts(request):
    global access_token
    request = AuthGetRequest(access_token=access_token)

    global plaid_client
    response = client.auth_get(request)
    
    accounts = response['accounts']
    return JsonResponse(accounts)


def getTransactions(request):
    global access_token
    request = TransactionsSyncRequest(
        access_token=access_token
    )

    global plaid_client
    response = plaid_client.transactions_sync(request)
    transactions = response['transactions']

    while response['has_more']:
        request = TransactionsSyncRequest(
            access_token=access_token,
            cursor=response['next_cursor']
        )
        response = client.transactions_sync(request)
        transactions += response['transactions']

    return JsonResponse(transactions)


def exchangePublicToken(request):
    exchangeReq = ItemPublicTokenExchangeRequest(
        public_token=request['public_token']
    )

    global plaid_client
    exchangeResp = plaid_client.item_public_token_exchange(exchangeReq)

    global access_token
    access_token = exchangeResp['access_token']

    return JsonResponse(exchangeResp)


def startLink(request):
    pass
    response = "blah blah"
    return exchangePublicToken(response)


def getLinkToken(request):
    request = LinkTokenCreateRequest(
        products=[Products('auth'), Products('transactions')],
        client_name="Conley Budgeting",
        country_codes=[CountryCode('US')],
        redirect_uri=utils.PLAID_URI,
        language='en',
        webhook='https://sample-webhook-uri.com',
        link_customization_name='default',
        user=LinkTokenCreateRequestUser(
            client_user_id='123-test-user-id'
        ),
    )

    # create link token
    global plaid_client
    response = client.link_token_create(request)
    link_token = response['link_token']
    
    return startLink(response)
    
