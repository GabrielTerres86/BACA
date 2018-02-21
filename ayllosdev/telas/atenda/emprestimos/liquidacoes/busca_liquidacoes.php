<?php

/* !
 * FONTE        : busca_liquidacoes.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/04/2011 
 * OBJETIVO     : Busca registros para tela de liquidações de emprestimo
 *
 * ALTERACOES   :[ 27/07/2013] Controle na liquidacao de contratos (Gabriel).
 * 				       [ 29/06/2015] Ajustes referente Projeto 215 - DV 3 (Daniel). 
 * 				       [ 07/07/2015] Ajustes referente Projeto 218 (Carlos Rafael). 	 
 * 				       [ 14/07/2016] Busca período de bloqueio de limite por refinanceamento da tela CADPRE. Projeto 299 (Lombardi).
 * 				       [ 21/02/2018] Incluído identificador de empréstimo para liquidar (Simas-AMcom).
 */

session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis	
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : '';
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';

// Buscar período de bloqueio de limite por refinanceamento da tela CADPRE.
// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADPRE" , 'BUSCA_PER_BLOQ_REF', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
$xmlObj    = getObjectXML($xmlResult);	

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
  $msgErro = $xmlObj->roottag->tags[0]->cdata;
  exibirErro('error',$msgErro,'Alerta - Ayllos',false);
}

$qtmesblq = $xmlObj->roottag->tags[0]->cdata;
echo 'qtmesblq = '.$qtmesblq.';';

//parametro criado para tratar PORTABILIDADE
if ($operacao != 'PORTAB_I' && $operacao != 'PORTAB_A') {

    // exibirErro('error',$dsctrliq,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
    // Monta o xml de requisição
    $xml  = "<Root>";
    $xml .= "	<Cabecalho>";
    $xml .= "		<Bo>b1wgen0002.p</Bo>";
    $xml .= "		<Proc>obtem-dados-liquidacoes</Proc>";
    $xml .= "	</Cabecalho>";
    $xml .= "	<Dados>";
    $xml .= "       <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
    $xml .= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
    $xml .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
    $xml .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
    $xml .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
    $xml .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
    $xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
    $xml .= "		<dtmvtopr>" . $glbvars["dtmvtopr"] . "</dtmvtopr>";
    $xml .= "		<inproces>" . $glbvars["inproces"] . "</inproces>";
    $xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "		<idseqttl>" . $idseqttl . "</idseqttl>";
    $xml .= "		<dsctrliq>" . $dsctrliq . "</dsctrliq>";
    $xml .= "		<cdlcremp>" . $cdlcremp . "</cdlcremp>";
    $xml .= "		<cdprogra>Emprestimos</cdprogra>";
    $xml .= "		<nrctremp>0</nrctremp>";
    $xml .= "		<dtcalcul>?</dtcalcul>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xml);

    // Cria objeto para classe de tratamento de XML
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
        exibirErro('error', $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
    }
	
    $liquidacoes = $xmlObj->roottag->tags[0]->tags;
} else { //tratamento para PORTABILIDADE 
    switch ($operacao) {
        case 'PORTAB_I':
            $operacao = 'I_DADOS_AVAL';
            break;
        case 'PORTAB_A':
            $operacao = 'A_DADOS_AVAL';
            break;
    }
    $liquidacoes = array();
}

if (count($liquidacoes) == 0) {
    echo '$("#dsctrliq","#frmNovaProp").val("Sem liquidacoes");';
    echo 'atualizaArray("' . $operacao . '");';
} else {

    echo 'arrayLiquidacoes.length = 0;';

    for ($i = 0; $i < count($liquidacoes); $i++) {

        $identificador = $i . getByTagName($liquidacoes[$i]->tags, 'nrctremp');

        echo 'var arrayLiquidacao' . $identificador . ' = new Object();';

        echo 'arrayLiquidacao' . $identificador . '[\'nrdconta\'] = "' . getByTagName($liquidacoes[$i]->tags, 'nrdconta') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'nmprimtl\'] = "' . getByTagName($liquidacoes[$i]->tags, 'nmprimtl') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'nrctremp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'nrctremp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlemprst\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlemprst') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlsdeved\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlsdeved') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlpreemp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlpreemp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlprepag\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlprepag') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'txjuremp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'txjuremp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vljurmes\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vljurmes') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vljuracu\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vljuracu') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlprejuz\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlprejuz') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlsdprej\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlsdprej') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dtprejuz\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dtprejuz') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vljrmprj\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vljrmprj') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vljraprj\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vljraprj') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'inprejuz\'] = "' . getByTagName($liquidacoes[$i]->tags, 'inprejuz') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlprovis\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlprovis') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'flgpagto\'] = "' . getByTagName($liquidacoes[$i]->tags, 'flgpagto') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dtdpagto\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dtdpagto') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'cdpesqui\'] = "' . getByTagName($liquidacoes[$i]->tags, 'cdpesqui') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dspreapg\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dspreapg') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'cdlcremp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'cdlcremp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dslcremp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dslcremp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'cdfinemp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'cdfinemp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dsfinemp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dsfinemp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dsdaval1\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dsdaval1') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dsdaval2\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dsdaval2') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlpreapg\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlpreapg') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtmesdec\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtmesdec') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtprecal\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtprecal') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlacresc\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlacresc') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlrpagos\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlrpagos') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'slprjori\'] = "' . getByTagName($liquidacoes[$i]->tags, 'slprjori') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dtmvtolt\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dtmvtolt') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtpreemp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtpreemp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dtultpag\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dtultpag') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'vlrabono\'] = "' . getByTagName($liquidacoes[$i]->tags, 'vlrabono') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtaditiv\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtaditiv') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dsdpagto\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dsdpagto') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'dsdavali\'] = "' . getByTagName($liquidacoes[$i]->tags, 'dsdavali') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtmesatr\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtmesatr') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'qtpromis\'] = "' . getByTagName($liquidacoes[$i]->tags, 'qtpromis') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'flgimppr\'] = "' . getByTagName($liquidacoes[$i]->tags, 'flgimppr') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'flgimpnp\'] = "' . getByTagName($liquidacoes[$i]->tags, 'flgimpnp') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'idseleca\'] = "' . getByTagName($liquidacoes[$i]->tags, 'idseleca') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'nrdrecid\'] = "' . getByTagName($liquidacoes[$i]->tags, 'nrdrecid') . '";';

        echo 'arrayLiquidacao' . $identificador . '[\'tpemprst\'] = "' . getByTagName($liquidacoes[$i]->tags, 'tpemprst') . '";';
        echo 'arrayLiquidacao' . $identificador . '[\'idenempr\'] = "' . getByTagName($liquidacoes[$i]->tags, 'idenempr') . '";';
        
        echo 'arrayLiquidacoes[' . $i . '] = arrayLiquidacao' . $identificador . ';';
    }

    echo 'carregaLiquidacoes();';

    // echo 'mostraLiquidacoes("BT","'.$operacao.'");';
}
?>
