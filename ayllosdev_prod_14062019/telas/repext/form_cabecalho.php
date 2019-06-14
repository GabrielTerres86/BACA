<?php
/*
  Fonte        : form_cabecalho.php
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Abril/2018
  Objetivo     : Cabeçalho para a tela REPEXT
  --------------
	Alterações   : 
  --------------
*/ 

?>

<form id="frmCabRepext" name="frmCabRepext" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consulta </option>
		<option value="D"> D - Manter Tipo Declarado </option>
		<option value="P"> P - Manter Tipo Proprietário </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>