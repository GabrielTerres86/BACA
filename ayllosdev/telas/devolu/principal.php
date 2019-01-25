<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Requisição de Conta da tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 *
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Inicializa
	$retornoAposErro = '';
	$cddopcao = '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	$opcao    = (isset($_POST["opcao"]))    ? $_POST["opcao"] : '';
	
    $retornoAposErro = 'estadoInicial();';
	
	if ($nrdconta == 0) {
		$cddopcao = 'D';
	} else {
        $cddopcao = 'S';
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>busca-devolucoes-cheque</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtoan>'.$glbvars['dtmvtoan'].'</dtmvtoan>';
	$xml .= '		<nrcalcul>'.$glbvars['nrcalcul'].'</nrcalcul>';
	$xml .= '		<stsnrcal>'.$glbvars['stsnrcal'].'</stsnrcal>';
	$xml .= "       <flgpagin>yes</flgpagin>";
	$xml .= "       <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "       <nrregist>".$nrregist."</nrregist>";
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	// Somente se for a consulta inicial
	if($opcao == 'CI') {
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
		}	
	}
	$qtregist   = $xmlObjeto->roottag->tags[1]->attributes["QTREGIST"];
	$nmprimtl	= $xmlObjeto->roottag->tags[1]->attributes['NMPRIMTL'];
	
	//Mensageria referente a situação da conta
	$xml  = ""; 
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult_prj = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "CONSULTA_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto_prj = getObjectXML($xmlResult_prj);	

	$param = $xmlObjeto_prj->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto_prj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto_prj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$retornoAposErro,false);
	}else{
		$inprejuz = getByTagName($param->tags,'inprejuz');	    
	}
	
	include('form_devolu.php');

	if ( $nrdconta == 0 ) {
		$devolucoes = $xmlObjeto->roottag->tags[0]->tags;
		include('tab_devolu_dados.php');
	} else {		
		$lancamento = $xmlObjeto->roottag->tags[1]->tags;
		include('tab_devolu_conta.php');
	}

?>
