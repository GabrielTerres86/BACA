<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 09/04/2014
 * OBJETIVO     : Cabecalho para a tela TRNBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 01/07/2014 - Inclusão do checkbox Movimenta C/C (Lucas Lunelli)
 * 				  11/08/2014 - Remoção de parâmetros (Lucas Lunelli)
 *				  18/01/2016 - Remover historico do form (Lucas Ranghetti #385886 Melhoria 157)
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
			<td colspan="2" > 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" onChange="mudaOpcao();">
					<option value="A" >A - Alterar V&iacute;nculo Transa&ccedil;&atilde;o Bancoob X Hist&oacute;rico</option>
					<option value="C" >C - Consultar V&iacute;nculo Transa&ccedil;&atilde;o Bancoob X Hist&oacute;rico</option>
					<option value="E" >E - Excluir V&iacute;nculo Transa&ccedil;&atilde;o Bancoob X Hist&oacute;rico</option>
					<option value="I" >I - Incluir V&iacute;nculo Transa&ccedil;&atilde;o Bancoob X Hist&oacute;rico</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="escolheOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td colspan="2" >
				<label for="cddtrans"><? echo utf8ToHtml('Transa&ccedil;&atilde;o:') ?></label>
				<input type="text" id="cddtrans" name="cddtrans" value="" />
				<input type="text" id="dsctrans" name="dsctrans" value="" style="margin-left:30px;"/>
			</td>
		</tr>				
		<tr>		
			<td colspan="2">
				<label name="desvazio"></label>
				<input type="checkbox" id="flgdebcc" name="flgdebcc"/>
				<label name="flgdebcc" for="flgdebcc">  Movimenta C/C</label>
			</td>
		</tr>
	</table>
</form>