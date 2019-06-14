<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado Flor         
 * DATA CRIAÇÃO : 27/02/2013
 * OBJETIVO     : Cabecalho para a tela CADTIC
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
					<option value="C"> C - Consultar tipo de categoria </option> 
					<option value="A"> A - Alterar tipo de categoria </option>
					<option value="E"> E - Excluir tipo de categoria </option>
					<option value="I"> I - Incluir tipo de categoria </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cdtipcat"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdtipcat" name="cdtipcat" value="<? echo $cdtipcat == 0 ? '' : $cdtipcat ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dstipcat" id="dstipcat"  value="<? echo $dstipcat; ?>" />				
			</td>
		</tr>		
	</table>
</form>