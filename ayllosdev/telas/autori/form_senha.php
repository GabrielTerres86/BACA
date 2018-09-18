<?php
/*!
 * FONTE        : form_senha.php
 * CRIAÇÃO      : Lucas Ranghetti (CECRED)
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Formulario senha
 * --------------
 * ALTERACOES   : 
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

	$cddopcao 	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',true);
	}

?>

<form id="frmSenha" name="frmSenha" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Disponibilize o PinPad para o cooperado') ?></legend>
		<br />
		<label for="cddsenha">Senha:</label>
		<input name="cddsenha" id="cddsenha" type="password" maxlength="6" value=""/>
		</br>
	</fieldset>	
	</br>
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar" onclick="btCancelar(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btValidar" onclick="validarSenha(); return false;">Validar</a>
</div>