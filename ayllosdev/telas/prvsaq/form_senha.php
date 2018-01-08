<?php
/*!
 * FONTE        : form_senha.php
 * CRIAÇÃO      : Douglas Quisinski (CECRED)
 * DATA CRIAÇÃO : 09/05/2014
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
		<legend><? echo utf8ToHtml('Digite a Senha') ?></legend>
		<label for="operauto">Coordenador:</label>
		<input name="operauto" id="operauto" type="text" />
		
		<br />
		<label for="codsenha">Senha:</label>
		<input name="codsenha" id="codsenha" type="password" />
		
	</fieldset>	
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="validarSenha(); return false;">Ok</a>
</div>