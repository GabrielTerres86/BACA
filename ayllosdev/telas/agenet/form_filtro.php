<?php
	/*!
	 * FONTE        : form_filtro.php
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 17/11/2015
	 * OBJETIVO     : Apresenta o formulÃ¡rio com os filtros para pesquisa
	 * --------------
	 * ALTERAÇÕES   : 29/06/2016 - m117 Inclusao do campo tipo de transacao no filtro (Carlos)
	 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
     *			      31/11/2017 - Exibir TEDs Canceladas devido a fraude PRJ335 - Analise de fraude(Odirlei-AMcom)
	 *
	 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	

?>
<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltro">
		
			<label for="nrdconta">Conta/dv:</label>
			<input id="nrdconta" name="nrdconta" type="text" ></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<label for="cdagenci">PA:</label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					
			<label for="insitlau">Situa&ccedil;&atilde;o:</label>
			<select class="campo" id="insitlau" name="insitlau">
				<option value="0" selected>Todos</option> 
				<option value="1" >Pendentes</option> 
				<option value="2" >Efetivados</option> 
				<option value="3" >Cancelados</option> 
                <option value="31" >Cancelados por Fraude</option> <!-- 3.1 - cancelamento por suspeita de fraude -->
				<option value="4" >N&atilde;o Efetivados</option> 
			</select>

			<label for="cdtiptra">Tipo:</label>
			<select class="campo" id="cdtiptra" name="cdtiptra">
				<option value="0" selected>Todos</option> 
				<option value="1" >Transfer&ecirc;ncia Intracooperativa</option> 
				<option value="2" >Pagamentos</option> 
				<option value="3" >Capital</option> 
				<option value="4" >TED</option> 
				<option value="5" >Transfer&ecirc;ncia Intercooperativa</option> 
				<option value="10" >Pagamentos DARF/DAS</option> 
				<option value="11" id="opt_recarga">Recarga de celular</option>
			</select>

			<label for="dtiniper">Data Inicial:</label>
			<input type="text" id="dtiniper" name="dtiniper"/>
			
			<label for="dtfimper">Data Final:</label>
			<input type="text" id="dtfimper" name="dtfimper"/>
								
		</div>
		
		<div id="divArquivo" style="display:none;">
		
			<label for="tipsaida">Formato de Sa&iacute;da:</label>
			<select class="campo" id="tipsaida" name="tipsaida">
				<option value="0">Arquivo</option> 
				<option value="1" selected>Impress&atilde;o</option> 
			</select>
			
			<label for="nmarquiv"><? echo ('Diretório:    /micros/' . $glbvars["dsdircop"] . '/') ?></label>
			<input type="text" id="nmarquiv" name="nmarquiv" value="" />
			
			<br style="clear:both" />				
								
		</div>
				
	</fieldset>
		
</form>