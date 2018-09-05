<?php 

	/************************************************************************
		Fonte: impressao_form.php
		Autor: Alex Sandro
		Data : Março/2018                 Última Alteração: 13/03/2018

		Objetivo  : Formulario para geração dos arquivos PDF

	
	  ************************************************************************/
?>	  
<form name="frmImprimirLoteTitcto" id="frmImprimirLoteTitcto" action="<?php echo $UrlSite; ?>telas/titcto/imprimir_dados_titcto_l.php" method="post">
	<input type="hidden" name="dtvencto" id="dtvencto" value="">
	<input type="hidden" name="cdagenci" id="cdagenci" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	