<?php
/* 
 * FONTE        : form_cabecalho_motivos.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Cabeçalho para a tela TAB089 aba Motivos
 */
?>

<form id="frmCab" name="frmCab" class="formulario">
    <label for="cddopcao">Op&ccedil;&atilde;o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar</option>
        <option value="I">I - Incluir</option>
        <option value="A">A - Alterar</option>
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
