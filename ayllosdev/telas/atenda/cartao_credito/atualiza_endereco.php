<?php

/*************************************************************************
	Fonte: atualiza_endereco.php
	Autor: Augusto - Supero			Ultima atualizacao: --/--/----
	Data : Setembro/2018
	
	Objetivo: Atualiza a proposta de alteração de limite
	
	Alteracoes: 

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	


$nrdconta = ( (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 );
$nrctrcrd = ( (!empty($_POST['nrctrcrd'])) ? $_POST['nrctrcrd'] : 0 );
$tipoAcao = ( (!empty($_POST['tipoAcao'])) ? $_POST['tipoAcao'] : 0 );
$idtipoenvio = ( (!empty($_POST['idtipoenvio'])) ? $_POST['idtipoenvio'] : 0 );
$cdagenci = ( (!empty($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 );

if (!validaInteiro($nrdconta)) {
    exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));');
}

if (!validaInteiro($nrctrcrd)) {
    exibirErro('error','Proposta inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));');
}

$xmlConsulta = "<Root>";
$xmlConsulta .= " <Dados>";
$xmlConsulta.= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlConsulta.= " </Dados>";
$xmlConsulta.= "</Root>";

$xmlResult = mensageria($xmlConsulta, "ATENDA_CRD", "BUSCA_PARAMETRO_APROVADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
    exibeErro($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

$parametroAprovador = !empty($xmlObject->roottag->tags[0]->cdata) ? $xmlObject->roottag->tags[0]->cdata : 0;

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
$xml .= "   <idtipoenvio>".$idtipoenvio."</idtipoenvio>";
$xml .= "   <cdagenci>".$cdagenci."</cdagenci>";

$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "ATUALIZA_ENDERECO_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$xmlDados = $xmlObject->roottag->tags[0];

if (strtoupper($xmlDados->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    if ($tipoAcao == 1) {
        if ($parametroAprovador == 0) {
            echo "exibeRotina(divRotina);solicitaSenha($nrctrcrd, cTipoSenha.COOPERADO);";
        } else {
            echo "solicitaTipoSenha($nrctrcrd, 'novo');";
        }
    } else {
        exibirErro("warn", "Endere&ccedil;o alterado com sucesso.","Alerta - Aimaro","alertarCooperado(".$tipoAcao.");voltarEndereco(".$tipoAcao.");",false);
    }
}
