<?php

/* !
 * FONTE        : db_inclusao_manual_imovel.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 21/06/2016
 * OBJETIVO     : Rotina para gravar a inclusão manual do imóvel
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
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$idseqbem = (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : 0;
$nrreginc = (isset($_POST['nrreginc'])) ? $_POST['nrreginc'] : 0;
$dtinclus = (isset($_POST['dtinclus'])) ? $_POST['dtinclus'] : '';
$dsjstinc = (isset($_POST['dsjstinc'])) ? $_POST['dsjstinc'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml .= "	<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "	<nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "	<idseqbem>" . $idseqbem . "</idseqbem>";
$xml .= "	<nrreginc>" . $nrreginc . "</nrreginc>";
$xml .= "	<dtinclus>" . $dtinclus . "</dtinclus>";
$xml .= "	<dsjstinc>" . $dsjstinc . "</dsjstinc>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "INCLUI_IMOVEL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
		
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 

echo "hideMsgAguardo();";
	
?>
