<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 07/02/2017
 * OBJETIVO     : Cabeçalho para a tela CADFRA
 * --------------
 * ALTERAÇÕES   : 
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
                    <option value='C'>C - Consultar parâmetros</option>
					<option value='A'>A - Alterar parâmetros</option>
					<option value='E'>E - Excluir parâmetros</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>		
	</table>
</form>