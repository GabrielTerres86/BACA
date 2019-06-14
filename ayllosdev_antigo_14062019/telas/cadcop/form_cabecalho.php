<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Agosto/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da CADCOP.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
  
  require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
  
?>

<form name="frmCab" id="frmCab" class="formulario cabecalho" style= "display:none;">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opcao:') ?></label>
	<select id="cddopcao" name="cddopcao">
    <option value="A"><? echo utf8ToHtml('A - Alterar') ?></option>
    <option value="C"><? echo utf8ToHtml('C - Consultar') ?></option>
    <option value="M"><? echo utf8ToHtml('M - Munic&iacute;pios') ?></option>
  </select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
