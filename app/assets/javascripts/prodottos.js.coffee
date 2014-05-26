# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#nuovo_negozio").fadeOut()
  $("#prezzo_negozio_id").click ->
    if $("#prezzo_negozio_id").val() == "" 
      $("#nuovo_negozio").fadeIn()
    else
      $("#nuovo_negozio").fadeOut()
  $("#nuovo_prodotto").fadeOut()
  $("#prezzo_prodotto_id").click ->
    if $("#prezzo_prodotto_id").val() == "" 
      $("#nuovo_prodotto").fadeIn()
    else
      $("#nuovo_prodotto").fadeOut() 
