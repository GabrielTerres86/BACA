<?
/*****************************************************************
  Fonte        : form_cabecalho.php
  Criação      : Adriano
  Data criação : Outubro/2011
  Objetivo     : Cabeçalho para a tela CADLNG
  --------------
  Alterações   :
  --------------
 ****************************************************************/ 
?>

<form id="frmCabCadlng" name="frmCabCadlng" class="formulario cabecalho">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" alt="Informe a op&ccedil;&atilde;o desejada ( C, E ou I).">
		<option value=""> 	 </option>
		<option value="C"> C </option> 
		<option value="E"> E </option>
		<option value="I"> I </option>
		
	</select>
	
	<input type="image" src="http://dwebayllos.cecred.coop.br/imagens//botoes/ok.gif" onclick="estadoInicial(); limpaCampos(); tipoOpcao();return false;">
	
	<br style="clear:both" />	

</form>