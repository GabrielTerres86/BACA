<?
/*!
 * FONTE        : altera_somente_bens.php
 * CRIAÇÃO      : Christian Grauppe (Envolti)
 * DATA CRIAÇÃO : 10/10/2018
 * OBJETIVO     : Verificas conta e traz dados do associados.
 *
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis
$arrAlienacoes = json_decode($_POST['arrayAlienacoes'], true);
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0';
$nrctrato = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
$dsdalien = (isset($_POST['dsdalien'])) ? $_POST['dsdalien'] : '';
$dsinterv = (isset($_POST['dsinterv'])) ? $_POST['dsinterv'] : '';

$cddopcao = 'A';
$tpctrato = '90';

// Montar o xml de Requisicao
$xmlCarregaDados  = "";
$xmlCarregaDados .= "<root>";
$xmlCarregaDados .= "	<Dados>";
$xmlCarregaDados .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xmlCarregaDados .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xmlCarregaDados .= "		<tpctrato>" . $tpctrato . "</tpctrato>";
$xmlCarregaDados .= "		<nrctrato>" . $nrctrato . "</nrctrato>";
$xmlCarregaDados .= "		<cddopcao>" . $cddopcao . "</cddopcao>";
$xmlCarregaDados .= '		<dsdalien>' . $dsdalien . '</dsdalien>';
$xmlCarregaDados .= '		<dsinterv>' . $dsinterv . '</dsinterv>';
$xmlCarregaDados .= "	</Dados>";

/*
$xmlCarregaDados .= "	<listabem>";

foreach ($arrAlienacoes as $alienacao) {

/*
	public 'dscatbem' => string 'AUTOMOVEL' (length=9)
	public 'dstipbem' => string 'USADO' (length=5)
	public 'dsbemfin' => string 'BUGGY/M-8/M-8 LONG 1.6' (length=22)
	public 'dscorbem' => string 'PRETO' (length=5)
	public 'dschassi' => string 'AAS21SSSSSSSSSSSS' (length=17)
	public 'nranobem' => string '2013' (length=4)
	public 'nrmodbem' => string '1999 GASOLINA' (length=13)
	public 'nrdplaca' => string 'ZZZ1234' (length=7)
	public 'nrrenava' => string '11112221126' (length=11)
	public 'tpchassi' => string '2' (length=1)
	public 'ufdplaca' => string 'SC' (length=2)
	public 'nrcpfbem' => string '497112965' (length=9)
	public 'dscpfbem' => string '004.971.129-65' (length=14)
	public 'vlmerbem' => string '9410' (length=4)
	public 'idalibem' => string '1' (length=1)
	public 'idseqbem' => string '1' (length=1)
	public 'cdcoplib' => string '' (length=0)
	public 'dsmarbem' => string 'BRM' (length=3)
	public 'vlrdobem' => string ' 9410,00' (length=8)
	public 'vlfipbem' => string ' 9410,00' (length=8)
	public 'nrcpfcgc' => string '497112965' (length=9)
	public 'cdoperad' => string '' (length=0)
	public 'dstpcomb' => string 'Gasolina' (length=8)
	public 'uflicenc' => string 'SC' (length=2)
* /

	$nrmodbem = $alienacao['nrmodbem'];
	if ( $pieces = explode(" ", $nrmodbem) ) {
		$nrmodbem = $pieces[0];
		$dstpcomb = $pieces[1];
	}
	$vlfipbem = str_replace(",", ".", $alienacao['vlfipbem'] );
	$vlrdobem = str_replace(",", ".", $alienacao['vlrdobem'] );
	
	$xmlCarregaDados .= "		<bemalien>";
	$xmlCarregaDados .= "			<dscatbem>" . $alienacao['dscatbem'] . "</dscatbem>";
	$xmlCarregaDados .= "			<dstipbem>" . $alienacao['dstipbem'] . "</dstipbem>";
	$xmlCarregaDados .= "			<dsmarbem>" . utf8_decode($alienacao['dsmarbem']) . "</dsmarbem>";
	$xmlCarregaDados .= "			<nrmodbem>" . $nrmodbem . "</nrmodbem>";
	$xmlCarregaDados .= "			<nranobem>" . $alienacao['nranobem'] . "</nranobem>";
	$xmlCarregaDados .= "			<dsbemfin>" . utf8_decode($alienacao['dsbemfin']) . "</dsbemfin>";
	$xmlCarregaDados .= "			<vlfipbem>" . $vlfipbem . "</vlfipbem>";
	$xmlCarregaDados .= "			<vlrdobem>" . $vlrdobem . "</vlrdobem>";
	$xmlCarregaDados .= "			<tpchassi>" . $alienacao['tpchassi'] . "</tpchassi>";
	$xmlCarregaDados .= "			<dschassi>" . $alienacao['dschassi'] . "</dschassi>";
	$xmlCarregaDados .= "			<dscorbem>" . $alienacao['dscorbem'] . "</dscorbem>";
	$xmlCarregaDados .= "			<ufdplaca>" . $alienacao['ufdplaca'] . "</ufdplaca>";
	$xmlCarregaDados .= "			<nrdplaca>" . $alienacao['nrdplaca'] . "</nrdplaca>";
	$xmlCarregaDados .= "			<nrrenava>" . $alienacao['nrrenava'] . "</nrrenava>";
	$xmlCarregaDados .= "			<uflicenc>" . $alienacao['uflicenc'] . "</uflicenc>";
	$xmlCarregaDados .= "			<nrcpfcgc>" . $alienacao['nrcpfcgc'] . "</nrcpfcgc>";
	$xmlCarregaDados .= "			<idseqbem>" . $alienacao['idseqbem'] . "</idseqbem>";
	$xmlCarregaDados .= "			<dstpcomb>" . $dstpcomb . "</dstpcomb>";
	$xmlCarregaDados .= " 			<cdopeapr>" . $alienacao['cdoperad'] . "</cdopeapr>";
	$xmlCarregaDados .= "		</bemalien>";

}

$xmlCarregaDados .= "	</listabem>";
*/
$xmlCarregaDados .= "</root>";

$xmlResult = mensageria($xmlCarregaDados,"TELA_MANBEM","GRAVA_ALIENACAO_HIPOTEC",$glbvars["cdcooper"],$glbvars["cdagenci"],$glbvars["nrdcaixa"],$glbvars["idorigem"],$glbvars["cdoperad"],"</Root>");
$xmlObject = getObjectXML($xmlResult);

//echo 'hideMsgAguardo();';

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
     $msgErro = $xmlObject->roottag->tags[0]->cdata;
     if ($msgErro == '') {
         $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
     }
     exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
} else if (strtoupper($xmlObject->roottag->tags[0]->name) == "AVISO") {
	$msgAviso  = $xmlObject->roottag->tags[0]->cdata;
} else {
	$msgAviso = "Bens atualizados com sucesso!";
	$metodo = "";
}

if ( $msgAviso != "" ) {
	exibirErro('inform',$msgAviso,'Alerta - Ayllos',$metodo,false);
}
