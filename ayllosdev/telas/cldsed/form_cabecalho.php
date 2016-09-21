<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO : Novembro/2013
 * OBJETIVO     : Cabecalho para a tela CLDSED
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'>C - Consultar movimentacoes de creditos diarios dos cooperados</option>
					<option value='F'>F - Realizar o fechamento das mov. de creditos diarios dos coop.just</option>
					<option value='J'>J - Alterar e cadastrar justificativas sobre as mov de cred. diarios dos coop.</option>
					<option value='X'>X - Desfazer o fechamento das mov. de creditos diarios dos coop. just</option>
				    <option value='P'>P - Consultar com maiores detalhes as movimentacoes dos cooperados.</option>
					<option value='T'>T - Listar movimentacoes realizadas por colaboradores do Sistema.</option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick = "LiberaFormulario();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
																	
</form>

