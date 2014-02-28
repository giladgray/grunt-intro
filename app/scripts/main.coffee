console.log 'Hello from CoffeeScript!'

nav = $('<ul>').addClass('nav').attr('id', 'section')
for h1 in $('h1') when h1.textContent.trim()
  nav.append $('<li>').append $('<a>').attr('href', "##{h1.id}").text(h1.textContent)

$('.navbar').prepend nav
