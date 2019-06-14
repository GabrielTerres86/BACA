<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Cria��o      : Jonata - RKAM
  Data cria��o : Maio/2017
  Objetivo     : Cabe�alho para a tela MOVRGP
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

<form id="frmCabMovrgp" name="frmCabMovrgp" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="A"> A - Alterar </option>
		<option value="C" selected> C - Consultar </option>
		<option value="E"> E - Excluir </option>
		<option value="F"> F - Fechamento do per&iacute;odo de digita&ccedil;&atilde;o</option>
		<option value="I"> I - Incluir </option>
		<option value="J"> J - Importar </option>
		<option value="L"> L - Exportar </option>
		<option value="R"> R - Reabertura do per&iacute;odo de digita&ccedil;&atilde;o  </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>