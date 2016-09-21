<?php
	
	//************************************************************************//
	//*** Fonte: rating_formulario_impressao.php                           ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   Última Alteração: 11/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar formulário para impressão do rating         ***//	
	//***                                                                  ***//
	//*** Alterações: 11/07/2012 - Retirado campo "redirect" popup. (Jorge)***//	
	//************************************************************************//	
		
?>
<form action="<?php echo $UrlSite; ?>includes/rating/rating_imprimir.php" name="frmImprimirRating" id="frmImprimirRating" method="post">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	