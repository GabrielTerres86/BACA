<?
/*!
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 08/09/2016
 * OBJETIVO     : CADASTRO para a tela COCNAE
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

<form id="frmCadastro" name="frmCadastro" class="formulario" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cdcnae"><? echo utf8ToHtml('CNAE:') ?></label>
				<input type="text" id="cdcnae" name="cdcnae" value="<? echo $cdcnae == 0 ? '' : $cdcnae ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" id="lupacnae" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dscnae" id="dscnae"  value="<? echo $dscnae; ?>" />				
			</td>
		</tr>
		<tr>		
			<td>
				<label for="tpcnae"><? echo utf8ToHtml('Tipo CNAE:') ?></label>
				<input type="radio" class="radio" id="tpcnae0" name="tpcnae" value="0" checked> 
				<label for="tpcnae" class="radio txtNormalBold tipocnae"><? echo utf8ToHtml('Restrito') ?></label>
				<input type="radio" class="radio" id="tpcnae1" name="tpcnae" value="1" style="margin-left:10px;"> 
				<label for="tpcnae" class="radio txtNormalBold tipocnae"><? echo utf8ToHtml('Proibido') ?></label>
				
				<!--
				<label for="tpcnae"> echo utf8ToHtml('Tipo CNAE:') </label>
				<select id="tpcnae" name="tpcnae">
					<option value="0">Selecione Tipo de CNAE</option>
					<option value="1">Restrito</option>
					<option value="2">Proibido</option>
				</select>						
				-->
				
				<input type="hidden" id="incnae" name="incnae" value="<? echo $incnae == 0 ? '' : $incnae ?>" />	
			</td>			
		</tr>
		<tr>		
			<td> 	
				<label for="dsmotivo"><? echo utf8ToHtml('Motivo:') ?></label>
				<input type="text" id="dsmotivo" name="dsmotivo" value="<? echo $dsmotivo == '' ? '' : $dsmotivo ?>" />	
			</td>
		</tr>
		<tr>		
			<td> 	
				<label for="dslicenca"><? echo utf8ToHtml('Licenças:') ?></label>
				<input type="text" id="dslicenca" name="dslicenca" value="<? echo $dslicenca == '' ? '' : $dslicenca ?>" />	
			</td>
		</tr>		
		<tr>		
			<td> 	
				<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão:') ?></label>
				<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo $dtmvtolt == '' ? '' : $dtmvtolt ?>" />	
			</td>
		</tr>				
	</table>
</form>
