<?php 
/*!
 * FONTE         : mensagem_confirma_importacao.php
 * CRIAÇÃO       : Mateus Zimmermann - Mout's
 * DATA CRIAÇÃO  : 08/05/2019
 * OBJETIVO      : Buscar a hora da tabela PRM e mostrar mensagem de confirmação com a hora
 *
 * ALTERACOES    : 
 */		

session_start();
		
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");	
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	
	
$xml = new XmlMensageria();

$xmlResult = mensageria($xml, "TELA_CADDNE", 'BUSCA_PARAM', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = simplexml_load_string($xmlResult);

if(!is_null($xmlObj->Erro->Registro)){
	if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		exibirErro('inform',$msgErro,'Alerta - Ayllos','','');
	}
}

$dsvlrprm = $xmlObj->inf->dsvlrprm;

echo "showConfirmacao('O processo de carga ser&aacute; executado hoje &agrave;s " . $dsvlrprm . ", hor&aacute;rio definido pela &aacute;rea de neg&oacute;cios. Confirma a carga neste hor&aacute;rio?','Confirma&ccedil;&atilde;o - Aimaro','importa_arquivos();','','sim.gif','nao.gif');";

?>