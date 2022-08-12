from django.db import models
"""
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.contrib.auth.password_validation import validate_password

import uuid

class UserManager(BaseUserManager):
    def _create_user(self, name, password, is_superuser=False, is_staff=False, **other):
        if 'id' not in other:
            other['id'] = uuid.uuid4()
        if not name:
            raise ValueError("Please enter your name")

        user = self.model(
                name=self.name,
                is_superuser=is_superuser,
                is_staff=is_staff,
                **other
                )
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_user(self, name, password, **other):
        return self._create_user(name, password, False, False, **other)

    def create_superuser(self, name, password, **other):
        return self._create_user(name, password, True, True, **other)


class BudgetUser(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, editable=False,
            default=uuid.uuid4, unique=True)
    name = models.CharField(max_length=40, unique=True)
    is_superuser = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)

    USERNAME_FIELD = 'name'

    objects = UserManager()
"""
