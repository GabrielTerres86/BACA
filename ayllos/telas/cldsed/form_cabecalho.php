<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO : Novembro/2013
 * OBJETIVO     : Cabecalho para a tela CLDSED
 * --------------
	* ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. Corrigi a falta de acentuacao. SD 491672 (Carlos R.)
 * --------------
 */
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o</label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar movimenta&ccedil;&otilde;es de cr&eacute;ditos di&aacute;rios dos cooperados</option>
					<option value='F'>F - Realizar o fechamento das mov. de creditos di&aacute;rios dos coop.just</option>
					<option value='J'>J - Alterar e cadastrar justificativas sobre as mov de cred. di&aacute;rios dos coop.</option>
					<option value='X'>X - Desfazer o fechamento das mov. de cr&eacute;ditos di&aacute;rios dos coop. just</option>
				    <option value='P'>P - Consultar com maiores detalhes as movimenta&ccedil;&otilde;es dos cooperados.</option>
					<option value='T'>T - Listar movimenta&ccedil;&otilde;es realizadas por colaboradores do Sistema.</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
																	
</form>

