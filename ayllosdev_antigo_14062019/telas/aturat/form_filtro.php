<?
/* * *********************************************************************

  Fonte: form_filtro.php
  Autor: Andrei - RKAM
  Data : Maio/2016                       Última Alteração: 

  Objetivo  : Mostrar valores da ATURAT.

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
		
		<div id="divFiltroRel">
		
			<label for="tprelato"><? echo utf8ToHtml('Tipo:') ?></label>
			<select id="tprelato" name="tprelato" >
				<option value="1"> <? echo utf8ToHtml('367 - Rating Associado') ?> </option> 
				<option value="2"> <? echo utf8ToHtml('539 - Ratings Cadastrados') ?> </option>	
			</select>

		</div> 

		<div id="divFiltroConta">

			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
			<label for="cdagenci">PA:</label>
			<input type="text" id="cdagenci" name="cdagenci" />
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="dtinirat">Data:</label>
			<input type="text" id="dtinirat" name="dtinirat"/>
			<label for="dtfinrat">a:</label>
			<input type="text" id="dtfinrat" name="dtfinrat"/>
		
		</div> 
		
	</fieldset>

	<fieldset id="fsetRisco" name="fsetRisco" style="display:none;padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Risco</legend>

		<div id="divRiscoCooperado">

			<label for="inrisctl">Risco do cooperado:</label>
			<input type="text" id="inrisctl" name="inrisctl"/>
			
		</div> 

	</fieldset>

</form>

