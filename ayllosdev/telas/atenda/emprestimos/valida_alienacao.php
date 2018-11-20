<?
/*!
 * FONTE        : valida_alienacao.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/03/2011
 * OBJETIVO     : Verificas conta e traz dados do associados.
 *
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [30/12/2013] Novo parametro, dschassi -  Guilherme(SUPERO)
 * 001: [14/03/2014] Novos parametros, nrdconta, nrctremp, dscorbem, nrdplaca, idseqbem - Guilherme(SUPERO)
 * 002: [20/01/2015] Novo parametro dstipbem, referente ao Tipo Veiculo. (Jorge/Gielow) - SD 241854
 * 003: [25/01/2016] Incluido condicao para verificar se apresenta mensagem de aviso, caso o valor da garantia for superior a 5 vezes do valor do emprestimo. (James)
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nmfuncao = (isset($_POST['nmfuncao'])) ? $_POST['nmfuncao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0';
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '0';
$dscorbem = (isset($_POST['dscorbem'])) ? $_POST['dscorbem'] : '';
$nrdplaca = (isset($_POST['nrdplaca'])) ? $_POST['nrdplaca'] : '';
$idseqbem = (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : '0';
$tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : '90';

$dscatbem = (isset($_POST['dscatbem'])) ? $_POST['dscatbem'] : '';
$dsbemfin = (isset($_POST['dsbemfin'])) ? $_POST['dsbemfin'] : '';
//$vlmerbem = (isset($_POST['vlmerbem'])) ? $_POST['vlmerbem'] : '';
$idcatbem = (isset($_POST['idcatbem'])) ? $_POST['idcatbem'] : '';
$tpchassi = (isset($_POST['tpchassi'])) ? $_POST['tpchassi'] : '';
$dschassi = (isset($_POST['dschassi'])) ? $_POST['dschassi'] : '';
$ufdplaca = (isset($_POST['ufdplaca'])) ? $_POST['ufdplaca'] : '';
$uflicenc = (isset($_POST['uflicenc'])) ? $_POST['uflicenc'] : '';
$nrrenava = (isset($_POST['nrrenava'])) ? $_POST['nrrenava'] : '';
$nranobem = (isset($_POST['nranobem'])) ? $_POST['nranobem'] : '';
$nrmodbem = (isset($_POST['nrmodbem'])) ? $_POST['nrmodbem'] : '';
//$nrcpfbem = (isset($_POST['nrcpfbem'])) ? $_POST['nrcpfbem'] : '';
$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
$dstipbem = (isset($_POST['dstipbem'])) ? $_POST['dstipbem'] : '';
$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';

$dsmarbem = (isset($_POST['dsmarbem'])) ? $_POST['dsmarbem'] : '';
$vlrdobem = (isset($_POST['vlrdobem'])) ? $_POST['vlrdobem'] : '';
$vlfipbem = (isset($_POST['vlfipbem'])) ? $_POST['vlfipbem'] : '';
$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
$dstpcomb = (isset($_POST['dstpcomb'])) ? $_POST['dstpcomb'] : '';

$dscatbem = ( $dscatbem == 'null' ) ? '' : $dscatbem;
$tpchassi = ( $tpchassi == 'null' ) ? '' : $tpchassi;
$dschassi = ( $dschassi == 'null' ) ? '' : $dschassi;
$ufdplaca = ( $ufdplaca == 'null' ) ? '' : $ufdplaca;
$uflicenc = ( $uflicenc == 'null' ) ? '' : $uflicenc;
$dstipbem = ( $dstipbem == 'null' ) ? '' : $dstipbem;

$nrcpfbem = $nrcpfcgc;
$vlmerbem = $vlrdobem;

if ($operacao == 'A_BENS' || $operacao == 'AI_BENS') {

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= "	<Dados>";
	$xmlCarregaDados .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlCarregaDados .= "		<nrctremp>" . $nrctremp . "</nrctremp>";
	$xmlCarregaDados .= "		<tpctrato>" . $tpctrato . "</tpctrato>";
	$xmlCarregaDados .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
	$xmlCarregaDados .= "		<cddopcao>" . $cddopcao . "</cddopcao>";
	$xmlCarregaDados .= "		<dscatbem>" . $dscatbem . "</dscatbem>";
	$xmlCarregaDados .= "		<dstipbem>" . $dstipbem . "</dstipbem>";
	$xmlCarregaDados .= "		<nrmodbem>" . $nrmodbem . "</nrmodbem>";
	$xmlCarregaDados .= "		<nranobem>" . $nranobem . "</nranobem>";
	$xmlCarregaDados .= "		<dsbemfin>" . $dsbemfin . "</dsbemfin>";
	$xmlCarregaDados .= "		<vlrdobem>" . $vlmerbem . "</vlrdobem>";
	$xmlCarregaDados .= "		<tpchassi>" . $tpchassi . "</tpchassi>";
	$xmlCarregaDados .= "		<dschassi>" . $dschassi . "</dschassi>";
	$xmlCarregaDados .= "		<dscorbem>" . $dscorbem . "</dscorbem>";
	$xmlCarregaDados .= "		<ufdplaca>" . $ufdplaca . "</ufdplaca>";
	$xmlCarregaDados .= "		<nrdplaca>" . $nrdplaca . "</nrdplaca>";
	$xmlCarregaDados .= "		<nrrenava>" . $nrrenava . "</nrrenava>";
	$xmlCarregaDados .= "		<uflicenc>" . $uflicenc . "</uflicenc>";
	$xmlCarregaDados .= "		<nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
	$xmlCarregaDados .= "		<idseqbem>" . $idseqbem . "</idseqbem>";
	$xmlCarregaDados .= "	</Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados
						   ,"TELA_MANBEM"
						   ,"VALIDA_BEM_ALIENA"
						   ,$glbvars["cdcooper"]
						   ,$glbvars["cdagenci"]
						   ,$glbvars["nrdcaixa"]
						   ,$glbvars["idorigem"]
						   ,$glbvars["cdoperad"]
						   ,"</Root>");
						   
	$xmlObject = getObjectXML($xmlResult);

	$msgErro = $msgAviso = $metodo = "";

	if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
		$msgErro = $xmlObject->roottag->tags[0]->cdata;
		if ($msgErro == '') {
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} else if (strtoupper($xmlObject->roottag->tags[0]->name) == "MENSAGEM" && $xmlObject->roottag->tags[0]->cdata != "") {
		$msgAviso = $xmlObject->roottag->tags[0]->cdata;
		if (strtoupper($xmlObject->roottag->tags[1]->name) == 'APROVACA' && $xmlObject->roottag->tags[1]->cdata != 0) {
			$metodo = "bloqueiaFundo(divRotina);pedeSenhaCoordenador(2,'".addslashes(addslashes(addslashes($nmfuncao)))."','');";
		}
	}

	if ( $msgAviso != "" ) {
		exibirErro('inform',$msgAviso,'Alerta - Ayllos',$metodo,false);
	} else if ( $metodo != "" ) {
		echo $metodo;
	} else {
		echo $nmfuncao;
	}

} else {

	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-dados-alienacao</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";

	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<dscorbem>".$dscorbem."</dscorbem>";
	$xml .= "		<nrdplaca>".$nrdplaca."</nrdplaca>";
	$xml .= "		<idseqbem>".$idseqbem."</idseqbem>";

	$xml .= "		<dscatbem>".$dscatbem."</dscatbem>";
	$xml .= "		<dstipbem>".$dstipbem."</dstipbem>";
	$xml .= "		<dsbemfin>".$dsbemfin."</dsbemfin>";
	$xml .= "		<vlmerbem>".$vlmerbem."</vlmerbem>";
	$xml .= "		<idcatbem>".$idcatbem."</idcatbem>";
	$xml .= "		<tpchassi>".$tpchassi."</tpchassi>";
	$xml .= "		<dschassi>".$dschassi."</dschassi>";
	$xml .= "		<ufdplaca>".$ufdplaca."</ufdplaca>";
	$xml .= "		<uflicenc>".$uflicenc."</uflicenc>";
	$xml .= "		<nrrenava>".$nrrenava."</nrrenava>";
	$xml .= "		<nranobem>".$nranobem."</nranobem>";
	$xml .= "		<nrmodbem>".$nrmodbem."</nrmodbem>";
	$xml .= "		<nrcpfbem>".$nrcpfbem."</nrcpfbem>";
	$xml .= "		<vlemprst>".$vlemprst."</vlemprst>";

	$xml .= "		<dsmarbem>".$dsmarbem."</dsmarbem>";
	$xml .= "		<vlrdobem>".$vlrdobem."</vlrdobem>";
	$xml .= "		<vlfipbem>".$vlfipbem."</vlfipbem>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<dstpcomb>".$dstpcomb."</dstpcomb>";

	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	$nomeCampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];

	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
	}

	// Condicao para veriricar se apresenta mensagem para o usuario
	if ($xmlObj->roottag->tags[0]->attributes['DSMENSAG'] != "") {

		$metodo = "bloqueiaFundo(divRotina);";

		// Condicao para verificar se apresenta senha de confirmacao
		if ($xmlObj->roottag->tags[0]->attributes['FLGSENHA'] == 1) {
			$metodo .= "pedeSenhaCoordenador(2,'".addslashes(addslashes(addslashes($nmfuncao)))."','');";
		} else {
			$metodo .= addslashes($nmfuncao);
		}
		exibirErro('inform',$xmlObj->roottag->tags[0]->attributes['DSMENSAG'],'Alerta - Ayllos',$metodo,false);
	} else {
		echo $nmfuncao;
	}

}