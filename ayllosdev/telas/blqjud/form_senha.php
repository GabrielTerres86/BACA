<?php
/*!
 * FONTE        : form_senha.php
 * CRIAÇÃO      : Jorge Hamaguchi (CECRED)
 * DATA CRIAÇÃO : 11/06/2013
 * OBJETIVO     : Formulario senha
 * --------------
 * ALTERACOES   : 10/12/2014 - Ajustes de controle de acesso dos operadores
 * 							   Adicionado chamada da funcao BuscaSenha().
 * 							   (Jorge/Rosangela) - SD 228463
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
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

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
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar();fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="validarSenha(); return false;">Ok</a>
</div>