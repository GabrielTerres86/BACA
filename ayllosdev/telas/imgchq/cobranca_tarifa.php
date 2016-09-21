<?php

    /**************************************************************************
          Fonte: cobranca_tarifa.php
          Autor: Lucas Moreira
          Data : Agosto/2015                   �ltima Altera��o: 16/03/2016

          Objetivo  : Cobra tarifa autom�ticamente.

          Altera��es: 16/03/2016 - Passar para mensageria o cdccoper recebido e n�o
                                   glbvars. (Guilherme/SUPERO)
    **************************************************************************/

    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m�todo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
        exibeErro($msgError);
        exit();
    }

    // Verifica se par�metros necess�rios foram informados
    if (!isset($_POST["cdagechq"]) || !isset($_POST["nrctachq"])) {
        exibeErro('Par&acirc;metros incorretos.');
        exit();
    }

    // parametros
    $cdagechq = $_POST['cdagechq'];
    $nrctachq = $_POST['nrctachq'];
    $cdcooper = $_POST['cdcooper'];

    $dsiduser = session_id();

    $xml  = '';
    $xml .= '<Root>';
    $xml .= '   <Dados>';
    $xml .= '       <cdagechq>'.$cdagechq.'</cdagechq>';
    $xml .= '       <nrctachq>'.$nrctachq.'</nrctachq>';
    $xml .= '   </Dados>';
    $xml .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TARIFA", "LAN_TARIFA", $cdcooper, $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

    // Cria objeto para classe de tratamento de XML
    $xmlObjDados = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra cr�tica
    if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
        $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibeErro($msg);
    }

    echo $xmlObjDados->roottag->tags[0]->cdata;

    // Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
        exit();
    }
?>