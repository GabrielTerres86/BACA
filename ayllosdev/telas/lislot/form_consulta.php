<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Formulario de Listagem dos históricos da Tela LISLOT
 * --------------
 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                
 *                11/11/2016 - Ajustes referente ao chamado 492589. (Kelvin)
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmConsulta" name="frmConsulta" class="formulario">
	
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		<div id="divConsulta" >
		
			<label for="tpdopcao">Tipo:</label>
			<select id="tpdopcao" name="tpdopcao">
				<option value="COOPERADO" selected>Cooperado</option>
				<option value="CAIXA" >Caixa</option>
				<option value="LOTE P/PA" >Lote P/PA</option>
			</select>
			
			<label for="cdagenci">PA:</label>
			<input id="cdagenci" name="cdagenci" type="text"/>
		
			<label for="cdhistor">Hist&oacute;rico:</label>
			<input id="cdhistor" name="cdhistor" type="text" />
							
			<label for="nrdconta">Conta/Dv:</label>
			<input id="nrdconta" name="nrdconta" type="text"/>
			
			<br style="clear:both" />
			
			<label for="dtinicio">Data Inicial:</label>
			<input id="dtinicio" name="dtinicio" type="text"/>
			
			<label for="dttermin">Data Final:</label>
			<input id="dttermin" name="dttermin" type="text"/>
			
			<input type="hidden" name="dtmvtolt" id="dtmvtolt" type="hidden" value="" />
			<input type="hidden" name="nmprimtl" id="nmprimtl" type="hidden" value="" />
			<input type="hidden" name="nrdocmto" id="nrdocmto" type="hidden" value="" />
			<input type="hidden" name="vllanmto" id="vllanmto" type="hidden" value="" />
			
								
						
		</div>
		
		<div id="divSaida" >
			
			<label for="nmdopcao">Sa&iacute;da:</label>
			<select id="nmdopcao" name="nmdopcao">
				<option value="yes">Arquivo</option>
				<option value="no">Impressao</option>
			</select>
			
			<br style="clear:both" />
			
		</div>
		
	</fieldset>
	
</form>

<br style="clear:both" />
