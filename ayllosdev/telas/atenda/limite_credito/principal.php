<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Última Alteração: 20/07/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Principal da rotina de Limite de       ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//
	//*** Alterações: 28/06/2010 - Incluir campo de envio a sede           ***//
	//****						  (Gabrel)								   ***//
	//***                                                                  ***//
	//***             16/09/2010 - Ajuste para enviar impressoes via email ***//
	//***                          para o PAC Sede (David).                ***//
	//***                                                                  ***//
	//***             27/10/2010 - Tratamento para projeto de linhas de    ***//
	//***                          crédito (David).                        ***//
	//***                    											   ***//
	//***             13/01/2011 - Inclusao do campo dsencfi3 (Adriano).   ***//
	//***																   ***//
	//***             28/06/2011 - Tabless (Rogerius - DB1).			   ***//
	//***																   ***//
	//***			  09/07/2012 - Retirado campo "redirect" (Jorge)       ***//
	//***																   ***//
	//***			  18/03/2014 - Incluir botao consultar imagem e os     ***//
	//***						   devidos ajustes (Lucas R.)   		   ***//
	//***                                                                  ***//
	//***             02/07/2014 - Permitir alterar a observacao da        ***//
	//****                         proposta (Chamado 169007) (Jonata-RKAM) ***//
	//***                                                                  ***//
	//***             23/12/2014 - Incluir o campo data de renovacao  e    ***//
	//***						   Tipo da Renovacao. (James)              ***//
	//***                                                                  ***//
	//***             02/01/2015 - Ajuste format numero contrato/bordero   ***//
	//***                          para consultar imagem do contrato;      ***//
	//***                          adequacao ao format pre-definido para   ***//
	//***                          nao ocorrer divergencia ao              ***//
    //***                          pesquisar no SmartShare.                ***//
    //***                          (Chamado 181988) - (Fabricio)           ***//
    //***                                                                  ***//
    //***             09/01/2015 - Altercoes referentes ao projeto de      ***//
    //***                          melhoria para alteracao de propoosta    ***//
    //***                          SD237152 (Tiago/Gielow).                ***//
	//***                                                                  ***//
	//***             06/04/2015 - Consultas automatizadas (Jonata-RKAM)   ***//   
	//***                                                                  ***//
	//***  			  08/07/2015 - Tratamento de caracteres especiais e	   ***// 
	//***						   remover quebra de linha da observação   ***//
	//***						   (Lunelli - SD SD 300819 | 300893) 	   ***//
	//***																   ***//
	//***    		  20/07/2015 - Ajuste no tratamento de caracteres 	   ***//
	//***                         (Kelvin)	   							   ***//
	//***                                                                  ***//
	//***             08/08/2017 - Implementacao da melhoria 438.          ***//
	//***                          Heitor (Mouts).                         ***//
	//***																   ***//
	//***			  06/03/2018 - Adicionado variável idcobope. 		   ***//
	//***					       (PRJ404 Reinert)						   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$cddopcao = $_POST["cddopcao"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetLimite  = "";
	$xmlGetLimite .= "<Root>";
	$xmlGetLimite .= "	<Cabecalho>";
	$xmlGetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetLimite .= "		<Proc>obtem-cabecalho-limite</Proc>";
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
	
	$limite = $xmlObjLimite->roottag->tags[0]->tags[0]->tags;
	
	$vllimite = getByTagName($limite,"vllimite");
	$dslimcre = getByTagName($limite,"dslimcre");
	$dtmvtolt = getByTagName($limite,"dtmvtolt");
	$dsfimvig = getByTagName($limite,"dsfimvig");	
	$dtfimvig = getByTagName($limite,"dtfimvig");
	$nrctrlim = getByTagName($limite,"nrctrlim");
	$qtdiavig = getByTagName($limite,"qtdiavig");
	$dsencfi1 = getByTagName($limite,"dsencfi1");
	$dsencfi2 = getByTagName($limite,"dsencfi2");
	$dsencfi3 = getByTagName($limite,"dsencfi3");
	$dssitlli = getByTagName($limite,"dssitlli");
	$dsmotivo = getByTagName($limite,"dsmotivo");
	$nmoperad = getByTagName($limite,"nmoperad");
	$flgpropo = getByTagName($limite,"flgpropo");
	$nrctrpro = getByTagName($limite,"nrctrpro");
	$cdlinpro = getByTagName($limite,"cdlinpro");
	$vllimpro = getByTagName($limite,"vllimpro");	
	$nmopelib = getByTagName($limite,"nmopelib");
	$flgenvio = getByTagName($limite,"flgenvio");
	$flgenpro = getByTagName($limite,"flgenpro");
	$cddlinha = getByTagName($limite,"cddlinha");
	$dsdlinha = getByTagName($limite,"dsdlinha");
	$tpdocmto = 84; //limite credito
	$flgdigit = getByTagName($limite,"flgdigit");
	$dsobserv = getByTagName($limite,'dsobserv');	
	$dstprenv = getByTagName($limite,"dstprenv");
	$dtrenova = getByTagName($limite,"dtrenova");
	$qtrenova = getByTagName($limite,"qtrenova");
	$flgimpnp = getByTagName($limite,"flgimpnp");
	$dslimpro = getByTagName($limite,"dslimpro");	
	$idcobope = getByTagName($limite,"idcobope");	
	//$dsobserv = removeCaracteresInvalidos($dsobserv);
	
	$xml  = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "LIM_ULTIMA_MAJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjMaj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjMaj->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjMaj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$majora = $xmlObjMaj->roottag->tags[0]->tags[0]->tags;
	
	$dtultmaj = getByTagName($majora,"dtultmaj");	
	
	include ("form_principal.php");

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>