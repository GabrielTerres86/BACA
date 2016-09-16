<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 
 * OBJETIVO     : Cabecalho para a tela CADCAT
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;"  style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar Categoria </option> 
					<option value="A"> A - Alterar Categoria </option>
					<option value="E"> E - Excluir Categoria </option>
					<option value="I"> I - Incluir Categoria </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cddgrupo">Grupo:</label>
				<input type="text" name="cddgrupo" id="cddgrupo" />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dsdgrupo" id="dsdgrupo"  value="<? echo $dsdgrupo; ?>" />				
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdsubgru">Sub-grupo:</label>
				<input type="text" name="cdsubgru" id="cdsubgru">
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dssubgru" id="dssubgru"  value="<? echo $dssubgru; ?>" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdtipcat">Tipo:</label>
				<input type="text" name="cdtipcat" id="cdtipcat" />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" name="dstipcat" id="dstipcat"  value="<? echo $dstipcat; ?>" />				
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdcatego"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdcatego" name="cdcatego" value="<? echo $cdcatego == 0 ? '' : $cdcatego ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(4);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dscatego" id="dscatego"  value="<? echo $dscatego; ?>" />
			</td>
		</tr>		
	</table>
</form>