<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : 25/04/2016
 * OBJETIVO     : Cabe�alho para a tela CADRIS
 * --------------
 * ALTERA��ES   : 19/12/2017 - Inclusao de opcao L na tela (Importacao de arquivo) - Heitor (Mouts)
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
                    <option value='C'>C - Consultar Risco</option>
                    <option value='I'>I - Incluir Risco</option>
					<option value='E'>E - Excluir Risco</option>						
					<option value='L'>L - Importa&ccedil;&atilde;o de arquivo</option>						
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>		
	</table>
</form>