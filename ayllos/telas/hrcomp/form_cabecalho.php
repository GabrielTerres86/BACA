<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 24/02/2014
 * OBJETIVO     : Cabecalho para a tela HRCOMP
 * --------------
 * ALTERAÇÕES   : 11/10/2016 - Acesso da tela HRCOMP em todas cooperativas SD381526 (Tiago/Elton)
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
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar  </option> 
					<option value="A"> A - Alterar  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="acessoOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>