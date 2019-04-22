<?php
/*!
 * FONTE        : apresentar_desligamentoCRM.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 26/12/2017
 * OBJETIVO     : Retornar dados para o formulario de desligamento da tela MATRIC
 * --------------
 * ALTERAÇÕES   : 22/04/2019 - Buscar o valor correto de cotas PRB0041599 - Tiago
 * --------------
 */ 
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	
    require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
  
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$cdmotivo = 0;
	$dsmotivo = "";
	$rowiddes = "";

    // Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "VERIFICA_SITUACAO_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);

    }
    
    $situacao = $xmlObj->roottag->tags[0]->tags;
	
	// Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml .= '		<tpdsaque>2</tpdsaque>';  // Fixo - DESLIGAMENTO
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "MATRIC", "BUSCA_SAQUE_CONTROLE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);

    }
	
	// Ler os valores vindos do XML
	//$vldcotas = $xmlObj->roottag->tags[0]->cdata; 
	$nrdconta = $xmlObj->roottag->tags[1]->cdata;
	$cdmotivo = $xmlObj->roottag->tags[2]->cdata; 
	$dsmotivo = $xmlObj->roottag->tags[3]->cdata;
	$rowiddes = $xmlObj->roottag->tags[4]->cdata;
	
	
	// Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "BUSCAR_SALDO_COTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);

    }
	
	$vldcotas = $xmlObj->roottag->tags[0]->tags[0]->cdata; 	
	

	include('form_desligamentoCRM.php');

?>

