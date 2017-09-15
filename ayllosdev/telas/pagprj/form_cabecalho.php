<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 15/06/2017
 * OBJETIVO     : Cabeçalho para a tela PAGPRJ
 * --------------
 * ALTERAÇÕES   : 
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
                    <option value='C'>C - Consultar Pagamentos preju&iacute;zo</option>
					<!--<option value='F'>F - For&ccedil;ar pagamento preju&iacute;zo conta corrente</option>-->
					<option value='P'>P - For&ccedil;ar pagamento preju&iacute;zo empr&eacute;stimo</option>	                    
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form> 