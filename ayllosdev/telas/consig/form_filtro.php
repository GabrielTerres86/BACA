<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Flavio - GFT
	 Data : JULHO/2018                �ltima Altera��o: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da CONSIG.                                  
	                                                                  
	 Altera��es: 
	 
	 
	
	**********************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();	
		
?>


<form name="frmFiltroConsig" id="frmFiltroConsig" class="formulario frmFiltroConsig" >

	<input type="hidden"  name="indconsignado" id="indconsignado" value="-1" />
	<input type="hidden"  name="rowid_emp_consig" id="rowid_emp_consig" value="0" />

	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<label for="cdempres">C&oacute;digo Empresa</label>
		<input type="text" id="cdempres" name="cdempres"  class="campo"/>
		<a 
			style="padding: 3px 0 0 3px;" 
			href="#"
			id="btLupa"
			class="btLupa">
			<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
		</a>

		<a 
			href="#"
			class="botao"
			id="btOK">
			OK
		</a>

		<br style="clear:both" />

		<label for="text_indconsignado">Conv&ecirc;nio Consignado</label>
		<input
			id="text_indconsignado"
			name="text_indconsignado"
			type="text"/>

		<label for="dtativconsignado">Data:</label>
		<input type="text" id="dtativconsignado" name="dtativconsignado" class="campo"/>

	</fieldset>

</form>
<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a
		href="#"
		class="botao"
		id="btVoltar">
		Voltar
	</a>
	<a
		href="#"
		class="botao"
		id="btProsseguir">
		Prosseguir
	</a>	

</div>


