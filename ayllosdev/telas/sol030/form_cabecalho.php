<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Lombardi						Última Alteração: 14/06/2017
 * DATA CRIAÇÃO : 19/07/2016
 * OBJETIVO     : Cabeçalho para a tela IMPPRE
 * --------------
 * ALTERAÇÕES   : 14/06/2017 - Ajuste para inclusão da opção de prazo para desligamento (Jonata - RKAM P364).
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
					<option value='C'>C - Consulta Calculo Sobras</option>
					<option value='A'>A - Altera Calculo Sobras</option>
                    <option value='D'>D - Consulta Data Informativo</option>
                    <option value='G'>G - Gerar TED Capital Rateio Juros e Sobras</option>
					<option value='I'>I - Altera Data Informativo</option>
					<option value='P'>P - Prazo para Desligamento</option>
					<option value='V'>V - Valor M&iacute;nimo Para Remessa De Capital Via TED</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
