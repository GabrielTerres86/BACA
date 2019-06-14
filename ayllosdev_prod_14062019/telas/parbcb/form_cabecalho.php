<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Jean Michel         
 * DATA CRIA��O : 08/04/2014
 * OBJETIVO     : Cabecalho para a tela PARBCB
 * PROJETO		: Projeto de Novos Cart�es Bancoob
 * --------------
 * ALTERA��ES   : 05/08/2014 - alterado para '/usr/connect/bancoob' (Lunelli)
 *
 *                05/12/2016 - P341-Automatiza��o BACENJUD - Utilizar o c�digo 
 *                             do departamento no lugar da descri��o (R.Darosci)
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
<input type="hidden" id="hdndepar" name="hdndepar" value="<?php echo $glbvars['cddepart']; ?>" />
	<table width="100%">
		<tr>		
			<td colspan="2"> 	
				<label for="tparquiv"><? echo utf8ToHtml('Tipo arquivo:') ?></label>
				<select id="tparquiv" name="tparquiv" onChange="mudaOpcao();">
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="efetuarConsulta('C'); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="nrseqarq"><? echo utf8ToHtml('Sequencia:') ?></label>
				<input type="text" id="nrseqarq" name="nrseqarq" value="" />
			</td>
			<td>
				<input type="checkbox" id="flgretpr" name="flgretpr" value="1" />
				<label for="flgretpr"><? echo utf8ToHtml('Retorno processado') ?></label>
			</td>
		</tr>			
		<tr>		
			<td colspan="2">
				<label for="dtultint"><? echo utf8ToHtml('&Uacute;ltima integra&ccedil;&atilde;o:') ?></label>
				<input type="text" id="dtultint" name="dtultint" value="" />
			</td>
		</tr>		
		<tr>		
			<td colspan="2">
				<label for="dsdirarq"><? echo utf8ToHtml('Diret&oacute;rio:') ?></label>			    
				<input type="text" id="dsdirarq" name="dsdirarq" value=""  />
			</td>
		</tr>
	</table>
</form>