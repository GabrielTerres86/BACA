<?php
/*!
 * FONTE        : form_opcaoE.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 15/04/2014							Última alteração: 03/12/2014
 * OBJETIVO     : Formulario da Opção E da Tela MOVTOS.
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajustes para liberação (Adriano).
 * --------------
 */ 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>


<form id="frmOpcaoE" name="frmOpcaoE" class="formulario" style="display:none">

	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		<div id="divOpcaoE" >
		
			<label for="lgvisual"><? echo utf8ToHtml('Saída:') ?></label>
			<select id="lgvisual" name="lgvisual">
				<option value="A" selected><? echo utf8ToHtml('Arquivo') ?> </option>
				<option value="I"><? echo utf8ToHtml('Impressão') ?> </option>
			</select>
							
			<br style="clear:both" />
					
		</div>
	</fieldset>
</form>


