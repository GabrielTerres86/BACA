/*!
 * FONTE        : ckeditor_config.sj
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 18/09/2017
 * OBJETIVO     : Arquivo com configuração do componente ckeditor
 * CUIDADOS     : Se atentar no nome da toolbar para não impactar em telas já em funcionamento
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

CKEDITOR.editorConfig = function( config ) {
	config.toolbarEnvnot = [
		{ name: 'styles', items: [ 'Format' ] },
		{ name: 'basicstyles', items: ['Bold','Italic','Underline'] },
		{ name: 'paragraph', items: ['NumberedList', 'BulletedList'] }
	];
	config.removeButtons = 'Source,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Scayt,Strike,Blockquote,Unlink,Link,Anchor,Subscript,Superscript,RemoveFormat,About,Image,Styles,Maximize,HorizontalRule,Table,SpecialChar,Outdent,Indent,';
};