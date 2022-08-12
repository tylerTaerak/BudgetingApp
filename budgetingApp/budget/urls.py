from django.urls import path
from . import views

urlpatterns = [
        path('', views.index, name='index'),
        path('get-access', views.get_access_token, name='access'),
        path('accounts', views.accounts, name='accounts'),
        path('item', views.item, name='item'),
        path('transactions', views.transactions, name='transactions')
        ]
