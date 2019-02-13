<?php 
	
	//************************************************************************//
	//*** Fonte: inclui_icf.php                                            ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Março/2013                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Incluir ICF - Informacoes de Clientes do Sistema     ***//	
	//***             Financeiro.                                          ***//	 
	//***                                                                  ***//
	//*** Alterações: 												       ***//
	//***                          								           ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	$nrdconta = $_POST["nrdconta"];
	$cdbandes = $_POST["cdbandes"];
	$cdagedes = $_POST["cdagedes"];
	$nrctades = $_POST["nrctades"];
	$dacaojud = $_POST["dacaojud"];
	$cdoperad = $_POST["cdoperad"];
    $dsdocmc7 = htmlspecialchars($_POST["dsdocmc7"]);
    $tpdconta = $_POST["tpdconta"];
    $dtdtroca = $_POST["dtdtroca"];
    $vldopera = $_POST["vldopera"];
					
	// Monta o xml de requisi??o
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0154.p</Bo>";
	$xmlRegistro .= "		<Proc>inclui-registro-icf</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRegistro .= "		<nrctaori>".$nrdconta."</nrctaori>";
	$xmlRegistro .= "		<cdbanori>85</cdbanori>";
	$xmlRegistro .= "		<cdbanreq>".$cdbandes."</cdbanreq>";	
	$xmlRegistro .= "		<cdagereq>".$cdagedes."</cdagereq>";
	$xmlRegistro .= "		<nrctareq>".$nrctades."</nrctareq>";
	$xmlRegistro .= "		<dacaojud>".$dacaojud."</dacaojud>";
	$xmlRegistro .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlRegistro .= "		<dsdocmc7>".$dsdocmc7."</dsdocmc7>";
	$xmlRegistro .= "		<tpdconta>".$tpdconta."</tpdconta>";
	$xmlRegistro .= "		<dtdtroca>".$dtdtroca."</dtdtroca>";
	$xmlRegistro .= "		<vldopera>".$vldopera."</vldopera>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	echo 'alert("ICF cadastrada com sucesso!");';

	echo 'estadoInicial();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>