<?php 

	/************************************************************************
		Fonte: impressao_form_dscchq.php
		Autor: Guilherme
		Data : Março/2009                     Última Alteração: 09/07/2012

		Objetivo  : Formulario para geração dos arquivos PDF

	    Alterações: 21/09/2010 - Ajuste para enviar impressoes via email para 
	*			                 o PAC Sede (David).
	*
	*				09/07/2012 - Retirado campo "redirect" popup (Jorge).
	*************************************************************************/
?>	  
<form name="frmImprimir" id="frmImprimir" action="<?php echo $UrlSite; ?>telas/atenda/descontos/cheques/imprimir_dados_dscchq.php" method="post">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nrctrlim" id="nrctrlim" value="">
<input type="hidden" name="nrborder" id="nrborder" value="">
<input type="hidden" name="idimpres" id="idimpres" value="">
<input type="hidden" name="limorbor" id="limorbor" value="">
<input type="hidden" name="flgemail" id="flgemail" value="">
<input type="hidden" name="flgrestr" id="flgrestr" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	