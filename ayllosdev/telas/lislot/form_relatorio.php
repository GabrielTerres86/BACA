<?php
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Formulario da opçao I da Tela LISLOT
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

<form id="frmRelatorio" name="frmRelatorio" class="formulario">
		<div id="divRelatorio" >
		
		<label for="tpdopcao"><? echo utf8ToHtml('Tipo:') ?></label>
		<select id="tpdopcao" name="tpdopcao">
			<option value="1" selected><? echo utf8ToHtml('Cooperado')?> </option>
			<option value="2" ><? echo utf8ToHtml('Caixa') ?> </option>
			<option value="3" ><? echo utf8ToHtml('Lote P/PA') ?> </option>
		</select>
		
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input id="cdagenci" name="cdagenci" type="text"/>
	
		<label for="cdhistor"><? echo utf8ToHtml('Historico:') ?></label>
		<input id="cdhistor" name="cdhistor" type="text"/>
						
		<label for="nrdconta"><? echo utf8ToHtml('Conta/Dv:') ?></label>
		<input id="nrdconta" name="nrdconta" type="text"/>
		
		<label for="dtinicio"><? echo utf8ToHtml('Data Inicial:') ?></label>
		<input id="dtinicio" name="dtinicio" type="text"/>
		
		<label for="dttermin"><? echo utf8ToHtml('Data Final:') ?></label>
		<input id="dttermin" name="dttermin" type="text"/>
		
		<label for="nmdopcao"><? echo utf8ToHtml('Saída:'); ?></label>
		<select id="nmdopcao" name="nmdopcao">
			<option value="yes">Arquivo</option>
			<option value="no">Impressao</option>
		</select>
				
					
		<br style="clear:both" />
		
	</div>
</form>


