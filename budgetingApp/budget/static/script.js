var handler = Plaid.create({
  
  env: 'sandbox',

  key: "{{ public_key }}",

  onSuccess: function(public_token, metadata) {
      $.ajaxSetup({beforeSend: function(xhr){
        xhr.setRequestHeader('Authorization', 'Token ' + localStorage.getItem('authToken'))
      }});
      $.post(
        {public_token: public_token},
        () => {
          document.location = "{% url 'accounts' %}";
        }
      );
  },

});
