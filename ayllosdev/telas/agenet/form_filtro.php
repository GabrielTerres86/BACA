<?php
	/*!
	 * FONTE        : form_filtro.php
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 17/11/2015
	 * OBJETIVO     : Apresenta o formulÃ¡rio com os filtros para pesquisa
	 * --------------
	 * ALTERAÇÕES   :  
	 * --------------
	 
	 29/06/2016 - m117 Inclusao do campo tipo de transacao no filtro (Carlos)

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
		
			<label for="nrdconta"><? echo ('Conta/dv:') ?></label>
			<input id="nrdconta" name="nrdconta" type="text" ></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="cdagenci"><? echo ('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					
			<label for="insitlau"><? echo ('Situação:') ?></label>
			<select class="campo" id="insitlau" name="insitlau">
				<option value="0" selected><? echo ("Todos") ?></option> 
				<option value="1" ><? echo ("Pendentes") ?></option> 
				<option value="2" ><? echo ("Efetivados") ?></option> 
				<option value="3" ><? echo ("Cancelados") ?></option> 
				<option value="4" ><? echo ("Não Efetivados") ?></option> 
			</select>

			<label for="cdtiptra"><? echo ('Tipo:') ?></label>
			<select class="campo" id="cdtiptra" name="cdtiptra">
				<option value="0" selected><? echo ("Todos") ?></option> 
				<option value="1" ><? echo ("Transferência Intracooperativa") ?></option> 
				<option value="2" ><? echo ("Pagamentos") ?></option> 
				<option value="3" ><? echo ("Capital") ?></option> 
				<option value="4" ><? echo ("TED") ?></option> 
				<option value="5" ><? echo ("Transferência Intercooperativa") ?></option> 
			</select>

			<label for="dtiniper"><? echo ('Data Inicial:') ?></label>
			<input type="text" id="dtiniper" name="dtiniper"/>
			
			<label for="dtfimper"><? echo ('Data Final:') ?></label>
			<input type="text" id="dtfimper" name="dtfimper"/>
								
		</div>
		
		<div id="divArquivo" style="display:none;">
		
			<label for="tipsaida"><? echo ('Formato de Saída:') ?></label>
			<select class="campo" id="tipsaida" name="tipsaida">
				<option value="0"><? echo ("Arquivo") ?></option> 
				<option value="1" selected><? echo ("Impressão") ?></option> 
			</select>
			
			<label for="nmarquiv"><? echo ('Diretório:    /micros/' . $glbvars["dsdircop"] . '/') ?></label>
			<input type="text" id="nmarquiv" name="nmarquiv" value="" />
			
			<br style="clear:both" />				
								
		</div>
				
	</fieldset>
		
</form>