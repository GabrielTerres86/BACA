<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Criação      : Jonata - Mouts
  Data criação : Maio/2017
  Objetivo     : Cabeçalho para a tela PARRGP
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

<form id="frmCabParrgp" name="frmCabParrgp" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="A"> A - Alterar </option>
		<option value="C" selected> C - Consultar </option>
		<option value="E"> E - Excluir </option>
		<option value="I"> I - Incluir </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>