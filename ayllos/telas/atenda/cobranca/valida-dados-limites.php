<?php 

/*************************************************************************
	Fonte: valida-dados-limites.php
	Autor: Gabriel						Ultima atualizacao: 23/02/2016
	Data : Dezembro/2010
	
	Objetivo: Valida os dados da tela de habilitacao.
	
	Alteracoes: 08/09/2011 - Ajuste para chamada da lista ListaNegra
						    (Adriano).
							
				10/05/2013 - Retirado campo de valor maximo do boleto. 
						     vllbolet (Jorge)

				23/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

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

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
	exibirErro('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}	

$cddopcao  = $_POST["cddopcao"];
$nrdconta  = $_POST["nrdconta"];
$dsorgarq  = trim($_POST["dsorgarq"]);
$inarqcbr  = $_POST["inarqcbr"];
$cddemail  = $_POST["cddemail"];
$flgconti  = trim($_POST["flgconti"]);
$titulares = $_POST["titulares"];

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <dsorgarq>".$dsorgarq."</dsorgarq>";
$xml .= "   <inarqcbr>".$inarqcbr."</inarqcbr>";
$xml .= "   <cddemail>".$cddemail."</cddemail>";
$xml .= "   <idseqttl>1</idseqttl>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "VALIDA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    exibirErro('error',utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}

echo 'hideMsgAguardo();';
 
if ($flgconti == "true") { // Se chama confirmacao
    echo 'confirmaHabilitacao("'.$cddopcao.'");';
} else { // Chama titulares
    echo 'chamaTitulares("H","'.$titulares.'");';
}
?>