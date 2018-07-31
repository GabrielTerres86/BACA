<?php
/*
 * FONTE        : carrega_filtros.php
 * CRIAÇÃO      : Marcos Lucas (Mouts)
 * DATA CRIAÇÃO : 23/01/2018
 * OBJETIVO     : Consulta para popular os filtros de banco liquidante e credenciadora
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Adicionado campo Credenciadora no Filtro (PRJ 486 - Mateus Z / Mouts)
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Inicializa variaveis
$procedure = '';
$retornoAposErro = '';

// Monta o xml dinâmico de acordo com a operação
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONCIP", "BUSCA_FILTROS_CONCIP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
}
else {

	$xmlRes = simplexml_load_string($xmlResult);

	echo json_encode(array(
		'liquidante' => $xmlRes->liquidantes,
		'credenciadora' => $xmlRes->credenciadoras,
		// PRJ 486
		'credenciadorasstr' => $xmlRes->credenciadorasstr
		)
	);
}
