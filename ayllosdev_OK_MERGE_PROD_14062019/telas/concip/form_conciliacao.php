<?php
/* !
 * FONTE        : form_conciliacao.php
 * CRIAÇÃO      : Marcos Lucas (Mout's)
 * DATA CRIAÇÃO : 20/02/2018
 * OBJETIVO     : Form selecao periodo
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Adicionado campo de Liquidação no Filtro (PRJ 486 - Mateus Z / Mouts)
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmConciliacao" name="frmConciliacao" class="formulario" onSubmit="return false;" style="display: none">
    <label for="dtLcto"><?php echo utf8ToHtml('Data Lançamento:'); ?></label>
    <input type="text" id="dtlcto" name="dtlcto" class="campo" value="<?php echo $glbvars['dtmvtolt']; ?>"/>

    <!-- PRJ 486 -->
    <label for="credenciadorasstr">&nbsp;<?php echo utf8ToHtml('Credenciadora:'); ?></label>
    <select id="credenciadorasstr" name="credenciadorasstr" class="campo" style="min-width:100px;max-width:120px;"></select>
    <!-- Fim PRJ 486 -->

    <br style="clear:both" />
</form>

<div id="divListaConciliacao" name="divListaConciliacao" style="display:none;"></div>

<div id="divBotoesConciliacao" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;">
    <a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btConsultar" onClick="controlaOperacao('STR'); return false;">Consultar</a>
</div>
