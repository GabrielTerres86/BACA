<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Julho/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da LCREDI.                                  
	                                                                  
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
    <option value="I"><? echo utf8ToHtml('I - Incluir') ?></option>
    <option value="A"><? echo utf8ToHtml('A - Alterar') ?></option>
    <option value="B"><? echo utf8ToHtml('B - Bloquear') ?></option>
    <option value="L"><? echo utf8ToHtml('L - Liberar') ?></option>
		<option value="E"><? echo utf8ToHtml('E - Excluir') ?></option>
    <option value="C"><? echo utf8ToHtml('C - Consultar') ?></option>
    <option value="F"><? echo utf8ToHtml('F - Consultar finalidades') ?></option>
    <option value="P"><? echo utf8ToHtml('P - Consultar coeficiente para presta&ccedil;&atilde;o') ?></option>
  </select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
