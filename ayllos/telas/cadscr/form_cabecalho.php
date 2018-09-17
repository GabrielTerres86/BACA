<?php
	/*!
	* FONTE        : form_cabecalho.php					Último ajuste: 01/08/2016
	* CRIAÇÃO      : Jéssica (DB1)
	* DATA CRIAÇÃO : 18/08/2015
	* OBJETIVO     : Cabeçalho para a tela CADINF
	* --------------
	* ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1 (Adriano).
	*				 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)	
	* --------------
	*/

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" selected>C - Consulta</option>
		<option value="B">B - Gera&ccedil;&atilde;o</option>
		<option value="L">L - Lan&ccedil;amentos</option>	
		<option value="X">X - Desfazer</option>	
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
	<div id="divCab" style="display:none"></div>
</form>


