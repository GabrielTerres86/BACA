<?php 

/*!
 * FONTE        : carrega_agend_debitos.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 10/01/2018
 * OBJETIVO     : Processa agendamento de debitos de convenios do Bancoob
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
*/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	if (!isset($_POST["cddopcao"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
			
	$cddopcao = $_POST["cddopcao"] == "" ? 0  : $_POST["cddopcao"];
    $cdcoptel = $_POST["cdcoptel"] == "" ? 0  : $_POST["cdcoptel"];
    $dtmvtopg = $_POST["dtmvtopg"] == "" ? "" : $_POST["dtmvtopg"];
	
	// Monta o xml de requisição
	$xml = new XmlMensageria();    
    $xml->add('cddopcao',$cddopcao);
    $xml->add('cdcoptel',$cdcoptel);
    $xml->add('dtmvtopg',$dtmvtopg);
   
   
    $xmlResult = mensageria($xml, "TELA_DEBBAN", "PROCESS_AGENDEB_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErro($msgErro,'error');
        exit();
    }       
    
    $dsmensag = getByTagName($xmlObj->roottag->tags[0]->tags,'dsmensag');
    if ($dsmensag != ""){        
        $dsmensag = $dsmensag ;
        exibeErro($dsmensag,'inform');
        exit();        
    }
    
   
	function exibeErro($msgErro,$tipo) {
		echo 'hideMsgAguardo();';
		echo 'showError("'.$tipo.'","'.$msgErro.'","Alerta - Contas","estadoInicial();");';
		exit();	
	}
		
?>


