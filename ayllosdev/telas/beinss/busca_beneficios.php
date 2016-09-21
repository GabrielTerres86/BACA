<? 
/*!
 * FONTE        : busca_baneficios.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 02/06/2011 
 * OBJETIVO     : Rotina para busca de beneficios
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','controlaLayout(\'3\');',false);

	// Guardo os parâmetos do POST em variáveis	
	$nrrecben = (isset($_POST['nrrecben'])) ? $_POST['nrrecben'] : 0;
	$nrbenefi = (isset($_POST['nrbenefi'])) ? $_POST['nrbenefi'] : 0;
	$dtdinici = (isset($_POST['dtdinici'])) ? $_POST['dtdinici'] : '';
	$dtdfinal = (isset($_POST['dtdfinal'])) ? $_POST['dtdfinal'] : '';
	
	//
	validaDados();
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0091.p</Bo>";
	$xml .= "		<Proc>busca-beneficio</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xml .= "		<nrrecben>".$nrrecben."</nrrecben>";
    $xml .= "		<nrbenefi>".$nrbenefi."</nrbenefi>";
    $xml .= "		<dtdinici>".$dtdinici."</dtdinici>";
    $xml .= "		<dtdfinal>".$dtdfinal."</dtdfinal>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
	
	
	include('tab_beneficios.php');
	
	//
	function validaDados() {
		// data inicial
		if ( $GLOBALS['dtdinici'] == '' ) exibirErro('error','Informe a data inicial do periodo.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'dtdinici\',\'frmPeriodo\')',false);
	
		// data final
		if ( $GLOBALS['dtdfinal'] == '' ) exibirErro('error','Informe a data final do periodo.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'dtdfinal\',\'frmPeriodo\')',false);

		// data inicial
		if ( !validaData($GLOBALS['dtdinici']) ) exibirErro('error','Data inicial inválida.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'dtdinici\',\'frmPeriodo\')',false);
	
		// data final
		if ( !validaData($GLOBALS['dtdfinal']) ) exibirErro('error','Data final inválida.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'dtdfinal\',\'frmPeriodo\')',false);
		
	}		
	
?>