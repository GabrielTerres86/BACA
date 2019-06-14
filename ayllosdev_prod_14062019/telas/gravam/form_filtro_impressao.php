<?
/* * *********************************************************************

  Fonte: form_filtro_impressao.php
  Autor: Andrei - RKAM
  Data : Maio/2016                       Última Alteração: 

  Objetivo  : Mostrar o form de filtros para a opção I.

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
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px 10px 10px 10px; margin:0px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltroImpressao">

			<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
			<select id="cdcooper" name="cdcooper" ></select>

			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input id="cdagenci" name="cdagenci" />
			
			<label for="nrseqlot">Lote:</label>
			<input type="text" id="nrseqlot" name="nrseqlot"/>
			
			<label for="tparquiv"><? echo utf8ToHtml('Tipo:') ?></label>
			<select id="tparquiv" name="tparquiv" >
				<option value="INCLUSAO"> <? echo utf8ToHtml('Inclus&atilde;o') ?> </option> 
				<option value="BAIXA"> <? echo utf8ToHtml('Baixa') ?> </option>	
				<option value="CANCELAMENTO"> <? echo utf8ToHtml('Cancelamento') ?> </option>	
        <option value="CONSULTA"> <? echo utf8ToHtml('Consulta') ?> </option>	
				<option value="TODAS"> <? echo utf8ToHtml('Todas') ?> </option>	
			</select>

			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="nrctrpro">Contrato:</label>
			<input type="text" id="nrctrpro" name="nrctrpro"/>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="buscaContratosGravames(1, 30); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="dschassi">Chassi:</label>
			<input type="text" id="dschassi" name="dschassi"/>
				
			<label for="dtrefere">Data de:</label>
			<input type="text" id="dtrefere" name="dtrefere" />
			
			<label for="dtrefate"> <? echo utf8ToHtml('Data até:') ?></label>
			<input type="text" id="dtrefate" name="dtrefere" />
			
			<label for="flcritic">
				<input id="flcritic" name="flcritic" type="checkbox" />
				<? echo utf8ToHtml('Somente Críticas') ?>
			</label>
					
		</div> 	

	</fieldset>

</form>

