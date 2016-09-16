<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : David Kruger      
 * DATA CRIA��O : 22/02/2013
 * OBJETIVO     : Cabe�alho para a tela RELSEG
 * --------------
 * ALTERA��ES   : 
 *				  
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
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C"> C - Consultar par�metros de comiss�o dos seguros  </option> 
					<option value="A"> A - Alterar par�metros de comiss�o dos seguros </option>
					<option value="R"> R - Relat�rios dos seguros Auto, Vida e Residencial </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>	
	</table>
</form>