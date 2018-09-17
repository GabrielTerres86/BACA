<?php
/*!
 * FONTE        : form_opcao.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 26/07/2013
 * OBJETIVO     : Formulário de opcões para a tela ADMISS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */		

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php'); 
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form name="frmOpcao" id="frmOpcao" class="formulario" onSubmit="return false;" style="display:none">	
	
	<fieldset>
		<legend style="margin-left: 5px; padding: 0px 2px;">Dados do Extrato</legend>
		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="0" />
		<label for="dtdemiss" id="dtdemiss2" name="dtdemiss2">A partir de:</label>
		<input type="text" id="dtdemiss" name="dtdemiss"  value="<? echo $dtdemiss ?>" />
		<label for="qtadmtot">Total:</label>
		<input type="text" id="qtadmtot" name="qtadmtot" value="0" />
	</fieldset>		
			
</form>

<form name="frmImp" id="frmImp" class="formulario" style="display:none">	

	<input type="hidden" id="cddopcao1" name="cddopcao1" />	
	<input type="hidden" id="numdopac1" name="numdopac1" />	
	<input type="hidden" id="dtdecons1" name="dtdecons1" />	
	<input type="hidden" id="dtatecon1" name="dtatecon1" />	
	
	<fieldset>
		<legend style="margin-left: 5px; padding: 0px 2px;">Associados Novos</legend>
		<label for="numdopac">PA:</label>
		<input type="text" id="numdopac" name="numdopac" value="19" />
		<label for="dtdecons">De:</label>
		<input type="text" id="dtdecons" name="dtdecons" value="" />
		<label for="dtatecon">At&eacute;:</label>
		<input type="text" id="dtatecon" name="dtatecon" value="" />
	</fieldset>		
			
</form>

