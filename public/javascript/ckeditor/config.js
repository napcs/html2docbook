CKEDITOR.editorConfig = function( config )
{
  config.toolbar = 'MyToolbar';
  
  config.toolbar_MyToolbar =
  [
      ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Scayt'],
      ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
      ['Image','Table'],
      '/',
      ['Format'], ['Styles'],
      ['Italic','Strike'],
      ['NumberedList','BulletedList'],
      ['Link','Unlink'],
      ['DocbookSidebar', 'DocbookProgramlisting'],
      ['Maximize']
  ];

  config.stylesSet = 'docbook_styles';
  config.extraPlugins = 'docbooksidebar,docbookprogramlisting'; 

};
  
CKEDITOR.stylesSet.add( 'docbook_styles',
[
    // Inline styles
    { name : 'Method name', element : 'span', attributes : { 'data-docbook-style' : 'methodname' } },
    { name : 'Class name', element : 'span', attributes : { 'data-docbook-style' : 'classname' } },
    { name : 'Variable name', element : 'span', attributes : { 'data-docbook-style' : 'varname' } },
    { name : 'Command', element : 'span', attributes : { 'data-docbook-style' : 'command' } },
    { name : 'Code', element : 'span', attributes : { 'data-docbook-style' : 'code' } },
    { name : 'Constant', element : 'span', attributes : { 'data-docbook-style' : 'constant' } },
    
    
    
]);


