<?php
/*!
 * FONTE        : form_cadmsp.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/09/2017
 * OBJETIVO     : Formulario de consulta da Tela CADMSP
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

?>

<form id="frmCadmsp" name="frmCadmsp" class="formulario" style="display: none">
	
	<div id="divMotivos" style="display: none">
		<fieldset style="margin-top: 10px">
			<legend> Motivos Saque Parcial </legend>
			<div/>
		</fieldset>
	</div>
	
	<div id="divDetalhes" style="display: none">
		<fieldset style="margin-top: 10px">
			<legend> Detalhes </legend>
			<label for="cdmotivo">C&oacute;digo:</label>
			<input type="text" id="cdmotivo"/>
			
			<label for="dsmotivo">Motivo:</label>
			<input type="text" id="dsmotivo"/>
			
			<label for="flgpessf">Pessoa F&iacute;sica:</label>
			<input type="checkbox" id="flgpessf" style="margin: 3px 0px 3px 3px !important; height: 20px !important;"/>
			
			<label for="flgpessj">Pessoa Jur&iacute;dica:</label>		
			<input type="checkbox" id="flgpessj" style="margin: 3px 0px 3px 3px !important; height: 20px !important;"/>
			
		</fieldset>
	</div>
</form>
