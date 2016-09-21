<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Cristian Filipe Fernandes        
 * DATA CRIA��O : Novembro/2013						�ltima altera��o: 25/11/2014
 * OBJETIVO     : Cabecalho para a tela CLDMES
 * --------------
 * ALTERA��ES   : 25/11/2014 - Ajustes para libera��o (Adriano).
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C' selected>C - Consultar movimenta��es</option>
					<option value='F'>F - Realizar fechamento</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
																	
</form>