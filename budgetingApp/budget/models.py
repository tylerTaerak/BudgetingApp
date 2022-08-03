from django.db import models

class PlaidToken(models.Model):
    access_token = models.CharField(max_length=64, default='')
    user + models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

