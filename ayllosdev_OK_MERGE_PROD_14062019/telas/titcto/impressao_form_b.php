<?php 

	/************************************************************************
		Fonte: impressao_form_b.php
		Autor: Alex Sandro
		Data : Abril/2018                 Última Alteração: 09/04/2018

		Objetivo  : Formulario para geração dos arquivos PDF

	
	  ************************************************************************/
?>	  
<form name="frmImprimirBorderoNaoLiberadoTitcto" id="frmImprimirBorderoNaoLiberadoTitcto" action="<?php echo $UrlSite; ?>telas/titcto/imprimir_dados_titcto_b.php" method="post">
	<input type="hidden" name="dtiniper" id="dtiniper" value="">
	<input type="hidden" name="dtfimper" id="dtfimper" value="">
	<input type="hidden" name="cdagenci" id="cdagenci" value="">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="nrborder" id="nrborder" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	