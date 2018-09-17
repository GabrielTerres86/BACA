<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 30/04/2014
 * OBJETIVO     : Cabecalho para a tela PCAPTA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<style>
    .ui-datepicker-trigger{
        float:left;
        margin-left:6px;
        margin-top:6px;
    }

</style> 

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="border-bottom: none;" onSubmit="return false;" style="display:none">

    <table width="100%" id="tableCab" name="tableCab">
        <tr>	
            <td>
                <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
                <select id="cddopcao" name="cddopcao" style="border: 1px solid black;">
                    <option value="C" >C - Carteira de Capta&ccedil;&atilde;o</option>
                    <option value="D" >D - Defini&ccedil;&atilde;o Política de Capta&ccedil;&atilde;o</option>
                    <option value="M" >M - Modalidades dos Produtos</option>
                    <?php if ($glbvars['nvoperad'] == 3 && $glbvars['cdcooper'] == 3) { ?>
                        <option value="H" >H - Hist&oacute;ricos dos Produtos</option>
                        <option value="N" >N - Nomenclatura dos Produtos</option>
                        <option value="P" >P - Produtos de Capta&ccedil;&atilde;o</option>					
                    <?php } ?>
                </select>
                <a href="#" class="botao" id="btOK" name="btnOK" onClick="escolheOpcao($('#cddopcao').val(), 0);" style = "text-align:right;">OK</a>
                <input type="hidden" id="nvoperad" value="<?php echo $glbvars['nvoperad']; ?>" />
                <input type="hidden" id="cdcooper" value="<?php echo $glbvars['cdcooper']; ?>" />
            </td>
        </tr>
    </table>
    <div id="pcapta" name="pcapta" style="border-top: 1px solid #777777;"></div>
</form>