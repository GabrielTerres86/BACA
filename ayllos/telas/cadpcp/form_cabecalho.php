<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 15/03/2018
 * OBJETIVO     : Cabeçalho para CADPCP
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


	// Carrega permissões do operador
	include("../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);


?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

    <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar porcentagem do pagador.</option>
		<? if (in_array('A', $glbvars['opcoesTela'])) { ?>
			<option value="A">A - Alterar porcentagem do pagador</option>
		<? } ?>

    </select>

    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>