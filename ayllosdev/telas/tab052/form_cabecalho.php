<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Leonardo de Freitas Oliveira - GFT
 * DATA CRIAÇÃO : 25/01/2018
 * OBJETIVO     : Cabeçalho para a tela TAB052
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario">

    <label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C"><?php echo utf8ToHtml('C - Consultar Par&acirc;metros Desconto de Títulos') ?></option>                
        <option value="A"><?php echo utf8ToHtml('A - Alterar Par&acirc;metros Desconto de Títulos') ?></option>           
    </select>

    <label for="tpcobran"><? echo utf8ToHtml('Tipo Cobrança:') ?></label>
    <select id="tpcobran" name="tpcobran">       
        <option value="1"><?php echo utf8ToHtml('Registrada') ?></option>                
        <option value="0"><?php echo utf8ToHtml('Sem Registro') ?></option>           
    </select>

    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />

</form>