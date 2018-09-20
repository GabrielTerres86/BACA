<?php
/*!
 * FONTE        : debitar_lancamentos.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 02/06/2016
 * OBJETIVO     : Rotina para validar e efetivar lancamento futuro.
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();

    require_once("../../../includes/config.php");
    require_once("../../../includes/funcoes.php");
    require_once("../../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo metodo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../../class/xmlfile.php");

    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D",false)) <> "") {
        exibeErro($msgError);
    }

    $acao     = $_POST["acao"];
    $nrdconta = $_POST["nrdconta"];
    $vlcampos = $_POST["vlcampos"];

    // Se parametros necessarios nao foram informados
    if (!isset($acao) || !isset($nrdconta) || !isset($vlcampos)) {
        exibeErro("Par&acirc;metros incorretos.");
    }

    // Monta o xml de requisição
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <vlcampos>".$vlcampos."</vlcampos>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $nmdeacao  = ($acao == 'V' ? 'LAUTOM_VALIDA' : 'LAUTOM_EFETUA');
    $xmlResult = mensageria($xml, "TELA_LAUTOM", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra critica
    if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibeErro($msgErro);
    }

    echo 'hideMsgAguardo();';
    echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';

    if ($acao == 'V') { // Validar
        $xmlDados = $xmlObject->roottag->tags[0];
        $inconfir = getByTagName($xmlDados->tags,"INCONFIR");
        $dsmensag = getByTagName($xmlDados->tags,"DSMENSAG");
        // Se nao possui saldo suficiente
        if ($inconfir > 0) {
            echo "confirmaDebitoSemSaldo('".$dsmensag."');"; // Chama a confirmacao
        } else {
            echo "validarDebitarLanctoFut('D');"; // Chama o Debito
        }
    } else { // Debitar
        echo 'showError("inform","D&eacute;bito de lançamento efetuado com sucesso.","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
        echo "acessaOpcaoAba(1,0,0);";
    }

    // Funcao para exibir erros na tela atraves de javascript
    function exibeErro($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
        exit();
    }
?>
