//= require jquery
//= require jquery_ujs
//= require_tree ./landing
//= require_self
//= require login-bundle
//= require handsontable.full


var activeIndex = 0;
var scrollTopPadding = -100;
var wrapper;
var fields;
function setActiveTab() {
    fields.removeClass('active');
    var activeField = fields.eq(activeIndex);
    activeField.addClass('active');
    // activeField.find('input').focus();
}
function scrollToActiveField(field) {
    var index = fields.index(field);
    if (index !== activeIndex) {
        activeIndex = index;
        var offset = jQuery(field).offset().top;
        jQuery('html, body').animate({ scrollTop: wrapper.scrollTop() + offset + scrollTopPadding }, 200);
        setActiveTab();
    }
}
function scrollToActiveFieldByIndex(index) {
    scrollToActiveField(fields.eq(index));
}
jQuery(document).ready(function () {
    wrapper = jQuery('.custom-form-container');
    fields = jQuery('.form-field');
    buttons = jQuery('.call-next');
    fields.click(function () {
        scrollToActiveField(this);
    });
    jQuery('.input-fields').on('keypress', function(e) {
      var keyCode = e.keyCode || e.which;
      if (keyCode === 13) { 
        if(jQuery(this).val() != '') {
          var inputs = jQuery('.input-fields');
          jQuery(this).closest('.form-field').removeClass('active')
          var nextInputIndex = inputs.index($(this)) + 1;
          if (nextInputIndex < inputs.length) {
            inputs.eq(nextInputIndex).focus();
            inputs.eq(nextInputIndex).closest('.form-field').addClass('active')
          }
        }
        return false;
      }
    });
});



if(typeof($) == "undefined")
  $ = jQuery;

$(document).on('click', '.image-checkbox', function() {
	$('.image-checkbox').removeClass('image-checkbox-checked');
	$('.fa-check').addClass('hidden');
  $(this).toggleClass('image-checkbox-checked');
  $(this).find('.fa-check').toggleClass('hidden');
  category_id = $(this).data('category-id');
  var checkbox = $('input[data-checkbox-id='+category_id+']');
  checkbox.prop('checked', !checkbox[0].checked);
  var category_ids = [];
  $('input.category-images-checkbox:checked').each(function(index,checkbox) {
    category_ids.push($(checkbox).val());
  }); 
  $("#hidden_category_ids").val(category_ids);
  scrollToActiveField($(this).closest('.form-field').next());
});

$(document).on('click', '.call-prev', function() {
  scrollToActiveField($(this).closest('.form-field').prev());
}); 

 

$(document).on('click', '.call-next', function() {
	console.log(($(this).closest('.form-field')).val());
  if ($(this).parent().prev().parent().find('input').val() != '') {
    scrollToActiveField($(this).closest('.form-field').next());
  }
  // var input_value;
  // input_value = $(this).val();
  // return $.ajax('/admin/orders.html', {
  //   type: "GET",
  //   data: {
  //     input_value: input_value,
  //     template: false
  //   },
  //   success: function(data) {
  //     return alert("success");
  //   }
  // });
});
//
// $(document).on('click', '.name-next', function() {
//   $('#form-id').toggleClass('hidden')
//   $('#email-hide').toggleClass('hidden')
// });
//
// $(document).on('click', '.email-next', function() {
//   $('#email-hide').toggleClass('hidden')
//   $('#mobile-hide').toggleClass('hidden')
// });
//
// $(document).on('click', '.mbl-next', function() {
//   $('#mobile-hide').toggleClass('hidden')
//   $('#upload-product').toggleClass('hidden')
// });





// Typewrite animations
var TxtType = function(el, toRotate, period) {
        this.toRotate = toRotate;
        this.el = el;
        this.loopNum = 0;
        this.period = parseInt(period, 10) || 2000;
        this.txt = '';
        this.tick();
        this.isDeleting = false;
    };

    TxtType.prototype.tick = function() {
        var i = this.loopNum % this.toRotate.length;
        var fullTxt = this.toRotate[i];

        if (this.isDeleting) {
        this.txt = fullTxt.substring(0, this.txt.length - 1);
        } else {
        this.txt = fullTxt.substring(0, this.txt.length + 1);
        }

        this.el.innerHTML = '<span class="wrap">'+this.txt+'</span>';

        var that = this;
        var delta = 140 - Math.random() * 100;

        if (this.isDeleting) { delta /= 2; }

        if (!this.isDeleting && this.txt === fullTxt) {
        delta = this.period;
        this.isDeleting = true;
        } else if (this.isDeleting && this.txt === '') {
        this.isDeleting = false;
        this.loopNum++;
        delta = 500;
        }

        setTimeout(function() {
        that.tick();
        }, delta);
    };

    window.onload = function() {
        var elements = document.getElementsByClassName('typewrite');
        for (var i=0; i<elements.length; i++) {
            var toRotate = elements[i].getAttribute('data-type');
            var period = elements[i].getAttribute('data-period');
            if (toRotate) {
              new TxtType(elements[i], JSON.parse(toRotate), period);
            }
        }
        var css = document.createElement("style");
        css.type = "text/css";
        document.body.appendChild(css);
    };
// jQuery(".input-fields").on("click", "input", function(){
//     jQuery('.wrapper-form::after').css('width','100%');
//     console.log('jgdfhj');
//   });
// Nav,footer smooth scroll
jQuery( document ).ready(function() {
    jQuery(".faq-btn").click(function(event) {
        event.preventDefault();
        jQuery('html, body').animate({
            scrollTop: jQuery("#faq").offset().top
        }, 1400);
    });

    jQuery(".features-btn").click(function(event) {
        event.preventDefault();
        jQuery('html, body').animate({
            scrollTop: jQuery("#request-quote").offset().top
        }, 1400);
    });

    jQuery(".contact-btn").click(function(event) {
        event.preventDefault();
        jQuery('html, body').animate({
            scrollTop: jQuery("#contact").offset().top
        }, 1400);
    });

})