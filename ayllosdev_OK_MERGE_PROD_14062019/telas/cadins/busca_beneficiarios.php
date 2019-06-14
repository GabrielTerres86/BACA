<? 
/*!
 * FONTE        : busca_baneficiarios.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 25/05/2011 
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
	
	// Guardo os parâmetos do POST em variáveis	
	$cddopcao = 'A';
	$nmrecben = (isset($_POST['nmrecben'])) ? $_POST['nmrecben'] : '';
	$cdagcpac = (isset($_POST['cdagcpac'])) ? $_POST['cdagcpac'] : '';
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : '';
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0091.p</Bo>";
	$xml .= "		<Proc>busca-benefic</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<nmrecben>".$nmrecben."</nmrecben>";
	$xml .= "		<cdagcpac>".$cdagcpac."</cdagcpac>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\')); cPac.focus();',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
			
	include('tab_beneficiarios.php');
							
?>