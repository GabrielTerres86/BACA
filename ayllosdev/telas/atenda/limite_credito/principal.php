<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               �ltima Altera��o: 20/07/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar op��o Principal da rotina de Limite de       ***//
	//***             Cr�dito da tela ATENDA                               ***//
	//***                                                                  ***//
	//*** Altera��es: 28/06/2010 - Incluir campo de envio a sede           ***//
	//****						  (Gabrel)								   ***//
	//***                                                                  ***//
	//***             16/09/2010 - Ajuste para enviar impressoes via email ***//
	//***                          para o PAC Sede (David).                ***//
	//***                                                                  ***//
	//***             27/10/2010 - Tratamento para projeto de linhas de    ***//
	//***                          cr�dito (David).                        ***//
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
	//***						   remover quebra de linha da observa��o   ***//
	//***						   (Lunelli - SD SD 300819 | 300893) 	   ***//
	//***																   ***//
	//***    		  20/07/2015 - Ajuste no tratamento de caracteres 	   ***//
	//***                         (Kelvin)	   							   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$cddopcao = $_POST["cddopcao"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
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
	//$dsobserv = removeCaracteresInvalidos($dsobserv);
	
	include ("form_principal.php");
	

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>