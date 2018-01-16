<?php
/* 
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Diego Simas/Reginaldo Silva/Letícia Terres - AMcom
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Cabeçalho para a tela TAB089
 */
?>

<form id="frmCab" name="frmCab" class="formulario">
    <label for="cddopcao">Op&ccedil;&atilde;o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Par&acirc;metros Op. Taxas Pr&eacute;-fixadas</option>                
        <option value="A">A - Alterar Par&acirc;metros Op. Taxas Pr&eacute;-fixadas</option>           
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
