<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lombardi
	 Data : Dezembro/2017                Última Alteração: 
	
	 Objetivo  : Mostrar o form do cabecalho da TIPCTA.
	
	 Alterações: 
	 
	 
	
	**********************************************************************/
  
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
  
?>

<form name="frmCab" id="frmCab" class="formulario cabecalho" style= "display:none;">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opcao:') ?></label>
	<select id="cddopcao" name="cddopcao">
    <option value="I"><? echo utf8ToHtml('I - Inclus&atilde;o de Tipos de Conta') ?></option>
    <option value="A"><? echo utf8ToHtml('A - Altera&ccedil;&atilde;o de Tipos de Conta') ?></option>
    <option value="C"><? echo utf8ToHtml('C - Consulta de Tipos de Conta') ?></option>
    <option value="E"><? echo utf8ToHtml('E - Exclus&atilde;o de Tipos de Conta') ?></option>
    <option value="T"><? echo utf8ToHtml('T - Transfer&ecirc;ncia de contas entre Tipos de Conta') ?></option>
  </select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
