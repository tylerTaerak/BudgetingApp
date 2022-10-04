from django.urls import path
from . import views

urlpatterns = [
        path('', views.index, name='index'),
        path('link', views.startLink, name='link'),
        path('accounts', views.getAccounts, name='accounts'),
        path('transactions', views.getTransactions, name='transactions')
        ]
