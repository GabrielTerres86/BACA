<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIA��O : Mar�o/2018
 * OBJETIVO     : Cabecalho para a tela PARDBT (Parametriza��o do Debirador �nico 
 *                - Execu��o Emergencial de Processos)
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="E"> E - Executar  </option> 
					<option value="H"> H - Hist�rico  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="acessoOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>