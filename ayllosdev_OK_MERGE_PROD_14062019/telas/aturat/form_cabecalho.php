<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da ATURAT.                                  
	                                                                  
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
		<option value="C"> <? echo utf8ToHtml('C - Consultar ratings') ?> </option> 
		<option value="A"> <? echo utf8ToHtml('A - Alterar ratings') ?> </option>
		<option value="R"> <? echo utf8ToHtml('R - Relatorio ratings') ?> </option>		
		<option value="L"> <? echo utf8ToHtml('L - Atualiza&ccedil;&atilde;o da nota do cooperado') ?> </option>
	</select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
