<?
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 15/08/2013
 * OBJETIVO     : Formulário Cabeçalho - Tela FINALI
 * --------------
 * ALTERACOES   : 10/08/2015 - Alterações e correções (Lunelli SD 102123)
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
    <table width = "100%">
        <tr>
            <td>
                <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
                <select id="cddopcao" name="cddopcao">
                    <option value="C"> C - Consultar finalidades de empr&eacute;stimos cadastradas. </option>
                    <option value="A"> A - Alterar dados de finalidades de empr&eacute;stimos cadastradas. </option>
                    <option value="B"> B - Bloquear finalidades de empr&eacute;stimos cadastradas. </option>
                    <option value="L"> L - Liberar finalidades de empr&eacute;stimos bloqueadas. </option>
                    <option value="E"> E - Excluir finalidades de empr&eacute;stimos cadastradas. </option>
                    <option value="D"> D - Excluir linhas de cr&eacute;dito vinculadas &agrave; finalidade. </option>
                    <option value="I"> I - Incluir novas finalidades de empr&eacute;stimos. </option>
                </select>
                <a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;" >OK</a>
            </td>
        </tr>
        <tr>
            <td>
                <label for="cdfinemp">C&oacute;digo:</label>
                <input type="text" id="cdfinemp" name="cdfinemp" value="<?php echo $cdfinemp; ?>" alt="Informe o codigo da finalidade." />
                <label for="dsfinemp">Descri&ccedil;&atilde;o:</label>
                <input type="text" id="dsfinemp" name="dsfinemp" value="<?php echo $dsfinemp; ?>" />
            </td>
        </tr>
    </table>
</form>

<br style="clear:both" />
<div id="divResultado" style="display:block;"></div>