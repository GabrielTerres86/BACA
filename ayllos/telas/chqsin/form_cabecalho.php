<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Cabecalho para a tela ADMCRD
 * --------------
 * ALTERAÇÕES   : 25/02/2014 - Revisão e Correção (Lucas).
 * --------------
 *				  16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora. 
	*				  01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 
				<label for="cdtipchq">Tipo</label>	
				<select class='campo' id='cdtipchq' name='cdtipchq'>
					<option value='O'>O - Cheques de outras institui&ccedil;&atilde;es financeiras</option>
					<option value='I'>I - Cheques internos</option>					
				</select>
				</br>
				</br>

				<label for="cddopcao" id="cddopcao">Op&ccedil;&atilde;o</label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar Cheques Sinistrados</option>
					<option value='I'>I - Incluir Cheques Sinistrados</option>
					<option value='E'>E - Excluir Cheques Sinistrados</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "liberaCampos();" style = "text-align:right;">OK</a>
			</td>
			
		</tr>
		
	</table>
</form>