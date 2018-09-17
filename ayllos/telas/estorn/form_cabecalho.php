<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : 14/09/2015
 * OBJETIVO     : Cabe�alho para a tela ESTORN
 * --------------
 * ALTERA��ES   : 02/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  
 * --------------
 */	
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
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
                    <option value='C'>C - Consultar Estornos</option>
					<option value='E'>E - Estornar Pagamentos</option>
					<option value='R'>R - Relat�rio</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>