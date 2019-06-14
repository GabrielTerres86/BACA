<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Flavio - GFT                                                     
	 Data : Julho/2018                �ltima Altera��o: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da CONSIG                                  
	                                                                  
	 Altera��es: 
	 
	 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
	
?>

<form id="frmCabecalhoConsig" name="frmCabecalhoConsig" class="formulario cabecalho frmCabecalhoConsig" style="display:none;">	
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consultar Conv&ecirc;nio </option>
		<option value="A"> A - Alterar Conv&ecirc;nio </option>
		<option value="H"> H - Habilitar Conv&ecirc;nio </option>
		<option value="D"> D - Desabilitar Conv&ecirc;nio </option>		
	</select>
	
	<a
		href="#"
		class="botao"
		id="btOK"
		style="text-align: right;">
		OK
	</a>
		
	<br style="clear:both" />	

</form>