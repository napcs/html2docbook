CKEDITOR.editorConfig = function( config )
{
  config.toolbar = 'MyToolbar';

  config.toolbar_MyToolbar =
  [
      ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Scayt'],
      ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
      ['Image','Table'],
      '/',
      ['Format'],
      ['Italic','Strike'],
      ['NumberedList','BulletedList'],
      ['Link','Unlink'],
      ['Maximize','-','About']
  ];
};