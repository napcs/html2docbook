CKEDITOR.plugins.add( 'DocbookSidebar',
{
    init: function( editor )
    {
        editor.addCommand( 'AddSidebar',
            {
              exec : function( editor )
              {    
                editor.insertHtml( '<div data-docbook-admonishment="sidebar"><h2>Title</h2><p>Sidebar text</p></div>');
              }
            });
        editor.ui.addButton('DocbookSidebar',
        {
          label: 'Add a sidebar',
          command: 'AddSidebar',
          icon: this.path + 'sb.png'
        } );
    }
} );