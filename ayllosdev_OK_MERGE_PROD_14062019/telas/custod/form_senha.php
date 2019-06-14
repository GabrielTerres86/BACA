<?php
/*!
 * FONTE        : form_senha.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/10/2011
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

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onclick="validarSenha(); return false;" >Ok</a>
</div>