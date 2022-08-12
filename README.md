# Budgeting Application

The budgeting application will:

* Keep track of expenditures and income
* Keep track of credit
* Keep track of envelope system & warn when low (buckets for checking/spending)
* Place money into buckets (for saving)

Currently (as of 22.8.3), I only have the Plaid quickstart installed properly,
which is just a simple showing-how of Plaid's software. I can probably use the code
within to learn a little bit more of how Plaid works and how I can implement it 
into my own web app, for me and Megan to use together for our various accounts.

A super great place to look at is [this github repo](https://github.com/ribab/plaid_django_example).
It's a fully working Django backend with Plaid implemented, so it's right up the alley
of which I wish to traverse

However, it seems that the version of the Plaid API that this example app uses is extremely
outdated (this site uses v4.0.0, but the current version is well over v9.0..). So I think it will
need to be translated to the modern version of Plaid, so that I can actually use the api properly.
But I think that may be left for another day...

I have decided to remove the quickstart app from this repo, since the above repo is much more
applicable to the kind of application I would like to make.

