<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Lombardi						�ltima Altera��o: 14/06/2017
 * DATA CRIA��O : 19/07/2016
 * OBJETIVO     : Cabe�alho para a tela IMPPRE
 * --------------
 * ALTERA��ES   : 14/06/2017 - Ajuste para inclus�o da op��o de prazo para desligamento (Jonata - RKAM P364).
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
