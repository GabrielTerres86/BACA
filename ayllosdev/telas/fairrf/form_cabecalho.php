<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Dionathan Henchel    
 * DATA CRIAÇÃO : 01/12/2015
 * OBJETIVO     : Cabecalho para a tela FAIRRF
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;"  style="display:none">
	<input type="hidden" id="glbcdcooper" name="glbcdcooper" value="<? echo $glbvars["cdcooper"] ?>" />	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<input type="hidden" id="cdtipcat" name="cdtipcat" value="<? echo $cdtipcat == 0 ? '' : $cdtipcat ?>" />	
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<? if  ( $glbvars["cdcooper"] == 3 ) { ?>
					<option value="C"> C - Consultar Faixas de IRRF </option>
					<option value="A"> A - Alterar Faixas de IRRF </option>
					<? } ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="inpessoa">Aplic&aacute;vel a:</label>
				<select name="inpessoa" id="inpessoa">
					<option value="1">Pessoa F&iacute;sica</option> 
					<option value="2">Pessoa Jur&iacute;dica</option> 
				</select>	
			</td>
		</tr>
	</table>
</form>