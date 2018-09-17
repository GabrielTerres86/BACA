<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/06/2017
 * OBJETIVO     : Cabecalho para a tela CADCUR
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar curso </option> 
					<option value="A"> A - Alterar curso </option>
					<option value="E"> E - Excluir curso </option>
					<option value="I"> I - Incluir curso </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cdfrmttl"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdfrmttl" name="cdfrmttl" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="rsfrmttl" id="rsfrmttl" />				
			</td>
		</tr>		
	</table>
</form>
<? include('form_cadcur.php'); ?>