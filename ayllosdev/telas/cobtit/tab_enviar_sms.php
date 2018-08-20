<?php
/* !
 * FONTE        : enviar_sms.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 06/06/2018
 * OBJETIVO     : Rotina para montar tela enviar e-mail.
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X",false)) <> "") {
	exibeErro($msgError);		
}	

function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$lindigit = (isset($_POST['lindigit'])) ? $_POST['lindigit'] : '0';

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "    <lindigit>" . $lindigit . "</lindigit>";
$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "COBTIT", "BUSCAR_TEXTO_SMS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getClassXML($xmlResult);
$root = $xmlObj->roottag;
// Se ocorrer um erro, mostra crítica
if ($root->erro){
    echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Ayllos","hideMsgAguardo();");';
    exit;
}
$texto = $root->dados->textosms;
?>

<form id="frmEnviarSMS" name="frmEnviarSMS" class="formulario" onSubmit="return false;" >

    <br style="clear:both" />		
    <label for="nrdddtfc"><?php echo utf8ToHtml('DDD:') ?></label>
    <input type="text" id="nrdddtfc" class="campo navigation" name="nrdddtfc" value="<?php echo $nrdddtfc == 0 ? '' : $nrdddtfc ?>" />	

    <label for="nrtelefo"><?php echo utf8ToHtml('Celular:') ?></label>
    <input type="text" id="nrtelefo" class="campo navigation" name="nrtelefo" value="<?php echo $nrtelefo == 0 ? '' : $nrtelefo ?>" />	
    <a style="padding: 3px 0 0 3px;" href="#" onClick="pesquisaCelular(); return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>		

    <label for="nmpescto"><?php echo utf8ToHtml('Contato:') ?></label>
    <input type="text" id="nmpescto" class="campo navigation" name="nmpescto" value="<?php echo $nmpescto == 0 ? '' : $nmpescto ?>" />	

    <br style="clear:both" />	
    <br style="clear:both" />	

    <textarea name="textosms" id="textosms" cols="100" rows="6" readonly="true" onClick="highlight();" ><?php echo $texto; ?></textarea>

    <br style="clear:both" />	

</form>

<div id="divBotoesEnviarEmail" style="margin-bottom: 5px; margin-top: 10px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btCopiar"  	onClick="<?php echo 'copiarTextoSMS(); '; ?> return false;">Copiar Texto</a>
    <a href="#" class="botao" id="btEnviar"  	onClick="<?php echo 'validaEnvioSMS(); '; ?> return false;">Enviar SMS</a>
</div>

<script type="text/javascript">
    highlightObjFocus($('#frmEnviarSMS'));
    controlafrmEnviarSMS();
</script>
