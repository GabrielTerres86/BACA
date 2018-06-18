<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIA��O      : Helinton Steffens - (Supero)
 * DATA CRIA��O : 13/03/2018 
 * OBJETIVO     : Formulario para conciliar uma ted.
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	//include('form_cabecalho.php');
?>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_extrato_consolidado_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">		
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>





