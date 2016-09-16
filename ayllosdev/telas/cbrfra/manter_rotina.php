<? 
/*!
 * FONTE          : manter_rotina.php
 * CRIAÇÃO      : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO : 16/06/2014
 * OBJETIVO       : Mantem a rotina das informacoes de inclusao, selecao e delecao na tela CBRFRA
 *
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	$stracao = $_POST['cddopcao'];
	$stropcao = $_POST['stropcao'];
	$strcodbar = $_POST['nrdcodigo'];
	$strcodbarexc = $_POST['nrdcodigoexc'];
	$datinclusao = $_POST['nmdata'];
	$datinicial = $_POST['nmdatainicial'];
	$datfinal = $_POST['nmdatafinal'];
	$nriniseq    = isset($_POST['nriniseq']) ? $_POST['nriniseq'] : 0;
	$nrregist    = isset($_POST['nrregist']) ? $_POST['nrregist'] : 0;
	$strnomacao = '';

 
	//rotina da exclusao de codigos com fraude	
	if($stracao == 'E' && $strcodbarexc != ''){
		$strnomacao = 	'EXCCBRFRA';
		$strdisabled = '';
		$strcodbar = '' ;
		$datinicial = '';
		$datfinal = '' ;
		$xmlexclusao  = "";
		$xmlexclusao .= "<Root>";
		$xmlexclusao .= " <Dados>";
		$xmlexclusao .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlexclusao .= "    <dscodbar>".$strcodbarexc."</dscodbar>";
		$xmlexclusao .= " </Dados>";
		$xmlexclusao .= "</Root>";
		$xmlResultExc = mensageria($xmlexclusao, "CBRFRA", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraudeExc = getObjectXML($xmlResultExc);
	
		if (strtoupper($xmlObjFraudeExc->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjFraudeExc->roottag->tags[0]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',false);
		} else{
			$msgOK = "C&oacute;digo com fraude exclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos',false);
		}
	}
	else
	if($stracao == 'I' && $strcodbar != ''){
		$strdisabled = '';
		$xmlInclusao  = "";
		$xmlInclusao .= "<Root>";
		$xmlInclusao .= " <Dados>";
		$xmlInclusao .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlInclusao .= "    <dscodbar>".$strcodbar."</dscodbar>"; 
		$xmlInclusao .= "    <dtsolici>".$datinclusao."</dtsolici>";
		$xmlInclusao .= " </Dados>";
		$xmlInclusao .= "</Root>";  
		$xmlResultInc = mensageria($xmlInclusao, "CBRFRA", "INCCBRFRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraudeInc = getObjectXML($xmlResultInc);
		
		if (strtoupper($xmlObjFraudeInc->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjFraudeInc->roottag->tags[0]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',false);
		} else{
			$msgOK = "C&oacute;digo com fraude inclu&iacute;do com sucesso!";
			exibirErro('inform',$msgOK,'Alerta - Ayllos',false);
		}
		
		$strcodbar = '' ;
		$datinicial = '';
		$datfinal = '' ;
	}	
	else {
		//rotina da colsulta de codigos com fraude	
		// caso a consulta seja no modo exclusao ativa a opcao de exclusao na tabela
		$strdisabled = ($stropcao == 'E') ? '' : 'display:none';
		//nome da acao enviada para mensageria e o monta o xml
		$strnomacao = 	'CONCBRFRA';	
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "    <dscodbar>".$strcodbar."</dscodbar>";
		$xml .= "    <dtiniper>".$datinicial."</dtiniper>";
		$xml .= "    <dtfimper>".$datfinal."</dtfimper>";
		$xml .= "    <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "    <nrregist>".$nrregist."</nrregist>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		//realiza o processo de mensageria para efetuar a transacao no banco de dados
		$xmlResult = mensageria($xml, "CBRFRA", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObjFraude = getObjectXML($xmlResult); 

		//retorno dos registros
		$registros = $xmlObjFraude->roottag->tags;
		
		include 'tabela_cbrfra.php'; 
	}

?>