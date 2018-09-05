<?php
/* !
 * FONTE        : tab_justificativa.php
 * CRIAÇÃO      : Vitor Shimada Assanuma
 * DATA CRIAÇÃO : 04/06/2018
 * OBJETIVO     : Rotina para justificativa de baixa.
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B",false)) <> "") {
	exibeErro($msgError);
}

function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}
?>

<form id="frmJustificativa" name="frmJustificativa" class="formulario" onSubmit="return false;">
<input type="hidden">

    <br style="clear:both" />

    <fieldset>
        <legend align="left" style="font-weight:bold;">Justificativa da Baixa</legend>
        <textarea name="dsjustifica_baixa" id="dsjustifica_baixa"></textarea>
    </fieldset>

    <br style="clear:both" />

</form>

<div id="divBotoesEnviarEmail" style="margin-bottom: 5px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar" onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btEnviar" onClick="<?php echo 'validaFormJustificativa(); '; ?> return false;">Confirmar</a>
</div>