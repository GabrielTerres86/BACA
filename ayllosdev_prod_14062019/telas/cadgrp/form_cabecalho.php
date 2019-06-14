<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Jonata - Mouts                                                     
	 Data : Setembro/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da CADGRP.                                  
	                                                                  
	 Alterações: 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
	
?>

<form id="frmCabCadgrp" name="frmCabCadgrp" class="formulario cabecalho" style="display:none;">	
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="B" selected> B - Busca Grupo de Cooperado</option>
		<option value="C" selected> C - Consulta Detalhada da Distribui&ccedil;&atilde;o dos Grupos</option>
		<option value="E" selected> E - <? echo utf8ToHtml('Manutenção de Período de Edital de Assembleias') ?></option>
		<option value="P" selected> P - Par&acirc;metriza&ccedil;&atilde;o de Fra&ccedil;&otilde;es de Grupo</option>
		<option value="G" selected> G - <? echo utf8ToHtml('Consulta Geral da Distribuição dos Grupos') ?></option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>