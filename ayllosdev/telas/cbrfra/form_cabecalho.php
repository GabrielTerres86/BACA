<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O     	: Rodrigo Bertelli (RKAM)        
 * DATA CRIA��O : Junho/2014
 * OBJETIVO     : Cabecalho para a tela CBRFRA
  */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<table width="99%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar C�digos com Fraude</option>
					<option value='I'>I - Incluir C�digos com Fraude</option>
					<option value='E'>E - Excluir C�digos com Fraude</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "liberaCampos();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>