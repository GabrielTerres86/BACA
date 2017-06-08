<?php

	/*************************************************************************
	 Fonte: buscar_id.php
	 Autor: Ricardo Linhares
	 Data : Abril/2017                          última Alteração:

	 Objetivo  : Buscar o ID disponível para inserção de Novo Pacote

	 Alterações:
     **************************************************************************/

class Error {
    var $erro;
    public function __construct($erro) {
        $this->erro = $erro;
    }
}

class IdDisponivel {
    var $id;
    public function __construct($id) {
        $this->id = $id;
    }
}

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "BUSCA_PROXIMO_ID", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    $idDisponivel = new IdDisponivel(getByTagName($registro->tags,'proximo_id'));
    echo json_encode($idDisponivel);
}

?>
