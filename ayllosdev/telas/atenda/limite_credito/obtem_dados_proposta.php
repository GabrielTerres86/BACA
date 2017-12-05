<?php
/*!
 * FONTE         : obtem_dados_proposta.php
 * CRIAÇÃO       : Gabriel Ramirez (RKAM)
 * DATA CRIAÇÃO  : 08/04/2015
 * OBJETIVO      : Efetuar consulta da proposta de limite
 *
 * ALTERACOES    : 08/04/2015 - Permitir as consultas para o limite de credito (Jonata-RKAM) 
 *				   08/07/2015 - Tratamento de caracteres especiais e remover quebra de linha da observação (Lunelli - SD SD 300819 | 300893) 
 *                 20/07/2015 - Ajuste no tratamento de caracteres (Kelvin)
 *                 19/08/2015 - Reformulacao cadastral (Gabriel-RKAM)  
 *                 05/12/2017 - Gravação do campo idcobope. Projeto 404 (Lombardi)
 */
 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	$nrdconta = empty($_POST["nrdconta"]) ? 0 : $_POST["nrdconta"];
	$nrctrlim = empty($_POST["nrctrlim"]) ? 0 : $_POST["nrctrlim"];

	// Monta o xml de requisição
	$xmlGetLimite  = "";
	$xmlGetLimite .= "<Root>";
	$xmlGetLimite .= "	<Cabecalho>";
	$xmlGetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetLimite .= "		<Proc>obtem-dados-proposta</Proc>";
	$xmlGetLimite .= "	</Cabecalho>";
	$xmlGetLimite .= "	<Dados>";
	$xmlGetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";		
	$xmlGetLimite .= "		<idseqttl>1</idseqttl>";	
	$xmlGetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimite .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";		
	$xmlGetLimite .= "		<inproces>".$glbvars["inproces"]."</inproces>";		
	$xmlGetLimite .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";		
	$xmlGetLimite .= "	</Dados>";
	$xmlGetLimite .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$proposta = $xmlObjLimite->roottag->tags[0]->tags[0]->tags;
	
	$nmextcop = getByTagName($proposta,"nmextcop");
	$nmexcop2 = getByTagName($proposta,"nmexcop2");
	$nmcidade = getByTagName($proposta,"nmcidade");
	$nrdconta = getByTagName($proposta,"nrdconta");	
	$nrmatric = getByTagName($proposta,"nrmatric");
	$nrcpfcgc = getByTagName($proposta,"nrcpfcgc");
	$nmprimtl = getByTagName($proposta,"nmprimtl");
	$nmsegntl = getByTagName($proposta,"nmsegntl");
	$dtadmiss = getByTagName($proposta,"dtadmiss");
	$nmresage = getByTagName($proposta,"nmresage");
	$dsempres = getByTagName($proposta,"dsempres");
	$nrdofone = getByTagName($proposta,"nrdofone");
	$dstipcta = getByTagName($proposta,"dstipcta");
	$dssitdct = getByTagName($proposta,"dssitdct");
	$nrctrlim = getByTagName($proposta,"nrctrlim");
	$vllimite = getByTagName($proposta,"vllimite");
	$nrctaav1 = getByTagName($proposta,"nrctaav1");
	$nrctaav2 = getByTagName($proposta,"nrctaav2");
	$nrcpfav1 = getByTagName($proposta,"nrcpfav1");
	$nrcpfav2 = getByTagName($proposta,"nrcpfav2");
	$vllimcre = getByTagName($proposta,"vllimcre");
	$vlsalari = getByTagName($proposta,"vlsalari");
	$vlsalcon = getByTagName($proposta,"vlsalcon");
	$vloutras = getByTagName($proposta,"vloutras");
	$vlalugue = getByTagName($proposta,"vlalugue");
	$dsobser1 = getByTagName($proposta,"dsobser1");
	$dsobser2 = getByTagName($proposta,"dsobser2");
	$dsobser3 = getByTagName($proposta,"dsobser3");
	$vlutiliz = getByTagName($proposta,"vlutiliz");
	$vlsmdtri = getByTagName($proposta,"vlsmdtri");
	$vltotemp = getByTagName($proposta,"vltotemp");
	$vltotpre = getByTagName($proposta,"vltotpre");
	$vlcaptal = getByTagName($proposta,"vlcaptal");
	$vlprepla = getByTagName($proposta,"vlprepla");
	$vlaplica = getByTagName($proposta,"vlaplica");
	$vltotccr = getByTagName($proposta,"vltotccr");
	$nmoperad = getByTagName($proposta,"nmoperad");
	$dsemsprp = getByTagName($proposta,"dsemsprp");
	$tpregist = getByTagName($proposta,"tpregist");	
	$inconcje = getByTagName($proposta,"inconcje");	
	$dsobserv = getByTagName($proposta,"dsobser1");	
	$idcobope = getByTagName($proposta,"idcobope");
	
	echo "setDadosProposta('$vlsalari','$vlsalcon','$vloutras','$vlalugue','$nrctaav1','$nrctaav2', '$inconcje', '$nrcpfav1', '$nrcpfav2', '$idcobope' );";
	echo "setDadosObservacao('$dsobserv');";
?>