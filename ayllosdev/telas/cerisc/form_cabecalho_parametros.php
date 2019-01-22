<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIA��O      : Douglas Pagel - AMcom
 * DATA CRIA��O : 06/11/2018
 * OBJETIVO     : Cabe�alho para a tela CERISC aba Parametros
 * ALTERA��O    : 
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
    <label for="cddopcao">Op��o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Par�metros Central de Risco</option>
        <option value="A">A - Alterar Par�metros Central de Risco</option>
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
