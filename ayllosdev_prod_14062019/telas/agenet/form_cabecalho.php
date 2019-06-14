<?php
	/*!
	 * FONTE        : form_cabecalho.php								Última alteração: 25/04/2016
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 17/11/2015
	 * OBJETIVO     : Cabecalho para a tela AGENET
	 * --------------
	 * ALTERAÇÕES   : 25/04/2016 - Ajuste para atender as solicitações do projeto M 117 (Adriano - M117).
     *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	 *				 
	 */
	 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">
	<table width="100%">
		<tr>
			<td>
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select class="campo" id="cddopcao" name="cddopcao">
					<option value="T" selected><? echo ("T - Visualizar os agendamentos") ?></option> 
					<option value="C"><? echo ("C - Cancelar agendamentos") ?></option> 
					<option value="I"><? echo ("I - Imprimir os agendamentos") ?></option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
