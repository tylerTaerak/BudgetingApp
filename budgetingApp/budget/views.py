from django.shortcuts import render
from django.http import HttpResponse
from django.db import transaction

from rest_framework.viewsets import GenericViewSet
import os

from plaid import Client

from budget.models import *


PLAID_CLIENT_ID = os.getenv('PLAID_CLIENT_ID')
PLAID_PUBLIC_KEY = os.getenv('PLAID_PUBLIC_KEY')
PLAID_SECRET = os.getenv('PLAID_SECRET')
PLAID_ENV = os.getenv('PLAID_ENV', 'sandbox')


def get_plaid_client():
    return Client(
            client_id = PLAID_CLIENT_ID,
            secret = PLAID_SECRET,
            public_key = PLAID_PUBLIC_KEY,
            environment = PLAID_ENV
            )


def index(request):
    return render(request, 'index.html', {'plaid_public_key': PLAID_PUBLIC_KEY,
                                            'plaid_environment': PLAID_ENV})


def get_access_token(request):
    global access_token

    public = request.POST['public_token']
    client = get_plaid_client()
    exchange_response = client.Item.public_token.exchange(public)
    access_token = exchange_response['access_token']

    return JsonResponse(exchange_response)

def set_access_token(request):
    global access_token

    access_token = request.POST('access_token')

    return JsonResponse({'error': False})

def accounts(request):
    global access_token

    client = get_plaid_client()
    accounts = client.Auth.get(access_token)
    return JsonResponse(accounts)

def item(request):
    global access_token

    client = get_plaid_client()
    item_resp = client.Item.get(access_token)
    inst_resp = client.Institutions.get_by_id(item_resp['item']['institution_id'])
    return JsonResponse({'item': item_resp['item'],
        'institution': inst_resp['institution']})

def transactions(request):
    global access_token

    client = get_plaid_client()
    start_date = "{:%Y-%m-%d}".format(datetime.datetime.now() + datetime.timedelta(-30))
    end_date = "{:%Y-%m-%d}".format(datetime.datetime.now())
    resp = client.Transactions.get(access_token, start_date, end_date)
    return JsonResponse(resp)

def create_public_token(request):
    global access_token

    client = get_plaid_client()
    resp = client.Item.public_token.create(access_token)
    return JsonResponse(response)

