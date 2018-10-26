<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 15/06/2017
 * OBJETIVO     : Cabeçalho para a tela PREJU
 * --------------
 * ALTERAÇÕES   : 03/01/2017: Confirmação de estorno. Andrey Formigari - Mouts
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
                    <option value='C'>E - Estorno da transferência a preju&iacute;zo</option>
					<option value='P'>P - For&ccedil;ar envio empr&eacute;stimo para preju&iacute;zo</option>	
					<option value='F'>F - For&ccedil;ar envio de conta corrente para preju&iacute;zo</option>	
                    <option value='I'>I - Importar arquivo: for&ccedil;ar envio para preju&iacute;zo</option>					
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form> 