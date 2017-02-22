<?php

/* !
 * FONTE        : db_busca_dados_imovel.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 10/06/2016
 * OBJETIVO     : Rotina para buscar os dados do imóvel selecionado em tela
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
$cdcoopel = 0;

// Recebe os parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$idseqbem = (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : 0;
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

// Se for a opção X
if ($cddopcao == 'X') {
    $cdcoopel = (isset($_POST['cdcooptl'])) ? $_POST['cdcooptl'] : 0;

	// Se não foi informado a cooperativa
	if ($cdcoopel == 0) {
		exibirErro('error', 'Cooperativa deve ser selecionada.', 'Alerta - Ayllos', 'cCdcooper.focus();', false);
	}
} else {
	$cdcoopel = $glbvars['cdcooper'];
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdcooper>" . $cdcoopel . "</cdcooper>";
$xml .= "	<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "	<nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "	<idseqbem>" . $idseqbem . "</idseqbem>";
$xml .= "	<cddopcao>" . $cddopcao . "</cddopcao>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "DADOS_IMOVEL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 

$dados  = $xmlObjeto->roottag->tags[0];

echo "cNrmatcar.val(\"" . getByTagName($dados->tags,"nrmatcar") . "\"); ";
echo "cNrcnscar.val(\"" . getByTagName($dados->tags,"nrcnscar") . "\"); ";
echo "cTpimovel.val(\"" . getByTagName($dados->tags,"tpimovel") . "\"); ";
echo "cNrreggar.val(\"" . getByTagName($dados->tags,"nrreggar") . "\"); ";
echo "cDtreggar.val(\"" . getByTagName($dados->tags,"dtreggar") . "\"); ";
echo "cNrgragar.val(\"" . getByTagName($dados->tags,"nrgragar") . "\"); ";
echo "cNrceplgr.val(\"" . getByTagName($dados->tags,"nrceplgr") . "\"); ";
echo "cTplograd.val(\"" . getByTagName($dados->tags,"tplograd") . "\"); ";
echo "cDslograd.val(\"" . getByTagName($dados->tags,"dslograd") . "\"); ";
echo "cNrlograd.val(\"" . getByTagName($dados->tags,"nrlograd") . "\"); ";
echo "cDscmplgr.val(\"" . getByTagName($dados->tags,"dscmplgr") . "\"); ";
echo "cDsbairro.val(\"" . getByTagName($dados->tags,"dsbairro") . "\"); ";
echo "cCdestado.val(\"" . getByTagName($dados->tags,"cdestado") . "\"); ";
// Chamar a rotina que carrega as cidades antes de tentar setar o valor
echo "carregar_cidades_uf(cCdestado,\"" . getByTagName($dados->tags,"cdcidade") . "\");";
echo "cDtavlimv.val(\"" . getByTagName($dados->tags,"dtavlimv") . "\"); ";
echo "cVlavlimv.val(\"" . getByTagName($dados->tags,"vlavlimv") . "\"); ";
echo "cDtcprimv.val(\"" . getByTagName($dados->tags,"dtcprimv") . "\"); ";
echo "cVlcprimv.val(\"" . getByTagName($dados->tags,"vlcprimv") . "\"); ";
echo "cTpimpimv.val(\"" . getByTagName($dados->tags,"tpimpimv") . "\"); ";
echo "cIncsvimv.val(\"" . getByTagName($dados->tags,"incsvimv") . "\"); ";
echo "cInpdracb.val(\"" . getByTagName($dados->tags,"inpdracb") . "\"); ";
echo "cVlmtrtot.val(\"" . getByTagName($dados->tags,"vlmtrtot") . "\"); ";
echo "cVlmtrpri.val(\"" . getByTagName($dados->tags,"vlmtrpri") . "\"); ";
echo "cQtdormit.val(\"" . getByTagName($dados->tags,"qtdormit") . "\"); ";
echo "cQtdvagas.val(\"" . getByTagName($dados->tags,"qtdvagas") . "\"); ";
echo "cVlmtrter.val(\"" . getByTagName($dados->tags,"vlmtrter") . "\"); ";
echo "cVlmtrtes.val(\"" . getByTagName($dados->tags,"vlmtrtes") . "\"); ";
echo "cIncsvcon.val(\"" . getByTagName($dados->tags,"incsvcon") . "\"); ";
// VENDEDOR
echo "cInpesvdr.val(\"" . getByTagName($dados->tags,"inpesvdr") . "\"); ";
echo "ajusta_pessoa_vendedor();";
echo "cNrdocvdr.val(\"" . getByTagName($dados->tags,"nrdocvdr") . "\"); ";
echo "cNmvendor.val(\"" . getByTagName($dados->tags,"nmvendor") . "\"); ";

// Se for a tela de consulta
if ($cddopcao == 'C') {

	echo "cNrreginc.val(\"" . getByTagName($dados->tags,"nrreginc") . "\"); ";
	echo "cDsjstinc.val(\"" . getByTagName($dados->tags,"dsjstinc") . "\"); ";
	echo "cDtinclus.val(\"" . getByTagName($dados->tags,"dtinclus") . "\"); ";
	echo "cDsjstbxa.val(\"" . getByTagName($dados->tags,"dsjstbxa") . "\"); ";
	echo "cDtdbaixa.val(\"" . getByTagName($dados->tags,"dtdbaixa") . "\"); ";
	echo "cDscritic.val(\"" . getByTagName($dados->tags,"dscritic") . "\"); ";
	
	echo 'ajusta_status_imovel('. getByTagName($dados->tags,"cdsituac") .',"'. getByTagName($dados->tags,"tpinclus") .'","'. getByTagName($dados->tags,"tpdbaixa") .'");';
	
	echo "fnMsgRegistroEncontrado(\"" . getByTagName($dados->tags,"nrmatcar") . "\"); "; 
}

echo "hideMsgAguardo();";
	
?>
