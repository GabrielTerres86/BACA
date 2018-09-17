<? 
/*!
 * FONTE        : form_opcao_l.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 21/09/2016
 * OBJETIVO     : Formulario que apresenta a opcao L da tela DESCTO
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
	
	include('form_cabecalho.php');
	
?>

<form id="frmOpcao" class="formulario">

	<input type="hidden" id="cddopcao" name="cddopcao" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> <? echo utf8ToHtml('Relatório'); ?> </legend>

		<label for="dtiniper"><? echo utf8ToHtml('Data Digitação De:'); ?></label>
		<input type="text" id="dtiniper" name="dtiniper" value="<?php echo $dtiniper ?>" />

		<label for="dtfimper"><? echo utf8ToHtml('Até:'); ?></label>
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
