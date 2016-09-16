<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : Setembro/2015
 * OBJETIVO     : Mostrar tela LISGPS
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
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Escolha uma op&ccedil;&atilde;o">
		<option value="C"><? echo utf8ToHtml('C - Consultar Pagamentos de GPS') ?></option>
		<option value="V"><? echo utf8ToHtml('V - Visualizar Pagamentos GPS') ?></option>
	</select>
	<a href="#" class="botao" id="btnOK" style="float:none;" ><? echo utf8ToHtml('OK') ?></a>
	
	<br style="clear:both" />
	
</form>