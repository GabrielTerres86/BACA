<?
/* * *********************************************************************

  Fonte: form_filtro.php
  Autor: Douglas Pagel (AMcom)
  Data : Fevereiro/2019                       Última Alteração: 

  Objetivo  : Mostrar valores da SEGEMP.

  Alterações:   

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
		

?>
<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
				
		<label for="idsegmento"><? echo utf8ToHtml("C&oacute;digo:"); ?></label>
		<input type="text" id="idsegmento" name="idsegmento" >
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('1'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
	</fieldset>
	
</form>

