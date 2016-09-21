<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 21/02/2013
 * OBJETIVO     : Cabecalho para a tela CADGRU
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
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar grupo </option> 
					<option value="A"> A - Alterar grupo </option>
					<option value="E"> E - Excluir grupo </option>
					<option value="I"> I - Incluir grupo </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cddgrupo"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo == 0 ? '' : $cddgrupo ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dsdgrupo" id="dsdgrupo"  value="<? echo $dsdgrupo; ?>" />				
			</td>
		</tr>		
	</table>
</form>