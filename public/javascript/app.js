$(function(){
    
  $("#help").dialog({
    bgiframe: true,
    width: 700,
    modal: true,
    autoOpen: false
  });
  
  $("a#help_link").on("click", function(e){
    e.preventDefault();
    $("#help").dialog("open");
  });
  
    CKEDITOR.replace( 'code', {
            toolbar : 'MyToolbar'
        });
});