<?php

/* !
 * FONTE        : db_salvar_dados_imovel.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 13/06/2016
 * OBJETIVO     : Rotina para salvar os dados do imóvel. Também utilizada pela rotina de inclusão 
 *				  manual, pois a mesma permitirá o cadastro de informações.
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
$nrmatcar = (isset($_POST['nrmatcar'])) ? $_POST['nrmatcar'] : 0;
$nrcnscar = (isset($_POST['nrcnscar'])) ? $_POST['nrcnscar'] : 0;
$tpimovel = (isset($_POST['tpimovel'])) ? $_POST['tpimovel'] : 0;
$nrreggar = (isset($_POST['nrreggar'])) ? $_POST['nrreggar'] : 0;
$dtreggar = (isset($_POST['dtreggar'])) ? $_POST['dtreggar'] : '';
$nrgragar = (isset($_POST['nrgragar'])) ? $_POST['nrgragar'] : 0;
$nrceplgr = (isset($_POST['nrceplgr'])) ? $_POST['nrceplgr'] : 0;
$tplograd = (isset($_POST['tplograd'])) ? $_POST['tplograd'] : 0;
$dslograd = (isset($_POST['dslograd'])) ? $_POST['dslograd'] : '';
$nrlograd = (isset($_POST['nrlograd'])) ? $_POST['nrlograd'] : '';
$dscmplgr = (isset($_POST['dscmplgr'])) ? $_POST['dscmplgr'] : '';
$dsbairro = (isset($_POST['dsbairro'])) ? $_POST['dsbairro'] : '';
$cdcidade = (isset($_POST['cdcidade'])) ? $_POST['cdcidade'] : 0;
$dtavlimv = (isset($_POST['dtavlimv'])) ? $_POST['dtavlimv'] : '';
$vlavlimv = (isset($_POST['vlavlimv'])) ? $_POST['vlavlimv'] : 0;
$dtcprimv = (isset($_POST['dtcprimv'])) ? $_POST['dtcprimv'] : '';
$vlcprimv = (isset($_POST['vlcprimv'])) ? $_POST['vlcprimv'] : 0;
$tpimpimv = (isset($_POST['tpimpimv'])) ? $_POST['tpimpimv'] : 0;
$incsvimv = (isset($_POST['incsvimv'])) ? $_POST['incsvimv'] : 0;
$inpdracb = (isset($_POST['inpdracb'])) ? $_POST['inpdracb'] : 0;
$vlmtrtot = (isset($_POST['vlmtrtot'])) ? $_POST['vlmtrtot'] : 0;
$vlmtrpri = (isset($_POST['vlmtrpri'])) ? $_POST['vlmtrpri'] : 0;
$qtdormit = (isset($_POST['qtdormit'])) ? $_POST['qtdormit'] : 0;
$qtdvagas = (isset($_POST['qtdvagas'])) ? $_POST['qtdvagas'] : 0;
$vlmtrter = (isset($_POST['vlmtrter'])) ? $_POST['vlmtrter'] : 0;
$vlmtrtes = (isset($_POST['vlmtrtes'])) ? $_POST['vlmtrtes'] : 0;
$incsvcon = (isset($_POST['incsvcon'])) ? $_POST['incsvcon'] : 0;
$inpesvdr = (isset($_POST['inpesvdr'])) ? $_POST['inpesvdr'] : 0;
$nrdocvdr = (isset($_POST['nrdocvdr'])) ? $_POST['nrdocvdr'] : 0;
$nmvendor = (isset($_POST['nmvendor'])) ? $_POST['nmvendor'] : '';

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


// Se não veio vendedor, envia todos os valores nulos
if ($nmvendor == '') {
	$inpesvdr = '';
	$nrdocvdr = '';
	$nmvendor = '';
}

// CAMPOS DA TELA DE INCLUSÃO MANUAL
$nrreginc = (isset($_POST['nrreginc'])) ? $_POST['nrreginc'] : 0;
$dtinclus = (isset($_POST['dtinclus'])) ? $_POST['dtinclus'] : '';
$dsjstinc = (isset($_POST['dsjstinc'])) ? $_POST['dsjstinc'] : '';

// Se não tem informação de número de registros, envia informações em branco
if ($nrreginc == 0 || $nrreginc == '') {
	$nrreginc = '';
	$dtinclus = '';
	$dsjstinc = '';
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
$xml .= "	<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml .= "	<nrmatcar>" . $nrmatcar . "</nrmatcar>";
$xml .= "	<nrcnscar>" . $nrcnscar . "</nrcnscar>";
$xml .= "	<tpimovel>" . $tpimovel . "</tpimovel>";
$xml .= "	<nrreggar>" . $nrreggar . "</nrreggar>";
$xml .= "	<dtreggar>" . $dtreggar . "</dtreggar>";
$xml .= "	<nrgragar>" . $nrgragar . "</nrgragar>";
$xml .= "	<nrceplgr>" . $nrceplgr . "</nrceplgr>";
$xml .= "	<tplograd>" . $tplograd . "</tplograd>";
$xml .= "	<dslograd>" . $dslograd . "</dslograd>";
$xml .= "	<nrlograd>" . $nrlograd . "</nrlograd>";
$xml .= "	<dscmplgr>" . $dscmplgr . "</dscmplgr>";
$xml .= "	<dsbairro>" . $dsbairro . "</dsbairro>";
$xml .= "	<cdcidade>" . $cdcidade . "</cdcidade>";
$xml .= "	<dtavlimv>" . $dtavlimv . "</dtavlimv>";
$xml .= "	<vlavlimv>" . $vlavlimv . "</vlavlimv>";
$xml .= "	<dtcprimv>" . $dtcprimv . "</dtcprimv>";
$xml .= "	<vlcprimv>" . $vlcprimv . "</vlcprimv>";
$xml .= "	<tpimpimv>" . $tpimpimv . "</tpimpimv>";
$xml .= "	<incsvimv>" . $incsvimv . "</incsvimv>";
$xml .= "	<inpdracb>" . $inpdracb . "</inpdracb>";
$xml .= "	<vlmtrtot>" . $vlmtrtot . "</vlmtrtot>";
$xml .= "	<vlmtrpri>" . $vlmtrpri . "</vlmtrpri>";
$xml .= "	<qtdormit>" . $qtdormit . "</qtdormit>";
$xml .= "	<qtdvagas>" . $qtdvagas . "</qtdvagas>";
$xml .= "	<vlmtrter>" . $vlmtrter . "</vlmtrter>";
$xml .= "	<vlmtrtes>" . $vlmtrtes . "</vlmtrtes>";
$xml .= "	<incsvcon>" . $incsvcon . "</incsvcon>";
$xml .= "	<inpesvdr>" . $inpesvdr . "</inpesvdr>";
$xml .= "	<nrdocvdr>" . $nrdocvdr . "</nrdocvdr>";
$xml .= "	<nmvendor>" . $nmvendor . "</nmvendor>";
// CAMPOS DA TELA DE INCLUSÃO MANUAL				
$xml .= "	<nrreginc>" . $nrreginc . "</nrreginc>";
$xml .= "	<dtinclus>" . $dtinclus . "</dtinclus>";
$xml .= "	<dsjstinc>" . $dsjstinc . "</dsjstinc>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "SALVA_IMOVEL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 

echo "hideMsgAguardo();";
	
?>
