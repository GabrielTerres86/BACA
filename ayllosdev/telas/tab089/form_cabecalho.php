<?php
/* 
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Diego Simas/Reginaldo Silva/Let�cia Terres - AMcom
 * DATA CRIA��O : 12/01/2018
 * OBJETIVO     : Cabe�alho para a tela TAB089
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
