<?php
/*
 * FONTE            : form_cabecalho.php
 * CRIAÇÃO          : Daniel Zimmermann
 * DATA CRIAÇÃO     : 14/09/2015			
 * OBJETIVO         : Cabeçalho para a tela CONLDB
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" >	

    <label for="cddopcao">Op&ccedil;&atilde;o:</label>
    <select id="cddopcao" name="cddopcao">
        <option value="A"> A - Arquivos</option> 
        <option value="C"> C - Contas</option>
    </select>

    <a href="#" class="botao" id="btnOK" onClick="controlaOpcao();
            return false;" style="text-align: right;">OK</a>

    <br style="clear:both" />	

</form>

<div id="divCdcooper" >
    <input type="hidden" id="cdcooper" name="cdcooper" value=" <?php echo $glbvars["cdcooper"] ?>" />
</div>

