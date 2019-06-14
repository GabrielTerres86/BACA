<?php 

	/************************************************************************
		Fonte: impressao_form.php
		Autor: Alex Sandro
		Data : Março/2018                 Última Alteração: 13/03/2018

		Objetivo  : Formulario para geração dos arquivos PDF

	
	  ************************************************************************/
?>	  
<form name="frmImprimirConsultaTitcto" id="frmImprimirConsultaTitcto" action="<?php echo $UrlSite; ?>telas/titcto/imprimir_dados_titcto_c.php" method="post">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value="">
	<input type="hidden" name="nmprimtl" id="nmprimtl" value="">
	<input type="hidden" name="tpcobran" id="tpcobran" value="">
	<input type="hidden" name="flresgat" id="flresgat" value="">
	<input type="hidden" name="dtvencto" id="dtvencto" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	