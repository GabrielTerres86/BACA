<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 28/02/2012 
 * OBJETIVO     : Formulario para integrar arquivos de cobranca da opcao I da tela COBRAN
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

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" id="cddopcao" name="cddopcao" value=""/>
	<input type="hidden" id="nmarqpdf" name="nmarqpdf" value=""/>

	<fieldset>
		<legend></legend>	
		<input type="text" id="nmarqint" name="nmarqint" value="<?php echo $nmarqint ?>"/>
	</fieldset>		
	
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


