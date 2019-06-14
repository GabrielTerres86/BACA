<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Exibe a tela de Alinea - tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923) 
 * 
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

<form id="frmAlinea" name="frmAlinea" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Informe a Alinea') ?></legend>
		<br />
		<label for="cdalinea"><? echo utf8ToHtml('C&oacute;digo da Alinea:') ?></label>
		<input name="cdalinea" id="cdalinea" type="text"/>
		<br />
	</fieldset>	
</form>

<div id="divBotoes2">
    <br />
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="proc_gera_dev(); return false;">Ok</a>
</div>