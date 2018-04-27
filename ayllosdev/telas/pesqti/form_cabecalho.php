<?
/*****************************************************************
  Fonte        : form_cabecalho.php
  Cria��o      : Adriano
  Data cria��o : Junho/2014
  Objetivo     : Cabe�alho para a tela PESQTI
  --------------
  Altera��es   : 17/01/2018 - Altera��es para atender o PJ406.
  --------------
 ****************************************************************/ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCabPesqti" name="frmCabPesqti" class="formulario cabecalho" style="display:none;">	
			
	<label for="cddopcao"><? echo utf8ToHtml('Op��o:') ?></label>
	<select name="cddopcao" id="cddopcao">
		<option value="C"> C - Consultar Titulos e Faturas</option>
		<option value="A"> A - Alterar Faturas</option> 
	</select>
		
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>