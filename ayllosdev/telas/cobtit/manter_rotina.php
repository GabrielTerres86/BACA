<?php
/* !
 * FONTE        : manter_rotina.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 21/05/2018
 * OBJETIVO     : Rotina para manter as operações da tela COBTIT
 * ALTERAÇÃO    : 16/10/2018 - Alterado para emitir boleto de borderos em prejuizo (Cássia de Oliveira - GFT)
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();



$operacao = $_POST["operacao"];
$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : '';
$nrcpfcgc = isset($_POST["nrcpfcgc"]) ? $_POST["nrcpfcgc"] : '';
$qtregist = isset($_POST["qtregist"]) ? $_POST["qtregist"] : 15;
$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
$dtvencto = isset($_POST["dtvencto"]) ? $_POST["dtvencto"] : '';
$nrborder = isset($_POST["nrborder"]) ? $_POST["nrborder"] : '';
$nrcpfava = isset($_POST["nrcpfava"]) ? $_POST["nrcpfava"] : '';
$nrctacob = (isset($_POST['nrctacob'])) ? $_POST['nrctacob'] : '';
$nrcnvcob = (isset($_POST['nrcnvcob'])) ? $_POST['nrcnvcob'] : '';
$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;

if (!isset($operacao) || $operacao=='') {
    exibeErro(htmlentities('Opera&ccedil;&atilde;o n&atilde;o encontrada'));
}
function exibeErro($msgError){
    $json['status'] = 'erro';
    $json['mensagem'] = utf8_encode($msgError);
    echo json_encode($json);
    exit();
}

switch ($operacao){
    case "BUSCAR_ASSOCIADO":
        if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C')) <> '') {
            exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
        }

        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"DSCT0003","DSCT0003_BUSCAR_ASSOCIADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $json['status'] = 'sucesso';
            $json['nrdconta'] = utf8_encode($root->dados->associado->nrdconta->cdata);
            $json['nrcpfcgc'] = utf8_encode($root->dados->associado->nrcpfcgc->cdata);
            $json['nmprimtl'] = utf8_encode($root->dados->associado->nmprimtl->cdata);
        }        
        echo json_encode($json);
    break;
    case "BUSCAR_BORDEROS":
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'C',false)) <> "") {
            exibeErro($msgError);       
        }   
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","BUSCAR_BORDEROS_VENCIDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $dados = $root->dados;
            $qtregist = $dados->getAttribute("QTREGIST");
            ob_start();
            require_once("tab_borderos.php");
            $html = ob_get_clean();
            $json['status'] = 'sucesso';
            $json['html'] = $html;
        }        
        echo json_encode($json);
    break;
    case "LISTAR_FERIADOS":
        $dtfinal = DateTime::createFromFormat("d/m/Y",$glbvars["dtmvtolt"]);
        $dtfinal = $dtfinal->add(new DateInterval('P1Y'));

        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        $xml .= "   <dtfinal>".$dtfinal->format("d/m/Y")."</dtfinal>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","LISTAR_FERIADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $dados = $root->dados;

        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $feriados = array();
            foreach($root->dados->find("inf") as $f){
                $feriados[] = $f->yyyymmdd->cdata;
            }
            $json['status'] = 'sucesso';
            $json['feriados'] = $feriados;
        }        
        echo json_encode($json);
    break;
    case "LISTAR_TITULOS":
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","LISTAR_TITULOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $dados = $root->dados;

        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            ob_start();
            require_once("tab_titulos.php");
            $html = ob_get_clean();
            $json['status'] = 'sucesso';
            $json['html'] = $html;
        }
        echo json_encode($json);
    break;
    case "DADOS_PREJUIZO":
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","DADOS_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $dados = $root->dados;

        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            ob_start();
            require_once("tab_prejuizo.php");
            $html = ob_get_clean();
            $json['status'] = 'sucesso';
            $json['html'] = $html;
        }
        echo json_encode($json);
    break;
    case "GERAR_BOLETO":
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G",false)) <> "") {
            exibeErro($msgError);
        }
        $nrtitulo = $_POST["nrtitulo"];
        $titulos = '';
        foreach($nrtitulo as $k=>$v){
            $titulos .= $v."=".converteFloat($_POST["vlpagar"][$v]).";";
        }

        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <nrtitulo>".$titulos."</nrtitulo>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= "   <nrcpfava>".$nrcpfava."</nrcpfava>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","GERAR_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;

        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $boleto = $root->dados->boleto;
            $json['status'] = 'sucesso';
            $json['mensagem'] = 'Boleto n&ordm; '.$boleto->nrdocmto.' gerado com sucesso com <br/> o valor R$ '.formataMoeda($boleto->vltitulo);
        }
        echo json_encode($json);
    break;
    case "GERAR_BOLETO_PREJUIZO":
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G",false)) <> "") {
            exibeErro($msgError);
        }

        $vlboleto = converteFloat($_POST['vlboleto']);
        $flvlpagm = $_POST['flvlpagm'];

        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <vlboleto>".$vlboleto."</vlboleto>";
        $xml .= "   <flvlpagm>".$flvlpagm."</flvlpagm>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= "   <nrcpfava>".$nrcpfava."</nrcpfava>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"COBTIT","GERAR_BOLETO_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;

        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $boleto = $root->dados->boleto;
            $json['status'] = 'sucesso';
            $json['mensagem'] = 'Boleto n&ordm; '.$boleto->nrdocmto.' gerado com sucesso com <br/> o valor R$ '.formataMoeda($boleto->vltitulo);
        }
        echo json_encode($json);
    break;
    case "BUSCAR_BOLETOS":
        $cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
        $dtbaixai = (isset($_POST['dtbaixai'])) ? $_POST['dtbaixai'] : '';
        $dtbaixaf = (isset($_POST['dtbaixaf'])) ? $_POST['dtbaixaf'] : '';
        $dtemissi = (isset($_POST['dtemissi'])) ? $_POST['dtemissi'] : '';
        $dtemissf = (isset($_POST['dtemissf'])) ? $_POST['dtemissf'] : '';
        $dtvencti = (isset($_POST['dtvencti'])) ? $_POST['dtvencti'] : '';
        $dtvenctf = (isset($_POST['dtvenctf'])) ? $_POST['dtvenctf'] : '';
        $dtpagtoi = (isset($_POST['dtpagtoi'])) ? $_POST['dtpagtoi'] : '';
        $dtpagtof = (isset($_POST['dtpagtof'])) ? $_POST['dtpagtof'] : '';
        $nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : '';
        $nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : '';

        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdagenci>" . $cdagenci . "</cdagenci>";
        $xml .= "   <nrborder>" . $nrborder . "</nrborder>";
        $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
        $xml .= "   <dtbaixai>" . $dtbaixai . "</dtbaixai>";
        $xml .= "   <dtbaixaf>" . $dtbaixaf . "</dtbaixaf>";
        $xml .= "   <dtemissi>" . $dtemissi . "</dtemissi>";
        $xml .= "   <dtemissf>" . $dtemissf . "</dtemissf>";
        $xml .= "   <dtvencti>" . $dtvencti . "</dtvencti>";
        $xml .= "   <dtvenctf>" . $dtvenctf . "</dtvenctf>";
        $xml .= "   <dtpagtoi>" . $dtpagtoi . "</dtpagtoi>";
        $xml .= "   <dtpagtof>" . $dtpagtof . "</dtpagtof>";
        $xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
        $xml .= "   <nrregist>" . $nrregist . "</nrregist>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        // Chamada mensageria
        $xmlResult = mensageria($xml, "COBTIT", "BUSCAR_BOLETOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }else{
            $dados = $root->dados;
            $qtregist = $dados->getAttribute("QTREGIST");
            ob_start();
            require_once("tab_boletos.php");
            $html = ob_get_clean();
            $json['status'] = 'sucesso';
            $json['html'] = $html;
        }
        echo json_encode($json);
    break;
    case "BAIXAR_BOLETO":
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B",false)) <> "") {
            exibeErroBaixa($msgError);      
        }

        $dsjustif = (isset($_POST['dsjustif'])) ? utf8_decode($_POST['dsjustif']) : '';
        $dtmvtolt = $glbvars["dtmvtolt"];
        
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
        $xml .= "   <nrborder>" . $nrborder . "</nrborder>";
        $xml .= "   <nrctacob>" . $nrctacob . "</nrctacob>";
        $xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
        $xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
        $xml .= "   <dtmvtolt>" . $dtmvtolt . "</dtmvtolt>";
        $xml .= "   <dsjustif><![CDATA[" . $dsjustif . "]]></dsjustif>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        
        $xmlResult = mensageria($xml, "COBTIT", "EFETUAR_BAIXA_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        $dados = $root->dados;

        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }else{
            ob_start();
            require_once("tab_boletos.php");
            $html = ob_get_clean();
            $json['status'] = 'sucesso';
            $json['mensagem'] = 'Boleto n&#186;'.$nrdocmto.' baixado com Sucesso';
        }
        echo json_encode($json);
    break;
    case "ENVIAR_BOLETO":
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X",false)) <> "") {
            exibeErro($msgError);       
        }

        $dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '';
        // 1 - Email ou 2 - SMS
        $tpdenvio = (isset($_POST['tpdenvio'])) ? $_POST['tpdenvio'] : 0;

        $indretor = (isset($_POST['indretor'])) ? $_POST['indretor'] : 0;
        $textosms = (isset($_POST['textosms'])) ? $_POST['textosms'] : '';
        $nrdddtfc = (isset($_POST['nrdddtfc'])) ? $_POST['nrdddtfc'] : '';
        $nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '';
        $nmpescto = (isset($_POST['nmpescto'])) ? $_POST['nmpescto'] : '';
        if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X",false)) <> "") {
            exibeErro($msgError);       
        }   
        // Montar o xml de Requisicao
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
        $xml .= "   <nrborder>" . $nrborder . "</nrborder>";
        $xml .= "   <nrctacob>" . $nrctacob . "</nrctacob>";
        $xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
        $xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
        $xml .= "   <nmcontat>" . $nmpescto . "</nmcontat>";
        $xml .= "   <tpdenvio>" . $tpdenvio . "</tpdenvio>";
        $xml .= "   <dsdemail>" . $dsdemail . "</dsdemail>";
        $xml .= "   <indretor>" . $indretor . "</indretor>";
        $xml .= "   <nrdddsms>" . $nrdddtfc . "</nrdddsms>";
        $xml .= "   <nrtelsms>" . $nrtelefo . "</nrtelsms>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        // Chamada mensageria
        $xmlResult = mensageria($xml, "COBTIT", "ENVIAR_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        // Tratamento de erro
        if (strtoupper($xmlObj->roottag->tags [0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

            exit();
        } else {
            echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divRotina\'));;");';
        }
    break;
    case "IMPORTAR_ARQUIVO":
        $nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
        $flgreimp = (isset($_POST['flgreimp'])) ? $_POST['flgreimp'] : 0;

        // Montar o xml de Requisicao
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
        $xml .= "   <flgreimp>" . $flgreimp . "</flgreimp>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "COBTIT", "COBTIT_IMP_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        // Tratamento de erro
        if (strtoupper($xmlObject->roottag->tags [0]->name == 'ERRO')) {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', 'fechaRotina($(\'#divRotina\'));', false);
        } else {
            $flgreimp = (int) $xmlObject->roottag->tags[0]->cdata;
            if ($flgreimp) { // Solicitar confirmacao
                echo "$('#flgreimp', '#frmNomArquivo').val(1);";
                echo 'confirmaImportacao();';
            } else {
                echo "$('#flgreimp', '#frmNomArquivo').val(0);";
                echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaArquivos(1, 15);fechaRotina($(\'#divRotina\'));");';
            }
        }

    break;
}
?>