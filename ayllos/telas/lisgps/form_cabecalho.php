<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Setembro/2015
 * OBJETIVO     : Mostrar tela LISGPS
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" alt="Escolha uma op&ccedil;&atilde;o">
		<option value="C">C - Consultar Pagamentos de GPS</option>
		<option value="S">S - Salvar Arquivo XML</option>
		<option value="V">V - Visualizar Pagamentos GPS</option>
	</select>
	<a href="#" class="botao" id="btnOK" style="float:none;" >OK</a>
	
	<br style="clear:both" />
	
</form>