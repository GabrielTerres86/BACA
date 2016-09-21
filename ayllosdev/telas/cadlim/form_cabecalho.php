<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : 15/12/2014
 * OBJETIVO     : Cabe�alho para a tela CADLIM
 * --------------
 * ALTERA��ES   : 21/09/2016 - Inclus�o do filtro "Tipo de Limite" no cabecalho. Projeto 300. (Lombardi)
 *				  
 * --------------
 */	
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
                    <option value='C'>C - Consultar regra</option>
					<option value='A'>A - Alterar regra</option>					
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>		
		<tr>
			<td>
				<label for="tplimite">Tipo de Limite:</label>
				<select name="tplimite" id="tplimite">
					<option value="0">Selecione</option>
					<option value="1">Limite de Cr&eacute;dito</option>
					<option value="2">Limite Desconto de Cheque</option>
				</select>			
			</td>
		</tr>		
		<tr>
			<td>
				<label for="inpessoa">Tipo de Cadastro:</label>
				<select name="inpessoa" id="inpessoa">
					<option value="0">Selecione</option>
					<option value="1">Pessoa F&iacute;sica</option>
					<option value="2">Pessoa Jur&iacute;dica</option>
				</select>			
			</td>
		</tr>
	</table>
</form>