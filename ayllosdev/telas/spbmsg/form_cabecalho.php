<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Cria��o      : Mateus Zimmermann - Mouts
  Data cria��o : Agosto/2018
  Objetivo     : Cabe�alho para a tela SPBMSG
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

<form id="frmCabSpbmsg" name="frmCabSpbmsg" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<!--<option value="C"> C - Consulta trace de mensagens </option>-->
		<option value="R" selected> R - Reenvio de mensagens </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>