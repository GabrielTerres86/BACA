<?
/* * *********************************************************************

  Fonte: form_filtro.php
  Autor: Andrei - RKAM
  Data : Maio/2016                       Última Alteração: 

  Objetivo  : Mostrar valores da Gravam.

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
		
		<div id="divFiltroConta">

			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
			<label for="cdagenci">PA:</label>
			<input type="text" id="cdagenci" name="cdagenci" />
			
			<label for="nrctrpro">Contrato:</label>
			<input type="text" id="nrctrpro" name="nrctrpro"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>

			<label for="nrgravam">N&uacute;mero do registro:</label>
			<input type="text" id="nrgravam" name="nrgravam"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(4); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		</div> 
		
	</fieldset>

	<fieldset id="fsetFiltroCancelamento" name="fsetFiltroCancelamento" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Tipo de Cancelamento</legend>

		<div id="divCancelamento">
		
			<label for="tpcancel"><? echo utf8ToHtml('Tipo do cancelamento:') ?></label>
			<select id="tpcancel" name="tpcancel" >
				<option value="1"> <? echo utf8ToHtml('Arquivo') ?> </option> 
				<option value="2"> <? echo utf8ToHtml('Manual') ?> </option>	
			</select>

		</div> 

	</fieldset>

</form>

