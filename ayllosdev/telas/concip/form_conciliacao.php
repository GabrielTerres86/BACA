<?php
/* !
 * FONTE        : form_conciliacao.php
 * CRIAÇÃO      : Marcos Lucas (Mout's)
 * DATA CRIAÇÃO : 20/02/2018
 * OBJETIVO     : Form selecao periodo
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
    <br style="clear:both" />
</form>

<div id="divListaConciliacao" name="divListaConciliacao" style="display:none;" width="1000"></div>

<div id="divBotoesConciliacao" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;">
    <a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btConsultar" onClick="controlaOperacao('STR'); return false;">Consultar</a>
</div>
