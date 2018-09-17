<?
/*!
 * FONTE        : form_vincula_tarifa.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 20/04/2013
 * OBJETIVO     : Form de vinculacao de tarifas
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="divDadosTarifa" name="divDadosTarifa">
	<form id="frmDadosTarifa" name="frmDadosTarifa" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset width="100%">
			<legend>Dados da Tarifa</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="cdtarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
						<input type="text" id="cdtarifa" name="cdtarifa" value="<? echo $cdtarifa == 0 ? '' : $cdtarifa ?>" />	
						<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
						<input type="text" name="dstarifa" id="dstarifa"  value="<? echo $dstarifa; ?>" />				
					</td>
				</tr>		
				<tr>		
					<td>
						<label for="tppessoa"><? echo utf8ToHtml('Aplicavel a:') ?></label>
						<select id="tppessoa" name="tppessoa">
							<option value="0">Selecione Tipo de Pessoa</option>
							<option value="1">Pessoa fisica</option>
							<option value="2">Pessoa juridica</option>
						</select>						
						<input type="hidden" id="inpessoa" name="inpessoa" value="<? echo $inpessoa == 0 ? '' : $inpessoa ?>" />	
					</td>			
				</tr>				
				<tr>		
					<td>
						<label for="dsdgrupo"><? echo utf8ToHtml('Grupo:') ?></label>
						<input type="text" id="dsdgrupo" name="dsdgrupo" value="<? echo $dsdgrupo == 0 ? '' : $dsdgrupo ?>" />		
						<input type="hidden" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>" />	
					</td>			
				</tr>							
				<tr>		
					<td>
						<label for="dssubgru"><? echo utf8ToHtml('Subgrupo:') ?></label>
						<input type="text" id="dssubgru" name="dssubgru" value="<? echo $dssubgru == 0 ? '' : $dssubgru ?>" />		
						<input type="hidden" id="cdsubgru" name="cdsubgru" value="<? echo $cdsubgru == 0 ? '' : $cdsubgru ?>" />	
					</td>			
				</tr>										
				<tr>		
					<td>
						<label for="dscatego"><? echo utf8ToHtml('Categoria:') ?></label>
						<input type="text" id="dscatego" name="dscatego" value="<? echo $dscatego == 0 ? '' : $dscatego ?>" />		
						<input type="hidden" id="cdcatego" name="cdcatego" value="<? echo $cdcatego == 0 ? '' : $cdcatego ?>" />	
					</td>			
				</tr>													
			</table>
		</fieldset>
	</form>
</div>