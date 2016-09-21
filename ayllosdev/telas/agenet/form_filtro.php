<?php
	/*!
	 * FONTE        : form_filtro.php
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 17/11/2015
	 * OBJETIVO     : Apresenta o formulário com os filtros para pesquisa
	 * --------------
	 * ALTERAÇÕES   :  
	 * --------------
	 */
	 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltro">
		
			<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
			<input id="nrdconta" name="nrdconta" type="text" ></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					
			<label for="insitlau"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
			<select class="campo" id="insitlau" name="insitlau">
				<option value="0" selected><? echo utf8ToHtml("Todos") ?></option> 
				<option value="1" ><? echo utf8ToHtml("Pendentes") ?></option> 
				<option value="2" ><? echo utf8ToHtml("Efetivados") ?></option> 
				<option value="3" ><? echo utf8ToHtml("Cancelados") ?></option> 
				<option value="4" ><? echo utf8ToHtml("N&atilde;o Efetivados") ?></option> 
			</select>					
			
			<label for="dtiniper"><? echo utf8ToHtml('Data Inicial:') ?></label>
			<input type="text" id="dtiniper" name="dtiniper"/>
			
			<label for="dtfimper"><? echo utf8ToHtml('Data Final:') ?></label>
			<input type="text" id="dtfimper" name="dtfimper"/>
								
		</div>
		
		<div id="divArquivo" style="display:none;">
		
			<label for="tipsaida"><? echo utf8ToHtml('Formato de Sa&iacute;da:') ?></label>
			<select class="campo" id="tipsaida" name="tipsaida">
				<option value="0"><? echo utf8ToHtml("Arquivo") ?></option> 
				<option value="1" selected><? echo utf8ToHtml("Impress&atilde;o") ?></option> 
			</select>
			
			<label for="nmarquiv"><? echo utf8ToHtml('Diret&oacute;rio:    /micros/' . $glbvars["dsdircop"] . '/') ?></label>
			<input type="text" id="nmarquiv" name="nmarquiv" value="" />
			
			<br style="clear:both" />				
								
		</div>
				
	</fieldset>
		
</form>