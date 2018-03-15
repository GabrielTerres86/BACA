<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 08/03/2018
 * OBJETIVO     : Cabeçalho para TITCTO
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

    <label for="cddopcao"><?php echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>
    <select id="cddopcao" name="cddopcao">
        <option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>>C - Consultar t&iacute;tulos descontados  por conta corrente ou por CPF/CNPJ.</option>
        <option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>>F - Resumo do dia das opera&ccedil;&otilde;es de desconto de t&iacute;tulos.</option>
        <option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?>>L - Imprimir listagem de lotes de desconto de t&iacute;tulos efetuados no dia.</option>
        <option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>>S - Pesquisar dados para concilia&ccedil;&atilde;o cont&aacute;bil.</option>
        <option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>>T - Pesquisar data de libera&ccedil;&atilde;o e loteamento de t&iacute;tulos.</option>
    </select>

    <a href="#" class="botao" id="btnOk1">Ok</a>
    <br style="clear:both" />	

</form>