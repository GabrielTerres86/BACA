<?php
	/*
	* FONTE            : form_cabecalho.php
	* CRIAÇÃO          : Lucas Reinert/Daniel Zimmermann
	* DATA CRIACAO     : Julho/2015						ULTIMA ALTERACAO : 01/08/2016
	* OBJETIVO         : Cabeçalho para a tela COBEMP
	* --------------
	* ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" >
    
    <label for="cddopcao">Op&ccedil;&atilde;o:</label>
    <select id="cddopcao" name="cddopcao">
        <option value="C"> C - Contratos</option> 
        <option value="M"> M - Manuten&ccedil;&atilde;o da Cobran&ccedil;a</option>
    </select>

    <a href="#" class="botao" id="btnOK" onClick="controlaOpcao();return false;" style="text-align: right;">OK</a>

    <br style="clear:both" />	

</form>

