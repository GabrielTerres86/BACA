<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Criação      : Adriano
  Data criação : Fevereiro/2017
  Objetivo     : Cabeçalho para a tela OCPPEP
  --------------
	Alterações   : 
  --------------
	**********************************************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCabOcppep" name="frmCabOcppep" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="A"> A - Ocupa&ccedil;&otilde;es </option>		
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>