<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Junho/2018
  Objetivo     : Cabeçalho para a tela CONJOB
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

<form id="frmCabConjob" name="frmCabConjob" class="formulario cabecalho" style="display:none;">		
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="P" selected> P - Par&acirc;metros Gerais </option>
		<option value="C"> C - Consulta </option>
		<option value="I"> I - Incluir </option>
		<option value="E"> E - Excluir </option>
		<option value="A"> A - Alterar </option>
		<option value="L" selected> L - LOG das Execu&ccedil;&otilde;es </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>