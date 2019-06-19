<?php
/* !
 * FONTE        : executa_cargas_sas.php
 * CRIA��O      : Christian Grauppe - ENVOLTI
 * DATA CRIA��O : Janeiro/2019
 * OBJETIVO     : Mostrar tela IMPPRE - justivicativa de carga
 * --------------
 * ALTERA��ES   : 09/09/2015 - Retirada a op��o N da coluna 'Permite varias no m�s' (Vanessa)
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$skcarga = (isset($_POST['skcarga'])) ? $_POST['skcarga'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$dsrejeicao = (isset($_POST['dsrejeicao'])) ? $_POST['dsrejeicao'] : '';

// Monta o xml de requisi��o
$xml  = '';
$xml .= '<Root>';
$xml .= '   <Dados>';
$xml .= '       <skcarga>'.$skcarga.'</skcarga>';
$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
$xml .= '       <dsrejeicao>'.$dsrejeicao.'</dsrejeicao>';
$xml .= '   </Dados>';
$xml .= '</Root>';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "TELA_IMPPRE", "EXEC_CARGA_SAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;

	echo 'showError("error","'. $msgErro.'", "Alerta - Ayllos", "buscaCargas();encerraRotina();hideMsgAguardo();");';	
	
} else {
	echo 'showError("inform", "Opera��o realizada com sucesso!", "Alerta - Ayllos", "buscaCargas();encerraRotina();hideMsgAguardo();");';
}