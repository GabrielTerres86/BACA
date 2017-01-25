<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Lombardi
 * DATA CRIA��O : 19/07/2016
 * OBJETIVO     : Cabe�alho para a tela IMPPRE
 * --------------
 * ALTERA��ES   : 
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
                    <option value='I'>I - Importar Carga</option>
					<option value='B'>B - Bloquear Carga</option>
					<option value='L'>L - Liberar Carga</option>
					<option value='E'>E - Excluir Carga</option>
					<option value='A'>A - Alterar Carga</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>