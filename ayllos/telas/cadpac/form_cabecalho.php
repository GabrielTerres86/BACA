<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/07/2016
 * OBJETIVO     : Cabeçalho para a tela CADPAC
 * --------------
 * ALTERAÇÕES   : 
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
                    <option value='C'>C - Consultar cadastro do PA</option>
                    <option value='I'>I - Incluir cadastro de PA</option>
					<option value='A'>A - Alterar cadastro do PA</option>
					<option value='B'>B - Cadastramento de caixas para o PA</option>
					<option value='X'>X - Incluir/Alterar valor limite comite local</option>
					<option value='S'>S - Dados para o site da cooperativa</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>		
	</table>
</form>