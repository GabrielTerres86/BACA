<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Formulario de consulta da Tela BANCOS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *			  	  09/09/2016 - Alterado layout e incluido novos campos: flgoppag, dtaltstr e dtaltpag. 
 *                			    PRJ-312 (Reinert)
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<form id="frmConsulta" name="frmConsulta" class="formulario">
	
	<div id="divConsulta" >		
		<fieldset style="margin-top: 10px">		
			<div style="padding: 2px">
				<label for="nmresbcc">Nome Abreviado:</label>
				<input id="nmresbcc" maxlength="15" name="nmresbcc" type="text" value="<?echo getByTagName($registro->tags,'nmresbcc');?>"/>
				</br>
				<label for="nmextbcc">Nome Extenso:</label>
				<input id="nmextbcc" maxlength="35" name="nmextbcc" type="text"/>
				</br>
				<label for="nrcnpjif">CNPJ:</label>
				<input id="nrcnpjif" maxlength="25" name="nrcnpjif" type="text"/>
			</div>
		</fieldset>
		<fieldset style="margin-top: 10px">
			<legend align="center" > SPB - Sistema de Pagamento Brasileiro </legend>
			<div>
				<label for="flgdispb">Operando com SPB-STR:</label>
				<select id="flgdispb" name="flgdispb" onchange="controlaSitSPB();">	
					<option value="1" >SIM</option>
					<option value="0" selected>NAO</option>
				</select>
				
				<label for="dtinispb">In&iacute;cio em:</label>
				<input id="dtinispb" name="dtinispb" type="text"/>
				
				<label for="dtaltstr">&Uacute;ltima altera&ccedil;&atilde;o</label>
				<input id="dtaltstr" name="dtaltstr" type="text" disabled />
				
				</br>
				
				<label for="flgoppag">Operando com SPB-PAG:</label>		
				<select id="flgoppag" name="flgoppag">	
					<option value="1" >SIM</option>
					<option value="0" selected>NAO</option>
				</select>
				
				<label for="dtaltpag">&Uacute;ltima altera&ccedil;&atilde;o</label>
				<input id="dtaltpag" name="dtaltpag" type="text" disabled />
				
			</div>
		</fieldset>		
		<br style="clear:both" />
		
	</div>
	
</form>
