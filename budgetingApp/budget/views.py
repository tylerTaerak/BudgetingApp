from django.shortcuts import render
from django.http import HttpResponse
from django.db import transaction
from rest_framework.viewsets import GenericViewSet
from budget.models import *


def index(request):
    return HttpResponse("Hello, world. This is the budget")



class PlaidLinkViewSet(GenericViewSet):
    @transaction.atomic()
    def create(self, request):
        public_token = request.data['public_token']
        exchange = plaid_client.Item.public_token.exchange(public_token)
        token, created = PlaidToken.objects.get_or_create(
            user=request.user,
            defaults={'access_token': echange['access_token']}
        )
        if not created:
            token.access_token = exchange['access_token']
            token.save()
        return Response(status=status.HTTP_204_NO_CONTENT)

class TransactionsViewSet(GenericViewSet):
    def list(self, request):
        try:
            token = PlaidToken.objects.get(user=request.user)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND)
        plaid_resp = plaid_client.Transactions.get(
                access_token=token.access_token,
                start_date='today',
                end_date='today',
                account_ids=[request.query_params['account']]
            )
        return Response(data={'content': plaid_resp['transactions']})
