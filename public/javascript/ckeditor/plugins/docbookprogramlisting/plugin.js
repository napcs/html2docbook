CKEDITOR.plugins.add( 'docbookprogramlisting',
{
    init: function( editor )
    {
        editor.addCommand( 'AddProgramlisting',
            {
              exec : function( editor )
              {    
                editor.insertHtml( '<pre data-docbook-verbatim="programlisting"></pre>');
              }
            });
        editor.ui.addButton( 'DocbookProgramlisting',
        {
          label: 'Add a Program Listing block',
          command: 'AddProgramlisting',
          icon: this.path + 'pl.png'
        } );
    }
} );