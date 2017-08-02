<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Cria��o      : Adriano - CECRED
  Data cria��o : Julho/2017
  Objetivo     : Cabe�alho para a tela CADCNA
  --------------
	Altera��es   : 
  --------------
	**********************************************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCabCadcna" name="frmCabCadcna" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consulta </option>
		<option value="A"> A - Alterar </option>
		<option value="I"> I - Incluir </option>
		<option value="E"> E - Excluir </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>