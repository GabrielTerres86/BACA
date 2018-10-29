<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Cabeçalho para a tela ESTORN
 * --------------
 * ALTERAÇÕES   : 02/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  03/08/2018 - Criado a opção para estornar o pagamento de Prejuízo de Conta Corrente
 *				               PRJ 450 - Diego Simas - AMcom  
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
					<option value='R'><?php echo utf8_decode('R - Relatório'); ?></option>					
					<option value='CCT'><?php echo utf8_decode('C - Consultar Estorno Pagamento de Prejuízo C/C'); ?></option>
					<option value='ECT'><?php echo utf8_decode('E - Estornar Pagamento de Prejuízo C/C'); ?></option>
					<option value='RCT'><?php echo utf8_decode('R - Relatório Estorno Pagamento de Prejuízo C/C'); ?></option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>