<?php
/* !
 * FONTE        : form_direciona_solicitacao.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Form para direcionamento de contas entre a cooperativa
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
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Ayllos","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))");';
	echo '</script>';
	exit();
}

$xml = new XmlMensageria();
$xml->add('dsrowid', $dsrowid);
$xmlResult = mensageria($xml, "SOLPOR", "BUSCA_CONTAS_DEVOLUCAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErro($msgErro);
}

$contas = $xmlObj->roottag->tags[0]->tags[0]->tags;

?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">
            <table border="0" cellpadding="0" cellspacing="0" width="750">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Direcionar Solicita&ccedil;&atilde;o</td>
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
                                        <form class="formulario" id="frmDireciona">
                                            <fieldset style="margin-top:10px">
                                                <legend>Direcionar Solicita&ccedil;&atilde;o</legend>
                                                <div id="divContas">
                                                    <div class="divRegistros">
                                                        <table style="table-layout: fixed;">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width: 20px;"></th>
                                                                    <th style="width: 105px;">Cooperativa</th>
                                                                    <th style="width: 55px;">Conta</th>
                                                                    <th style="width: 85px;">CPF</th>
                                                                    <th style="width: 125px;">Nome</th>
                                                                    <th style="width: 100px;">CNPJ Empregador</th>
                                                                    <th>Nome Empregador</th>
                                                                </tr>
                                                            </thead>
                                                        </table>
                                                        <table>
                                                            <tbody>
                                                                <?php
                                                                for($i = 0, $len = count($contas); $i < $len; $i++) {
                                                                    $cdcooper = getByTagName($contas[$i]->tags,"cdcooper");
                                                                    $nmrescop = getByTagName($contas[$i]->tags,"nmrescop");
                                                                    $nrdconta = getByTagName($contas[$i]->tags,"nrdconta");
                                                                    $nrcpfcgc = getByTagName($contas[$i]->tags,"nrcpfcgc");
                                                                    $nmprimtl = getByTagName($contas[$i]->tags,"nmprimtl");
                                                                    $nrcpfemp = getByTagName($contas[$i]->tags,"nrcpfemp");
                                                                    $nmextttl = getByTagName($contas[$i]->tags,"nmextttl");
                                                                ?>
                                                                    <tr onClick="selecionarConta(this)" id="direcionamento_conta_<?=$i?>">
                                                                        <td>
                                                                            <input type="radio" name="identificador" value="<?=$i?>">
                                                                            <input type="hidden" name="cdcooper" value="<?=$cdcooper?>">
                                                                            <input type="hidden" name="nrdconta" value="<?=str_replace(".", "", $nrdconta)?>">
                                                                        </td>
                                                                        <td><? echo $cdcooper . " - " . $nmrescop?></td>
                                                                        <td><?=$nrdconta?></td>
                                                                        <td><?=$nrcpfcgc?></td>
                                                                        <td><?=$nmprimtl?></td>
                                                                        <td><?=$nrcpfemp?></td>
                                                                        <td><?=$nmextttl?></td>
                                                                    </tr>
                                                                <?php } ?>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </form>
                                    </div>
                                    <div>
                                        <table>
                                            <tr>
                                                <td width="70px" align="center"> <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); return false;">Voltar</a></td>
                                                <td width="70px" align="center"> <a href="#" class="botao" id="btContinuar" onClick="validarDirecionamentoPortabilidade('<?=$dsrowid?>'); return false;">Continuar</a></td>
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