<?php
	
	//************************************************************************//
	//*** Fonte: rating_formulario_impressao.php                           ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   �ltima Altera��o: 11/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar formul�rio para impress�o do rating         ***//	
	//***                                                                  ***//
	//*** Altera��es: 11/07/2012 - Retirado campo "redirect" popup. (Jorge)***//	
	//************************************************************************//	
		
?>
<form action="<?php echo $UrlSite; ?>includes/rating/rating_imprimir.php" name="frmImprimirRating" id="frmImprimirRating" method="post">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	