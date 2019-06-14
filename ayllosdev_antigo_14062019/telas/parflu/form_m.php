<?
/*!
 * FONTE        	: form_m.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form para a opcao M
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmParflu" name="frmParflu" class="formulario">
    <br />
    <fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px;">
    <legend> Percentuais </legend>
        <table width="100%" style="margin:5px 0 10px 15px;">
        <tr>
            <td>Margem SR Doc</td>
            <td>Margem SR Cheques</td>
            <td>Margem SR T&iacute;tulos</td>
            <td>Base de C&aacute;lculo Devolu&ccedil;&atilde;o Cheques</td>
        </tr>
        <tr>
            <td><input type="text" name="margem_doc" id="margem_doc" value="<?php echo getByTagName($xmlRegist->tags,'MARGEM_DOC'); ?>" /></td>
            <td><input type="text" name="margem_chq" id="margem_chq" value="<?php echo getByTagName($xmlRegist->tags,'MARGEM_CHQ'); ?>" /></td>
            <td><input type="text" name="margem_tit" id="margem_tit" value="<?php echo getByTagName($xmlRegist->tags,'MARGEM_TIT'); ?>" /></td>
            <td><input type="text" name="devolu_chq" id="devolu_chq" value="<?php echo getByTagName($xmlRegist->tags,'DEVOLU_CHQ'); ?>" /></td>
        </tr>
        </table>
    </fieldset>
	
</form>