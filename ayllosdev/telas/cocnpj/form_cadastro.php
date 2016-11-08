<?
/*!
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 08/09/2016
 * OBJETIVO     : CADASTRO para a tela COCNPJ
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
				<label for="inpessoa"><? echo utf8ToHtml('Tipo Pessoa:') ?></label>
				<input type="radio" class="radio" id="inpessoa1" name="inpessoa" value="1" checked> 
				<label for="inpessoa1" class="radio txtNormalBold tipoinpessoa"><? echo utf8ToHtml('Fisica') ?></label>
				<input type="radio" class="radio" id="inpessoa2" name="inpessoa" value="2" style="margin-left:10px;"> 
				<label for="inpessoa2" class="radio txtNormalBold tipoinpessoa"><? echo utf8ToHtml('Juridica') ?></label>				
			</td>			
		</tr>	
		<tr>		
			<td> 	
				<label for="nrcpfcgc"><? echo utf8ToHtml('CNPJ:') ?></label>
				<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<? echo $nrcpfcgc == 0 ? '' : $nrcpfcgc ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" id="lupacnpj" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsnome" id="dsnome"  value="<? echo $dsnome; ?>" />				
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
				<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão:') ?></label>
				<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo $dtmvtolt == '' ? '' : $dtmvtolt ?>" />	
			</td>
		</tr>				
	</table>
</form>
