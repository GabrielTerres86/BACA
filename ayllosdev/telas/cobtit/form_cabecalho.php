<?php
/*
 * FONTE            : form_cabecalho.php
 * CRIAÇÃO          : Luis Fernando (GFT)
 * DATA CRIAÇÃO     : 21/05/2018
 * OBJETIVO         : Cabeçalho para a tela COBTIT
 * --------------
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], '@',false)) <> '') {
	echo '<script>';
	echo '$(document).ready(function(){';
	echo 'showError("error","'.utf8ToHtml($msgError).'","Alerta - Ayllos","","NaN");';
    echo '});';
	echo '</script>';
	exit();
}

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" >
    
    <label for="cddopcao">Op&ccedil;&atilde;o:</label>
    <select id="cddopcao" name="cddopcao">
		<? if($glbvars["cdcooper"]==3){/*Aqui deve acontecer apenas se for cooperativa 3*/?>
			<option value="Y">Y - Boletagem Massiva</option> 
		<? } 
		else{ ?>
	        <option value="C"> C - Criar Cobran&ccedil;a</option> 
	        <option value="M"> M - Manuten&ccedil;&atilde;o da Cobran&ccedil;a</option>
        <? } ?>
    </select>

    <a href="#" class="botao" id="btnOK" onClick="controlaOpcao();return false;" style="text-align: right;">OK</a>

    <br style="clear:both" />

</form>