<?php
/*
  Fonte        : form_cabecalho.php
  Cria��o      : Mateus Zimmermann - Mouts
  Data cria��o : Abril/2018
  Objetivo     : Cabe�alho para a tela REPEXT
  --------------
	Altera��es   : 
  --------------
*/ 

?>

<form id="frmCabRepext" name="frmCabRepext" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consulta </option>
		<option value="D"> D - Manter Tipo Declarado </option>
		<option value="P"> P - Manter Tipo Propriet�rio </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>