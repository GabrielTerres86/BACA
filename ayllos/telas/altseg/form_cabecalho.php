<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe	       
 * DATA CRIAÇÃO : 16/09/2013
 * OBJETIVO     : Cabecalho para a tela ALTSEG
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:b">
	<table width="100%">
		<tr>		
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='opcao'>
					<option value='C'>C - Consultar planos de seguros</option>
					<option value='I'>I - Incluir planos de seguros</option>
				    <option value='A'>A - Alterar planos de seguros</option>
				</select>	
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>													
</form>