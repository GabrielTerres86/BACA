<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Jonathan - RKAM                                                     
	 Data : Marco/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da CADCCO.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
	
?>

<form id="frmCabCadcco" name="frmCabCadcco" class="formulario cabecalho" style="display:none;">	
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consultar par&acirc;metros</option>
		<option value="A"> A - Alterar par&acirc;metros </option>
		<option value="E"> E - Excluir conv&ecirc;nio de cobran </option>
		<option value="I"> I - Incluir par&acirc;metros </option>		
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>