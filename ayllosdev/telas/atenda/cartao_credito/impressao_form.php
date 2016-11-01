<?php 

	/************************************************************************
		Fonte: imprimir.php
		Autor: Guilherme
		Data : Maio/2008                      Última Alteração: 09/07/2012
		
		Objetivo  : Formulario para geração dos arquivos PDF

	    Alterações: 09/07/2012 - etirado campo "redirect" do form de impressao. (jorge)
	  ************************************************************************/
?>	  
<form name="frmImprimir" id="frmImprimir" action="<?php echo $UrlSite; ?>telas/atenda/cartao_credito/imprimir_dados.php" method="post">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">	
	<input type="hidden" name="nrctrcrd" id="nrctrcrd" value="">
	<input type="hidden" name="idimpres" id="idimpres" value="">
	<input type="hidden" name="cdadmcrd" id="cdadmcrd" value="">
	<input type="hidden" name="cdmotivo" id="cdmotivo" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	