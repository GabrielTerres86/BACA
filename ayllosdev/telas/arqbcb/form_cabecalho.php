<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Lunelli         
 * DATA CRIA��O : 13/03/2014
 * OBJETIVO     : Cabecalho para a tela ARQCAB
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmBcb" name="frmBcb" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="E"> E - Enviar Arquivo </option>
					<option value="R"> R - Receber Arquivo </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cddarqui"><? echo utf8ToHtml('Tipo:') ?></label>
				<select id="cddarqui" name="cddarqui" style="width: 460px;">
					<option value="A"> Saldo dispon�vel dos Associados </option>
					<option value="C"> Solicita��o de Cart�o </option>
					<!-- <option value="D"> Concilia��o de D�bitos </option> -->
				</select>
			</td>
		</tr>		
	</table>
</form>