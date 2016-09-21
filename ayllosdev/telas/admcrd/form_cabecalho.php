<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Cabecalho para a tela ADMCRD
 * --------------
 * ALTERAÇÕES   : 25/02/2014 - Revisão e Correção (Lucas).
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
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar Administradoras Cadastradas</option>
					<option value='A'>A - Alterar Cadastro de Administradoras</option>
					<option value='I'>I - Incluir Cadastro de Administradoras</option>
					<option value='E'>E - Excluir Cadastro de Administradoras</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "liberaCampos();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>