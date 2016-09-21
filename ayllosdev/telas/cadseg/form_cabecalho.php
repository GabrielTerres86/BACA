<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe        
 * DATA CRIAÇÃO : 19/11/2013
 * OBJETIVO     : Cabecalho para a tela CADSEG
 * --------------
 * ALTERAÇÕES   : 23/01/2014 - Ajustes gerais para liberacao. (Jorge)
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select name="cddopcao"  id="cddopcao"  class='campo' />
					<option value='C'>C - Consultar seguradora</option>
					<option value='A'>A - Alterar seguradora</option>
					<option value='I'>I - Incluir seguradora</option>
					<option value='E'>E - Excluir seguradora</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
				
</form>
