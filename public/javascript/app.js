$(function(){
  
  $("#help").hide();
  
  $("a#help_link").on("click", function(e){
    e.preventDefault();
    $("#help").dialog({
      bgiframe: true,
      width: 700,
      modal: true,
      autoOpen: true
    });
  });
  
    CKEDITOR.replace( 'code', {
            toolbar : 'MyToolbar'
        });
});