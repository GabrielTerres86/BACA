<?php 

	//************************************************************************//
	//*** Fonte: form_impressao.php                                        ***//
	//*** Autor: Lucas R                                                   ***//
	//*** Data : Junho/2013                 Última Alteração: 12/08/2013   ***//
	//***                                                                  ***//
	//*** Objetivo  : Imprimir dados da tabela crapblj                     ***//
	//***                                                                  ***//	 
	//*** Alterações: 12/08/2013 - Alteração da sigla PAC para PA. (Carlos)***//
	//***			   			              	                           ***//
	//***		                 	   			  					       ***//
	//***																   ***//
	//***			                                                       ***//
	//************************************************************************//	

	
?>

<div id="divOpcaoR" style="display:none;"  >
<form id="frmOpcaoR" class="formulario" name="frmOpcaoR" >

	<fieldset>
		<legend>Impressão Bloqueio</legend>
		
		<label for="agenctel" >PA:</label>
		<input id="agenctel" name="agenctel" type="text" value="<? echo $agenctel ?>"/>
		<br />
			
		<label for="dtinicio">Período:</label>
		<input id="dtinicio" name="dtinicio" type="text" value="<? echo $dtinicio ?>"/>
			
	    <label for="dtafinal">Até</label>
		<input type="text" name="dtafinal" id="dtafinal" value="<? echo $dtafinal ?>" />	
	
		
		<br style="clear:both" />	
		<br style="clear:both" />	
		
	</fieldset> 
	
	
</form>
</div>

