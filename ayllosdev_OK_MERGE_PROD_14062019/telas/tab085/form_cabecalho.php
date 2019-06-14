<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Jonata - Mouts                                                     
	 Data : Agosto/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da TAB085.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
	
?>

<form id="frmCabTab085" name="frmCabTab085" class="formulario cabecalho" style="display:none;">	
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
    <option value="C" selected> C - Consultar par&acirc;metros</option>
    
    <?php
		echo ($glbvars["cdcooper"] == 3 ?  '<option value="A"> A - Alterar par&acirc;metros </option>' : '');
		echo ($glbvars["cdcooper"] == 3 ?  '<option value="H"> H - Hor&aacute;rio agendamento </option>' : '');
	?>
    
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>