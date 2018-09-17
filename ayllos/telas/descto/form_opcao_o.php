<? 
/*!
 * FONTE        : form_opcao_o.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 24/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao O da tela DESCTO
 * --------------
 * ALTERAÇÕES   : 01/10/2013 - Alteração da sigla PAC para PA (Carlos).
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
	
?>

<form id="frmOpcao" class="formulario">

	<input type="hidden" id="cddopcao" name="cddopcao" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> <? echo utf8ToHtml('Relatório'); ?> </legend>

		<label for="dtiniper">De:</label>
		<input type="text" id="dtiniper" name="dtiniper" value="<?php echo $dtiniper ?>" />
		<label for="dtfimper"><? echo utf8ToHtml('até'); ?></label>
		<input type="text" id="dtfimper" name="dtfimper" value="<?php echo $dtfimper ?>" />
		
		<label for="nrdconta">Conta/DV:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>" />

	</fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


