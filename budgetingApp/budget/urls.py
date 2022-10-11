from django.urls import path
from . import views

urlpatterns = [
        path('', views.index, name='index'),
        path('pubkey', views.exchangePublicToken, name='pubkey'),
        path('link', views.getLinkToken, name='link'),
        path('accounts', views.getAccounts, name='accounts'),
        path('transactions', views.getTransactions, name='transactions')
        ]
