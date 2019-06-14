<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 14/08/2013
 * OBJETIVO     : Cabeçalho para a tela PARMON
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	*
	*				 31/10/2017 - Ajuste tela prevencao a lavagem de dinheiro - Melhoria 458 (junior Mouts)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
	<input type="hidden" id="glbcoope" name="glbcoope" value="<? echo $glbvars['cdcooper'] ?>" />
	<input type="hidden" id="glbdtmvt" name="glbdtmvt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<table width="100%">
		<tr>		
			<td>
				<label for="cddopcaoFP">Tipo</label>
				<select id="cddopcaoFP" name="cddopcaoFP" style="width: 200px;">
					<option value="F">F - Fraudes</option> 
					<option value="P">P - PLD</option> 
				</select>
				<a href="#" class="botao" id="btnOKFP" name="btnOKFP" onClick="liberaCamposFraudePLD(); return false;" style = "text-align:right;">OK</a>	
			</td>
		</tr>
		<tr id ="cdlinhaopcao" style="display:none;">
			<td>						
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 200px;">
					<option value="A">A - Alterar par&acirc;metros de monitoramento</option> 
					<option value="C">C - Consultar par&acirc;metros de monitoramento</option> 
					<option value="AP">A - Alterar par&acirc;metros de controle de lavangem de dinheiro</option> 
					<option value="CP">C - Consultar par&acirc;metros de controle de lavagem de dinheiro</option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="liberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>