<?php 

	//************************************************************************//
	//*** Fonte: form_impressao.php                                        ***//
	//*** Autor: Lucas R                                                   ***//
	//*** Data : Junho/2013                 �ltima Altera��o: 12/08/2013   ***//
	//***                                                                  ***//
	//*** Objetivo  : Imprimir dados da tabela crapblj                     ***//
	//***                                                                  ***//	 
	//*** Altera��es: 12/08/2013 - Altera��o da sigla PAC para PA. (Carlos)***//
	//***			   			              	                           ***//
	//***		                 	   			  					       ***//
	//***																   ***//
	//***			                                                       ***//
	//************************************************************************//	

	
?>

<div id="divOpcaoR" style="display:none;"  >
<form id="frmOpcaoR" class="formulario" name="frmOpcaoR" >

	<fieldset>
		<legend>Impress�o Bloqueio</legend>
		
		<label for="agenctel" >PA:</label>
		<input id="agenctel" name="agenctel" type="text" value="<? echo $agenctel ?>"/>
		<br />
			
		<label for="dtinicio">Per�odo:</label>
		<input id="dtinicio" name="dtinicio" type="text" value="<? echo $dtinicio ?>"/>
			
	    <label for="dtafinal">At�</label>
		<input type="text" name="dtafinal" id="dtafinal" value="<? echo $dtafinal ?>" />	
	
		
		<br style="clear:both" />	
		<br style="clear:both" />	
		
	</fieldset> 
	
	
</form>
</div>

