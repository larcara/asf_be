/**
 * Created with JetBrains RubyMine.
 * User: Luca
 * Date: 02/11/13
 * Time: 13.56
 * To change this template use File | Settings | File Templates.
 */
function parsepage(pagenumber){

    var pagelink="http://www.klikkapromo.it/coupon-offerta-ddd-ff-dd_" + pagenumber+ "_D_0";
    var obj={};
    console.log("ciao");
    var jqxhr = $.ajax(
        {
            url: pagelink,
            crossDomain: true,
            xhrFields: {withCredentials: true}
        }).done(function() {
            alert( "success" );
        }).fail(function(data) {
            alert( "error" + data );
        }).always(function() {
            alert( "complete" );
        });


    /*
    $.post(pagelink, function (data) {
        obj={
            marca: $(".box_sez_prod:first h2:first", data).text().trim(),
            prodotto: $("title", data).text().trim().split("|")[0].trim(),
            prodotto2: $(".box_sez_prod:first span:first", data).html().split("<br>")[0].trim(),
            key: "klikkapromo_" + pagenumber,
            prezzovolume: $(".box_sez_prod:first span:first", data).html().split("<br>")[1].trim(),
            categories: $.map($("#tblVediAltriProdotti.related>li a", data), function(value,index){return $(value).text()}),
            specialprice: $("#MainContent_pnl_Offerte table tr", data)
        };    // can use 'data' in here...
    });
     alert (obj);
     */



}