<?php 

	/************************************************************************
		Fonte: impressao_extrato.php
		Autor: Guilherme/Supero
		Data : Agosto/2011                      �ltima Altera��o: 08/08/2016
		
		Objetivo  : Formulario para gera��o dos arquivos PDF, para Extrato
					Cecred Visa

	    Altera��es: 09/07/2012 - Retirado campo "redirect" do form. (Jorge)

		            08/08/2016 - Alterado name e id do form pois estava gerando 
					             inconsistencia de validacao de regras em virtude
								 do mesmo id de form no fonte impressao_form.
								 (Chamado 477696) - (Fabr�cio)

	  ************************************************************************/
?>	  
<form name="frmImprimirExtr" id="frmImprimirExtr" action="<?php echo $UrlSite; ?>telas/atenda/cartao_credito/imprimir_extrato.php" method="post">
	<input type="hidden" name="idimpres" id="idimpres" value="">
	
	<input type="hidden" name="nrdconta" id="nrdconta" value="">	
	<input type="hidden" name="nrcrcard" id="nrcrcard" value="">
	<input type="hidden" name="dtvctini" id="dtvctini" value="">
	<input type="hidden" name="dtvctfim" id="dtvctfim" value="">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	