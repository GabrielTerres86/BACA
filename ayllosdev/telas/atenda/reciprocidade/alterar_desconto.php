<?php

/*************************************************************************
	Fonte: alterar_desconto.php
	Autor: André Clemer - Supero			Ultima atualizacao: --/--/----
	Data : Julho/2018
	
	Objetivo: Ativar desconto.
	
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

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
	exibirErro('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}

$idcalculo_reciproci = ( (!empty($_POST['idcalculo_reciproci'])) ? $_POST['idcalculo_reciproci'] : 0 );
$cdcooper            = ( (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'] );
$nrdconta            = ( (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : $glbvars['nrdconta'] );
$convenios           = ( (!empty($_POST['convenios'])) ? json_decode($_POST['convenios']) : '' );
$perdesconto         = ( (!empty($_POST['perdesconto'])) ? json_decode($_POST['perdesconto']) : '' );
$boletos_liquidados  = ( (!empty($_POST['boletos_liquidados'])) ? $_POST['boletos_liquidados'] : null );
$volume_liquidacao   = ( (!empty($_POST['volume_liquidacao'])) ? $_POST['volume_liquidacao'] : null );
$qtdfloat            = ( (isset($_POST['qtdfloat'])) ? $_POST['qtdfloat'] : null );
$vlaplicacoes        = ( (!empty($_POST['vlaplicacoes'])) ? $_POST['vlaplicacoes'] : null );
$vldeposito          = ( (!empty($_POST['vldeposito'])) ? $_POST['vldeposito'] : null );
$dtfimcontrato       = ( (!empty($_POST['dtfimcontrato'])) ? $_POST['dtfimcontrato'] : null );
$flgdebito_reversao  = ( (!empty($_POST['flgdebito_reversao'])) ? $_POST['flgdebito_reversao'] : 0 );
$vldesconto_coo      = ( (!empty($_POST['vldesconto_coo'])) ? $_POST['vldesconto_coo'] : 0 );
$dtfimadicional_coo  = ( (!empty($_POST['dtfimadicional_coo'])) ? $_POST['dtfimadicional_coo'] : null );
$vldesconto_cee      = ( (!empty($_POST['vldesconto_cee'])) ? $_POST['vldesconto_cee'] : 0 );
$dtfimadicional_cee  = ( (!empty($_POST['dtfimadicional_cee'])) ? $_POST['dtfimadicional_cee'] : null );
$txtjustificativa    = ( (!empty($_POST['txtjustificativa'])) ? $_POST['txtjustificativa'] : null );
$idvinculacao        = ( (!empty($_POST['idvinculacao'])) ? $_POST['idvinculacao'] : null );
$vldescontoconcedido_coo  = ( (!empty($_POST['vldescontoconcedido_coo'])) ? $_POST['vldescontoconcedido_coo'] : 0 );
$vldescontoconcedido_cee  = ( (!empty($_POST['vldescontoconcedido_cee'])) ? $_POST['vldescontoconcedido_cee'] : 0 );

$arrConvenios = array();
if (count($convenios)) {
    foreach($convenios as $convenio) {
        $auxConvenios = array();
        foreach($convenio as $k => $v) {
            $auxConvenios[] = $v;
        }
        $arrConvenios[] = implode(",", $auxConvenios);
    }
}

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <idcalculo_reciproci>".$idcalculo_reciproci."</idcalculo_reciproci>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <ls_convenios>".implode(";", $arrConvenios)."</ls_convenios>";
$xml .= "   <boletos_liquidados>".converteFloat($boletos_liquidados)."</boletos_liquidados>";
$xml .= "   <volume_liquidacao>".converteFloat($volume_liquidacao)."</volume_liquidacao>";
$xml .= "   <qtdfloat>".$qtdfloat."</qtdfloat>";
$xml .= "   <vlaplicacoes>".converteFloat($vlaplicacoes)."</vlaplicacoes>";
$xml .= "   <vldeposito>".converteFloat($vldeposito)."</vldeposito>";
$xml .= "   <dtfimcontrato>".$dtfimcontrato."</dtfimcontrato>";
$xml .= "   <flgdebito_reversao>".$flgdebito_reversao."</flgdebito_reversao>";
$xml .= "   <vldesconto_coo>".converteFloat($vldesconto_coo)."</vldesconto_coo>";
$xml .= "   <dtfimadicional_coo>".$dtfimadicional_coo."</dtfimadicional_coo>";
$xml .= "   <vldesconto_cee>".converteFloat($vldesconto_cee)."</vldesconto_cee>";
$xml .= "   <dtfimadicional_cee>".$dtfimadicional_cee."</dtfimadicional_cee>";
$xml .= "   <txtjustificativa>".utf8_decode($txtjustificativa)."</txtjustificativa>";
$xml .= "   <idvinculacao>".$idvinculacao."</idvinculacao>";
$xml .= "   <perdesconto>".implode("|", $perdesconto)."</perdesconto>";
$xml .= "   <vldescontoconcedido_coo>".converteFloat($vldescontoconcedido_coo)."</vldescontoconcedido_coo>";
$xml .= "   <vldescontoconcedido_cee>".converteFloat($vldescontoconcedido_cee)."</vldescontoconcedido_cee>";
$xml .= " </Dados>";
$xml .= "</Root>";
//exit('hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'); // debug
$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "ALTERA_DESCONTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$xmlDados = $xmlObject->roottag;

if (strtoupper($xmlDados->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    $idcalculo_reciproci = getByTagName($xmlDados,"IDCALCULO_RECIPROCI");

    exibirErro('inform','Descontos atualizados com sucesso.','Alerta - Ayllos','acessaOpcaoContratos();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}
