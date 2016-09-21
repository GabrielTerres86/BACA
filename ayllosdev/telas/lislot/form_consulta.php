<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Formulario de Listagem dos históricos da Tela LISLOT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmConsulta" name="frmConsulta" class="formulario">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		<div id="divConsulta" >
		
			<label for="tpdopcao"><? echo utf8ToHtml('Tipo:') ?></label>
			<select id="tpdopcao" name="tpdopcao">
				<option value="COOPERADO" selected><? echo utf8ToHtml('Cooperado')?> </option>
				<option value="CAIXA" ><? echo utf8ToHtml('Caixa') ?> </option>
				<option value="LOTE P/PA" ><? echo utf8ToHtml('Lote P/PA') ?> </option>
			</select>
			
			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input id="cdagenci" name="cdagenci" type="text"/>
		
			<label for="cdhistor"><? echo utf8ToHtml('Historico:') ?></label>
			<input id="cdhistor" name="cdhistor" type="text" />
							
			<label for="nrdconta"><? echo utf8ToHtml('Conta/Dv:') ?></label>
			<input id="nrdconta" name="nrdconta" type="text"/>
			
			<br style="clear:both" />
			
			<label for="dtinicio"><? echo utf8ToHtml('Data Inicial:') ?></label>
			<input id="dtinicio" name="dtinicio" type="text"/>
			
			<label for="dttermin"><? echo utf8ToHtml('Data Final:') ?></label>
			<input id="dttermin" name="dttermin" type="text"/>
			
			<input type="hidden" name="dtmvtolt" id="dtmvtolt" type="hidden" value="" />
			<input type="hidden" name="nmprimtl" id="nmprimtl" type="hidden" value="" />
			<input type="hidden" name="nrdocmto" id="nrdocmto" type="hidden" value="" />
			<input type="hidden" name="vllanmto" id="vllanmto" type="hidden" value="" />
			
								
						
		</div>
		
		<div id="divSaida" >
			
			<label for="nmdopcao"><? echo utf8ToHtml('Saída:'); ?></label>
			<select id="nmdopcao" name="nmdopcao">
				<option value="yes">Arquivo</option>
				<option value="no">Impressao</option>
			</select>
			
			<br style="clear:both" />
			
		</div>
		
	</fieldset>
	
</form>

<br style="clear:both" />
<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="dtmvtolt" id="dtmvtolt" type="hidden" value="" />
	<input type="hidden" name="tpdopcao" id="tpdopcao" type="hidden" value="" />
	<input type="hidden" name="nmarqimp" id="nmarqimp" type="hidden" value="" />
</form>
