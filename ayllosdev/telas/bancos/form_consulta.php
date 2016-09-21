<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Formulario de consulta da Tela BANCOS
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
	
	<div id="divConsulta" >
												
		<label for="nmresbcc"><? echo utf8ToHtml('Nome Abreviado:') ?></label>
		<input id="nmresbcc" name="nmresbcc" type="text" value="<?echo getByTagName($registro->tags,'nmresbcc');?>"/>
				
		<label for="nmextbcc"><? echo utf8ToHtml('Nome Extenso:') ?></label>
		<input id="nmextbcc" name="nmextbcc" type="text"/>		
								
		<label for="flgdispb"><? echo utf8ToHtml('Operando no SPB:') ?></label>
		
		<select id="flgdispb" name="flgdispb">	
			<option value="SIM" ><? echo utf8ToHtml('SIM')?> </option>
			<option value="NAO" selected><? echo utf8ToHtml('NAO')?> </option>
		</select>
		
		<label for="dtinispb"><? echo utf8ToHtml('Inicio da Operação:') ?></label>
		<input id="dtinispb" name="dtinispb" type="text"/>
					
		<br style="clear:both" />
		
	</div>
	
</form>
