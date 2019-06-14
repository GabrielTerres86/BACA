<?php

	/*************************************************************************
	 Fonte: buscar_tipo_pessoa.php
	 Autor: Ricardo Linhares
	 Data : Abril/2017                          última Alteração:

	 Objetivo  : Buscar o tipo de pessoa para o ID Informado

	 Alterações:
     **************************************************************************/

class Error {
    var $erro;
    public function __construct($erro) {
        $this->erro = $erro;
    }
}

class Pessoa {
    var $inpessoa;
    public function __construct($inpessoa) {
        $this->inpessoa = $inpessoa;
    }
}

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$cdtarifa = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdtarifa>".$cdtarifa."</cdtarifa>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "BUSCA_TIPO_PESSOA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    $erro = new Error($msgErro);
    echo json_encode($erro);

} else {

    $registro = $xmlObj->roottag->tags[0];
    $inpessoa = new Pessoa(getByTagName($registro->tags,'inpessoa'));
    echo json_encode($inpessoa);
}

?>
