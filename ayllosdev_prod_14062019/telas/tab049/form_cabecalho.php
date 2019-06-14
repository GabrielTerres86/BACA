<?php
/* 
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Márcio(Mouts)
 * DATA CRIAÇÃO : 08/2018
 * OBJETIVO     : Cabeçalho para a tela TAB049
 */
?>

<form id="frmCab" name="frmCab" class="formulario">
    <label for="cddopcao">Op&ccedil;&atilde;o</label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C">C - Consultar Par&acirc;metros de Seguro</option>                
        <option value="A">A - Alterar Par&acirc;metros de Seguro</option>           
    </select>    
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />
</form>
