<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Moreira
 * DATA CRIAÇÃO : 04/09/2013
 * OBJETIVO     : Cabecalho para a tela PRMDPV
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:b">
	<table width="100%">
		<tr>		
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='opcao'>
					<option value='BT'>T - Tarifas por Canal</option>
					<option value='BC'>C - Custo Bilhete por Exercício</option>
				</select>	
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "consultaInicial();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>													
</form>