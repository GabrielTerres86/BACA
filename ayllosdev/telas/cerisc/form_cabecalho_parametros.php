<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIAÇÃO      : Douglas Pagel - AMcom
 * DATA CRIAÇÃO : 06/11/2018
 * OBJETIVO     : Cabeçalho para a tela CERISC aba Parametros
 * ALTERAÇÃO    : 
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
    <label for="cddopcao">Opção</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Parâmetros Central de Risco</option>
        <option value="A">A - Alterar Parâmetros Central de Risco</option>
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
