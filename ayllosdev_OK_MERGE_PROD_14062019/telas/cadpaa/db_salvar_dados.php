<?php

/* !
 * FONTE        : db_salvar_dados.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 07/11/2016
 * OBJETIVO     : Rotina para salvar os dados do PA Administrativo. 
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa
$retornoAposErro = '';

// Recebe os parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
$cdpaadmi = (isset($_POST['cdpaadmi'])) ? $_POST['cdpaadmi'] : 0;
$dspaadmi = (isset($_POST['dspaadmi'])) ? $_POST['dspaadmi'] : 0;
$tprateio = (isset($_POST['tprateio'])) ? $_POST['tprateio'] : 0;

/*if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}*/

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdcooper>" . $cdcooper . "</cdcooper>";
$xml .= "	<cdpaadmi>" . $cdpaadmi . "</cdpaadmi>";
$xml .= "	<dspaadmi>" . $dspaadmi . "</dspaadmi>";
$xml .= "	<tprateio>" . $tprateio . "</tprateio>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "TELA_CADPAA", "INCLUI_PA_ADMIN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cCdpa_admin.focus();',false);
} 

echo "hideMsgAguardo();";
	
?>
