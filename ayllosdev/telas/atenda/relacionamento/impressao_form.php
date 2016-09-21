<?php 

	/************************************************************************
		Fonte: impressao_form.php
		Autor: Guilherme
		Data : Outubro/2009                 Ultima Alteracao: 09/07/2012

		Objetivo  : Formulario para gera&ccedil;&atilde;o dos arquivos PDF

	    Alteracoes: 09/07/2012 - Retirado campo "redirect" popup (Jorge).
	  ************************************************************************/
?>	  
<form name="frmImprimirRelacion" id="frmImprimirRelacion" action="<?php echo $UrlSite; ?>telas/atenda/relacionamento/imprimir_dados_relacionamento.php" method="post">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="rowidedp" id="rowidedp" value="">
	<input type="hidden" name="rowididp" id="rowididp" value="">
	<input type="hidden" name="idimpres" id="idimpres" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	