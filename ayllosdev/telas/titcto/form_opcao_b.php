<? 
/*!
 * FONTE        : form_opcao_b.php
 * CRIACAO      : Alex Sandro - (GFT)
 * DATA CRIACAO : 09/04/2018
 * OBJETIVO     : Formulario que apresenta a opção para imprimir borderos não liberados, referente a opção B da tela TITCTO
 * --------------
 * ALTERAÇÕES   :  23/05/2018 - Insert da validação da permissão para tela - Vitor Shimada Assanuma (GFT)
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
	
	include('form_cabecalho.php');
	
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $_POST['cddopcao'], false)) <> '') {
	    exibirErro('error', $msgError, 'Alerta - Ayllos', 'estadoInicial()', true);
	}
?>

<form id="frmOpcao" class="formulario">

	<input type="hidden" id="cddopcao" name="cddopcao" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> <? echo utf8ToHtml('Relatório de borderôs não liberados'); ?> </legend>

		<label for="dtiniper"><? echo utf8ToHtml('Data Digitação De:*'); ?></label>
		<input type="text" id="dtiniper" name="dtiniper" value="<?php echo $dtiniper ?>" />

		<label for="dtfimper"><? echo utf8ToHtml('Até:*'); ?></label>
		<input type="text" id="dtfimper" name="dtfimper" value="<?php echo $dtfimper ?>" />

		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>" />

		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta ?>" />

		<label for="nrborder"><? echo utf8ToHtml('Borderô:'); ?></label>
		<input type="text" id="nrborder" name="nrborder" value="<?php echo $nrborder ?>" />
	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>



<?php 
    // Forms com os dados para fazer a chamada da geração de PDF    
    include("impressao_form_b.php");
?>