<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da ATURAT.                                  
	                                                                  
	 Alterações: 
	 --------------
	 [24/04/2019] Luiz Otávio Olinger Momm - AMCOM: Opção R: Desabilitar opção. Os relatórios serão migrados para o BI (Product Backlog Item 18540:Tratamento tela Aturat)
	 [23/05/2019] Luiz Otávio Olinger Momm - AMCOM: Opção R: Habilitado apenas para a central Ailos (coop 3)

	 
	
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
		<? if ($glbvars["cdcooper"] == 3) { ?>
		<option value="R"> <? echo utf8ToHtml('R - Relatorio ratings') ?> </option>
		<? } ?>
		<option value="L"> <? echo utf8ToHtml('L - Atualiza&ccedil;&atilde;o da nota do cooperado') ?> </option>
	</select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
