<?
/* * *********************************************************************

  Fonte: form_filtro.php
  Autor: Andrei - RKAM
  Data : Julho/2016                       Última Alteração: 11/08/2016

  Objetivo  : Mostrar valores da LCREDI.

  Alterações: 11/08/2016 - Retirado a chamada da include para carregar as permissões
						  (Andrei - RKAM).
  

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
				
		<label for="cdlcremp"><? echo utf8ToHtml("C&oacute;digo:"); ?></label>
		<input type="text" id="cdlcremp" name="cdlcremp" >
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('1'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
	</fieldset>
	
</form>

