<?php 
	
	//************************************************************************//
	//*** Fonte: incluir_bloqueio.php                                      ***//
	//*** Autor: Guilherme/SUPERO                                          ***//
	//*** Data : Mar�o/2013                   �ltima Altera��o:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Funcoes relativas ao Bloqueio Judicial               ***//	
	//***                                                                  ***//
	//***                          								           ***//
	//*** Altera��es: 29/07/2016 - Ajuste para controle de permiss�o sobre ***//
	//***                          as subrotinas de cada op��o	           ***//
    //***                         (Adriano - SD 492902).				   ***//
	//***			 31/10/2016 - Realizar a chamada da rotina INCLUI-     ***//
	//***					      BLOQUEIO-JUD diretamente do oracle via   ***//
	//***					      mensageria (Renato Darosci - Supero)     ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao = $_POST["cddopcao"];
	$cdoperac = $_POST["cdoperac"];

	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao);

	$nmrotina = $glbvars["nmrotina"];
	 
	switch ($opcao){

		case 'B': $glbvars["nmrotina"] = "BLQ JUDICIAL"; break;
		case 'C': $glbvars["nmrotina"] = "BLQ CAPITAL"; break;
		case 'T': $glbvars["nmrotina"] = "TRF JUDICIAL"; break;		
		
	}

	// Verifica permiss&atilde;o da subrotina
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cdoperac);

    $nrdconta = $_POST["nrdconta"];     // LISTA
    $cdtipmov = $_POST["cdtipmov"];     // LISTA
    $cdmodali = $_POST["cdmodali"];     // LISTA
    $vlbloque = $_POST["vlbloque"];     // LISTA
    $nroficio = $_POST["nroficio"];
    $nrproces = $_POST["nrproces"];
    $dsjuizem = $_POST["dsjuizem"];
    $dsresord = $_POST["dsresord"];
    $flblcrft = $_POST["flblcrft"];
    $dtenvres = $_POST["dtenvres"];
    $vlrsaldo = $_POST["vlrsaldo"];
	$dsinfadc = $_POST["dsinfadc"];
	$cddopcao = $_POST["cddopcao"];

	// Monta o xml de requisi��o
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlRegistro .= "		<cdtipmov>".$cdtipmov."</cdtipmov>";
	$xmlRegistro .= "		<cdmodali>".$cdmodali."</cdmodali>";	
	$xmlRegistro .= "		<vlbloque>".$vlbloque."</vlbloque>";
	$xmlRegistro .= "		<nroficio>".$nroficio."</nroficio>";
    $xmlRegistro .= "		<nrproces>".$nrproces."</nrproces>";
    $xmlRegistro .= "		<dsjuizem>".$dsjuizem."</dsjuizem>";
    $xmlRegistro .= "		<dsresord>".$dsresord."</dsresord>";
    $xmlRegistro .= "		<flblcrft>".$flblcrft."</flblcrft>";
    $xmlRegistro .= "		<dtenvres>".$dtenvres."</dtenvres>";    
    $xmlRegistro .= "		<vlrsaldo>".$vlrsaldo."</vlrsaldo>";
    $xmlRegistro .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
    $xmlRegistro .= "       <dsinfadc>".$dsinfadc."</dsinfadc>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xmlRegistro, "BLQJUD", "INCLUI_BLOQUEIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	if ($cddopcao == 'T') {
		echo "showError('inform','Transfer�ncia cadastrada com sucesso!','Informe - BLQJUD','hideMsgAguardo();estadoInicial();');";
	}else{
		echo "showError('inform','Bloqueio cadastrado com sucesso!','Informe - BLQJUD','hideMsgAguardo();estadoInicial();');";
	}
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) {
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","hideMsgAguardo();");';
		exit();
	}
	
?>