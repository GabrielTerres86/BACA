<? 
/*!
 * FONTE        : form_cadret.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 27/08/2013 
 * OBJETIVO     : Form da tela CADRET
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div>
<form id="frmcadret" name="frmcadret" style="display:none" class="formulario" onsubmit="return false;">
	<fieldset>
	<legend>Produto</legend>
	<table width="100%">
		<tr>		
			<td>
				<label for="cdprodut">Produto:</label>
				<select id="cdprodut" name="cdoperac" style="width: 200px;">
					<option value="1">1 - Gravames</option>
					<option value="3">3 - Aliena&ccedil;&atilde;o de Im&oacute;veis</option>
				</select>
				<a href="#" class="botao" id="btnOK2" name="btnOK2" onClick="liberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
	</fieldset>

	<fieldset id="FS_RETORNO">
	<legend>Cadastro de Retorno</legend>
	<table width="100%">
		<tr  id="tr_cdoperac">		
			<td>
				<label for="cdoperac">Opera&ccedil;&atilde;o:</label>
				<select id="cdoperac" name="cdoperac" style="width: 200px;">
					<option value="I">I - Inclus&atilde;o</option>
					<option value="Q">Q - Quita&ccedil;&atilde;o</option>
					<option value="C">C - Cancelamento</option>
					<option value="M">M - Manuten&ccedil;&atilde;o</option>
				</select>
			</td>
		</tr>
		<tr id="tr_nrtabela">		
			<td>
				<label for="nrtabela">Tabela:</label>
				<select id="nrtabela" name="nrtabela" style="width: 200px;">
					<option value="1">1</option>
					<option value="2">2</option>
					<option value="3">3</option>
					<option value="4">4</option>
				</select>
			</td>
		</tr>
		<tr id="tr_cdretorn">		
			<td>
				<label for="cdretorn">C&oacute;digo:</label>
				<input type="text" id="cdretorn" name="cdretorn" value="<? echo $cdretorn ?>" />
			</td>
		</tr>
		<tr id="tr_dsretorn">		
			<td>
				<label for="dsretorn">Descri&ccedil;&atilde;o:</label>
				<input type="text" id="dsretorn" name="dsretorn" value="<? echo $dsretorn ?>" />
			</td>
		</tr>
	</table>
	</fieldset>
</form>
</div>