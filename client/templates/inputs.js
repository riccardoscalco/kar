Template.inputs.helpers({
  day: function() {
    return '' + (new Date(Session.get('date')).getDate());
  },
  month: function() {
    return '' + (new Date(Session.get('date')).getMonth() + 1);
  },
  year: function() {
    return '' + new Date(Session.get('date')).getFullYear();
  }
})

Template.inputs.events({

  'submit form': function(e) {

    if (!Session.get('submitting')) {

      Session.set('submitting',true);
      e.preventDefault();

      var d = new Date();
      var day = $(e.target).find('[name=day]'),
          month = $(e.target).find('[name=month]'),
          year = $(e.target).find('[name=year]'),

      day = day.val() ? day.val() : day.attr('placeholder');
      month = month.val() ? month.val() : month.attr('placeholder');
      year = year.val() ? year.val() : year.attr('placeholder');

      var hours = '' + new Date(Session.get('date')).getHours();
      var minutes = '' + new Date(Session.get('date')).getMinutes();
      var seconds = '' + new Date(Session.get('date')).getSeconds();

      var date = new Date( year, month - 1, day, hours, minutes, seconds );
      
      var note = {
        'show': true,
        'date': date.getTime(),
        'coordinates': Session.get('coordinates'),
        'description': $(e.target).find('[name=description]').val(),
        'category': $(e.target).find('[name="radios"]:checked').val()
      };

      note._id = Notes.insert(note);

    } else {
      e.preventDefault();
      null;
    }

  }
});



Template.inputs.rendered = function() {

  (function() {
    // trim polyfill : https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim
    if (!String.prototype.trim) {
      (function() {
        // Make sure we trim BOM and NBSP
        var rtrim = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
        String.prototype.trim = function() {
          return this.replace(rtrim, '');
        };
      })();
    }

    [].slice.call( document.querySelectorAll( 'input.input__field' ) ).forEach( function( inputEl ) {
      // in case the input is already filled..
      if( inputEl.value.trim() !== '' ) {
        classie.add( inputEl.parentNode, 'input--filled' );
      }

      // events:
      inputEl.addEventListener( 'focus', onInputFocus );
      inputEl.addEventListener( 'blur', onInputBlur );
    } );

    function onInputFocus( ev ) {
      classie.add( ev.target.parentNode, 'input--filled' );
    }

    function onInputBlur( ev ) {
      if( ev.target.value.trim() === '' ) {
        classie.remove( ev.target.parentNode, 'input--filled' );
      }
    }
  })();

}