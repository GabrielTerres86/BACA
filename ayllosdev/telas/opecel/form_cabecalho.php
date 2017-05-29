<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/01/2017
 * OBJETIVO     : Cabecalho para a tela OPECEL
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
					<option value="C"> C - Consultar operadoras </option> 
					<option value="A"> A - Alterar operadoras </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>				
				<label for="cdoperadora">Operadora:</label>		
				<input id="cdoperadora" name="cdoperadora" type="text"/>
				<a style="padding: 3px 0 0 3px;" id="btLupaOpe" >
					<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/>
				</a>	
				<input id="nmoperadora" name="nmoperadora" type="text"/>
				
			</td>
		</tr>
	</table>
</form>