<?
/* * *********************************************************************

  Fonte: form_filtro_historico.php
  Autor: Andrei - RKAM
  Data : Maio/2016                       Última Alteração: 

  Objetivo  :  Mostrar o form de filtros para a opão H.

  Alterações: 
  

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");	

?>
<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltroHistorico">

			<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
			<select id="cdcooper" name="cdcooper" ></select>

			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
			<label for="nrctrpro">Contrato:</label>
			<input type="text" id="nrctrpro" name="nrctrpro"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>

		</div> 

	</fieldset>

</form>

