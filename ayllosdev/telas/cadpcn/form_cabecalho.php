<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Cristian Filipe        
 * DATA CRIA��O : 19/11/2013
 * OBJETIVO     : Cabecalho para a tela CADSEG
 * --------------
 * ALTERA��ES   : 23/01/2014 - Ajustes gerais para liberacao. (Jorge)
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select name="cddopcao"  id="cddopcao"  class='campo' />
					<option value="I"><? echo ("I - Incluir um valor m�ximo de limite para o CNAE") ?></option>
					<option value="C" selected="selected"><? echo ("C - Consultar o c�digo CNAE e o valor cadastrado") ?></option>
					<option value="A"><? echo ("A - Alterar o valor m�ximo cadastrado para o c�digo CNAE") ?></option>
					<option value="AE"><? echo ("E - Excluir o valor m�ximo cadastrado para um c�digo CNAE") ?></option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
				
</form>
