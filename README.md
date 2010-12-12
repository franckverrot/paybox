Paybox
======


Installation (Rails 3)
----------------------

In your Gemfile :

    gem 'paybox'


Usage
-----

    response = Paybox.new(
      :operation => '00057',
      :amount => 1000,
      :user_id => your_db_customer/suscriber_account_id,
      :card_nbr => card_number_or_encrypted_alias,
      :expire => card_expiration_date (mmyy),
      :cvv2 => card_cvv2_code (3 digits)
    )

Then you can read response like this, for instance :

    response.coderesponse = '00000' # =>  Cool, successful request
or
    response.commentaire = "PAYBOX : Numéro de porteur invalide" # =>  Oooops, invalid card number given

Todo
----

Lots of improvements can be made:

* Add I18n
* Tests
* Documentation
* ...

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


Contributors
------------
* Guillaume Barillot, author of the initial implementation
* Franck Verrot

Copyright
---------

Copyright (c) 2010 Franck Verrot. MIT LICENSE. See LICENSE for details.
