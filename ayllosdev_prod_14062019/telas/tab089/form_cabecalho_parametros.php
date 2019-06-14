<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIA��O      : Mateus Zimmermann - Mouts
 * DATA CRIA��O : 12/01/2018
 * OBJETIVO     : Cabe�alho para a tela TAB089 aba Parametros
 * ALTERA��O    : 22/08/2018 - PJ 438 - Alterado o nome do fonte para form_cabecalho_parametros - Mateus Z (Mouts)
 */
?>

<form id="frmCab" name="frmCab" class="formulario">
    <label for="cddopcao">Op&ccedil;&atilde;o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Par�metros de Opera��es de Cr�dito</option>
        <option value="A">A - Alterar Par�metros de Opera��es de Cr�dito</option>
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
