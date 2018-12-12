<?php
/* !
 * FONTE        : form_reprova_solicitacao.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Grid das solicitações de portabilidade
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

$dsrowid = (!empty($_POST['dsrowid'])) ? $_POST['dsrowid'] : '';

function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","");';
	echo '</script>';
	exit();
}

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>MOTVREPRVCPORTDDCTSALR</nmdominio>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "SOLPOR", "BUSCA_DOMINIO_TBCC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibeErro($msgErro);
}

$dominios = $xmlObj->roottag->tags[0]->tags;
$dominiosDesejados = array();
?>
 
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">
            <table border="0" cellpadding="0" cellspacing="0" width="450">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Rejeitar Solicita&ccedil;&atilde;o</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="tdConteudoTela" align="center">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="return false;" class="txtNormalBold">Principal</a></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divCabecalho">
                                        <form class="formulario" id ="frmReprovacao">
                                            <fieldset style="margin-top:10px;padding:10px 0;">
                                                <legend>Rejeitar Solicita&ccedil;&atilde;o</legend>
                                                <label for="motivoPortabilidade" style="width: 105px;">Motivo:</label>
                                                <select style="" id="motivoPortabilidade" class="campo" name="motivoPortabilidade">
                                                    <option value=""></option>
                                                    <?php 
                                                        foreach ($dominios as $dominio) {
                                                            if (!in_array(getByTagName($dominio->tags, 'cddominio'), $dominiosDesejados) && count($dominiosDesejados) > 0) {
                                                                continue;
                                                            }
                                                    ?>
                                                        <option value="<?= getByTagName($dominio->tags, 'cddominio'); ?>"><?=getByTagName($dominio->tags, 'dscodigo'); ?></option> 					
                                                    <?php } ?>
                                                </select>
                                            </fieldset>
                                        </form>
                                    </div>
                                    <div>
                                        <table>
                                            <tr>
                                                <td width="70px" align="center"> <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); return false;">Voltar</a></td>
                                                <td width="70px" align="center"> <a href="#" class="botao" id="btContinuar" onClick="validarReprovacaoPortabilidade('<?=$dsrowid?>'); return false;">Continuar</a></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <br>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>