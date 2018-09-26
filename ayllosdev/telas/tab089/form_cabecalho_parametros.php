<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Cabeçalho para a tela TAB089 aba Parametros
 * ALTERAÇÃO    : 22/08/2018 - PJ 438 - Alterado o nome do fonte para form_cabecalho_parametros - Mateus Z (Mouts)
 */
?>

<form id="frmCab" name="frmCab" class="formulario">
    <label for="cddopcao">Op&ccedil;&atilde;o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Parâmetros de Operações de Crédito</option>
        <option value="A">A - Alterar Parâmetros de Operações de Crédito</option>
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
