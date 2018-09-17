<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann 
 * DATA CRIAÇÃO : 17/03/2016
 * OBJETIVO     : Cabeçalho para a tela CONPRO
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario">

    <label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="C"> C - Consultar Proposta</option> 
        <option value="R"> R - Relatorio Proposta</option> 
		<option value="A"> A - Consultar Acionamento</option>
    </select>

    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos();
            return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />	

</form>