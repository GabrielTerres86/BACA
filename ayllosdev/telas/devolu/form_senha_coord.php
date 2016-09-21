<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Exibe a tela de Senha - tela DEVOLU
 * --------------
 * ALTERAÇÕES   :
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

<form id="frmSenhaCoord" name="frmSenhaCoord" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Digite a Senha') ?></legend><br/>
		<label for="operauto">Coordenador:</label>
		<input name="operauto" id="operauto" type="text" />
		
		<br />
		<label for="codsenha">Senha:</label>
		<input name="codsenha" id="codsenha" type="password" />
		
	</fieldset>	
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="validarSenha();return false;">Ok</a>
</div>