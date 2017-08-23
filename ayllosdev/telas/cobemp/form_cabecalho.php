<?php
/*
 * FONTE            : form_cabecalho.php
 * CRIAÇÃO          : Lucas Reinert/Daniel Zimmermann
 * DATA CRIACAO     : Julho/2015						ULTIMA ALTERACAO : 10/03/2017
 * OBJETIVO         : Cabeçalho para a tela COBEMP
 * --------------
 * ALTERAÇÕES       : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *
 *                    13/03/2017 - Criacao da opcao Y - Boletagem Massiva. (P210.2 - Jaison/Daniel)
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
    <?php
        // Se for CECRED
        if ($glbvars["cdcooper"] == 3) {
            ?>
            <option value="Y"> Y - Boletagem Massiva</option>
            <?php
        // Demais Cooperativas
        } else {
            ?>
            <option value="C"> C - Contratos</option> 
            <option value="M"> M - Manuten&ccedil;&atilde;o da Cobran&ccedil;a</option>
            <?php
        }
    ?>
    </select>

    <a href="#" class="botao" id="btnOK" onClick="controlaOpcao();return false;" style="text-align: right;">OK</a>

    <br style="clear:both" />	

</form>