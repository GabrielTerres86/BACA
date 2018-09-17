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
					<option value="C"> C - Consultar Vinculo Tarifa x Programas </option>
					<option value="I"> I - Incluir Sigla Tarifa/Parametro </option>
					<option value="A"> A - Alterar Sigla Tarifa/Parametro </option>
					<option value="V"> V - Vincular Tarifa x Programas </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cdbattar"><? echo utf8ToHtml('Sigla:') ?></label>
				<input type="text" class="campo alphanum" id="cdbattar" name="cdbattar" value="<? echo $cdbattar == 0 ? '' : $cdbattar ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="nmidenti" id="nmidenti"  value="<? echo $nmidenti; ?>" />				
			</td>
		</tr>		
        <tr>		
			<td>
				<label for="tpcadast"><? echo utf8ToHtml('Tipo:') ?></label>				
				<select id="tpcadast" name="tpcadast">
					<option value="0">Selecione</option>
					<option value="1">Tarifa</option>
					<option value="2">Parametro</option>
				</select>								
				<label for="cdprogra"><? echo utf8ToHtml('Programa:') ?></label>
				<input type="text" id="cdprogra" name="cdprogra" value="<? echo $cdprogra == 0 ? '' : $cdprogra?>" />	
			</td>			
		</tr>				
	</table>
</form>
