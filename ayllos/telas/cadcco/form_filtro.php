<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Jonathan - RKAM
	 Data : Feveveiro/2016                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da CADCCO.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
		
?>


<form name="frmFiltro" id="frmFiltro" class="formulario" >
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

			
		<label for="nrconven"><? echo utf8ToHtml('Conv&ecirc;nio:') ?></label>
		<input type="text" id="nrconven" name="nrconven" >
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			

	</fieldset>

</form>	

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="consultaParametros();return false;">Prosseguir</a>	

</div>


