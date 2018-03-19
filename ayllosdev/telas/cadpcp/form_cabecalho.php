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
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

    <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar porcentagem do pagador.</option>
        <option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?>>A - Alterar porcentagem do pagador.</option>
    </select>

    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>