<?
/* * *********************************************************************

  Fonte: form_filtro_arquivo.php
  Autor: Andrei - RKAM
  Data : Maio/2016                       Última Alteração: 

  Objetivo  : Mostrar o form de filtros para as opções G/R.

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
		
		<div id="divFiltroArq">

			<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
			<select id="cdcooper" name="cdcooper" ></select>
				
			<label for="tparquiv"><? echo utf8ToHtml('Tipo do arquivo:') ?></label>
			<select id="tparquiv" name="tparquiv" >
				<option value="INCLUSAO"> <? echo utf8ToHtml('Inclus&atilde;o') ?> </option> 
				<option value="BAIXA"> <? echo utf8ToHtml('Baixa') ?> </option>	
				<option value="CANCELAMENTO"> <? echo utf8ToHtml('Cancelamento') ?> </option>	
				<option value="TODAS"> <? echo utf8ToHtml('Todas') ?> </option>	
			</select>
			
		</div> 
		
	</fieldset>

</form>

