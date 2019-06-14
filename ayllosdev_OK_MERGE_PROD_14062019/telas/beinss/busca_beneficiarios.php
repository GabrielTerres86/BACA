<? 
/*!
 * FONTE        : busca_baneficiarios.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/06/2011 
 * OBJETIVO     : Rotina para busca de beneficiários
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
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','controlaLayout(\'1\');',false);
	
	// Guardo os parâmetos do POST em variáveis	
	$nrprocur = (isset($_POST['nrprocur'])) ? $_POST['nrprocur'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$nmrecben = (isset($_POST['nmrecben'])) ? $_POST['nmrecben'] : '';
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 30;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0091.p</Bo>";
	$xml .= "		<Proc>busca-benefic-beinss</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
    $xml .= "		<nmrecben>".$nmrecben."</nmrecben>";
	$xml .= "		<cdageins>".$cdagenci."</cdageins>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<nrprocur>".$nrprocur."</nrprocur>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','controlaLayout(\'1\');',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
	
	include('tab_beneficiarios.php');
	
?>