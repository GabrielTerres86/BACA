<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 
 * OBJETIVO     : Cabecalho para a tela CADSGR
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar Sub-grupo </option> 
					<option value="A"> A - Alterar Sub-grupo </option>
					<option value="E"> E - Excluir Sub-grupo </option>
					<option value="I"> I - Incluir Sub-grupo </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cddgrupo"><? echo utf8ToHtml('Grupo:') ?></label>
				<input type="text" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsdgrupo" id="dsdgrupo"  value="<? echo $dsdgrupo; ?>" />
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cdsubgru"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdsubgru" name="cdsubgru" value="<? echo $cdsubgru == 0 ? '' : $cdsubgru ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dssubgru" id="dssubgru"  value="<? echo $dssubgru; ?>" />
			</td>
		</tr>		
	</table>
</form>