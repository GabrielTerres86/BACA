<?php
/* !
 * FONTE        : principal.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 22/06/2012
 * OBJETIVO     : Mostrar opcao Principal da rotina de Simulação da tela ATENDA	  
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Aumentado o tamanho da tabela - Marcelo L. Pereira (GATI)
 * 001: [28/02/2018] Alterado para buscar os dados na mensageria Oracle (P438 Douglas Pagel / AMcom)
 */

session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '@';

// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', 'controlaOperacao();', false);
}

// Verifica se o número da conta foi informado
if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) {
    exibirErro('error', 'Parâmetros incorretos.', 'Alerta - Aimaro', 'fechaRotina(divRotina)', false);
}

$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];

if ($operacao == 'DIV_IMP') {
    $flgImp = 1;
    $operacao = '';
    $nrctremp = 0;
}

if (!validaInteiro($nrdconta)) {
    exibirErro('error', 'Conta/dv inválida.', 'Alerta - Aimaro', 'fechaRotina(divRotina)', false);
}
if (!validaInteiro($idseqttl)) {
    exibirErro('error', 'Seq.Ttl inválida.', 'Alerta - Aimaro', 'fechaRotina(divRotina)', false);
}

// Monta o xml de requisição
$xml = "";
$xml.= "<Root>";
$xml.= "	<Dados>";
$xml.= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml.= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml .= "		<flgerlog>1</flgerlog>";
$xml.= "	</Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_SIMULACAO", "SIMULA_BUSCA_SIMULACOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
// Cria objeto para classe de tratamento de XML
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error', $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Aimaro', 'fechaSimulacoes()', false);
}

$simulacoes = $xmlObj->roottag->tags[0]->tags;

?>
<table id="tbsimulacoes"cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="700">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11" id="tdTitTelaEmp"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag SetFoco" id="tdTitTelaSim" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">SIMULA&Ccedil;&Atilde;O</td>
                                <td width="12" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaSimulacoes(true);
                                        return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" align="center" style="border: 1px solid #969FA9; background-color: #F4F3F0; padding: 0px;">
                                    <div id="divConteudoOpcao">
                                        <form id="formImpressao" ></form>
                                        <?
                                        include("tabela_simulacoes.php"); 
                                        include("form_simulacao.php"); 
                                        ?>
                                    </div>
                                </td>
                            </tr>
                        </table>			    
                    </td> 
                </tr>
            </table>
        </td>
    </tr>
</table>