<?php
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Formulário de Senha
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

<form id="frmSenha" name="frmSenha" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Digite a Senha') ?></legend>
		<br />
		<label for="cddsenha">Senha:</label>
		<input name="cddsenha" id="cddsenha" type="password" />
		<br />
	</fieldset>	
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina'));mostraBanco(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="grava_processo_solicitacao(); return false;">Ok</a>
</div>