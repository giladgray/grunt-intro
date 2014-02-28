console.log 'Hello from CoffeeScript!'

nav = $('<ul>').addClass('nav').attr('id', 'section')
for h1 in $('h1') when h1.textContent.trim()
  nav.append $('<li>').append $('<a>').attr('href', "##{h1.id}").text(h1.textContent)

$('.navbar').prepend nav

$('#toggleMenu').click ->
  $('.navbar').toggleClass('collapsed')
  false

$('.navbar a').click (evt) ->
  h1 = $(evt.target.attributes.href.value)
  console.log h1
  padding = +h1.css('padding-top').match(/\d+/)?[0]
  $('body').animate {scrollTop: h1.offset().top + padding - 20}, '500'
  false
