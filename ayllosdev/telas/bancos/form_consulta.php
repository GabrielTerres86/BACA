<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Formulario de consulta da Tela BANCOS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
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
												
		<label for="nmresbcc">Nome Abreviado:</label>
		<input id="nmresbcc" name="nmresbcc" type="text" value="<?echo getByTagName($registro->tags,'nmresbcc');?>"/>
				
		<label for="nmextbcc">Nome Extenso:</label>
		<input id="nmextbcc" name="nmextbcc" type="text"/>		
								
		<label for="flgdispb">Operando no SPB:</label>
		
		<select id="flgdispb" name="flgdispb">	
			<option value="SIM" >SIM</option>
			<option value="NAO" selected>N&Atilde;O</option>
		</select>
		
		<label for="dtinispb">Inicio da Opera&ccedil;&atilde;o:</label>
		<input id="dtinispb" name="dtinispb" type="text"/>
					
		<br style="clear:both" />
		
	</div>
	
</form>
