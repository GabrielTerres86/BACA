<?php
/*!
 * FONTE        : form_senha.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 05/04/2018
 * OBJETIVO     : Formulario senha
 * --------------
 * ALTERAÇÕES   : 
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
		<legend>Digite a Senha</legend>
		<label for="operauto"><? echo utf8ToHtml('Usuário:') ?></label>
		<input name="operauto" id="operauto" type="text" />
		
		<br />
		<label for="codsenha">Senha:</label>
		<input name="codsenha" id="codsenha" type="password" />
		
	</fieldset>	
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar" onclick="fecharFormSenha(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="validarSenha(); return false;">Ok</a>
</div>