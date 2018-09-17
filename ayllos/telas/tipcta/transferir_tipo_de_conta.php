<?
/* * *********************************************************************

  Fonte: incluir_tipo_de_conta.php
  Autor: Lombardi
  Data : Dezembro/2018                       Última Alteração: 

  Objetivo  : Incluir Tipo de Conta.

  Alterações: 

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
	$cdtipo_conta_origem  = (isset($_POST['cdtipo_conta_origem'])) 	? $_POST['cdtipo_conta_origem'] : '';
	$cdtipo_conta_destino = (isset($_POST['cdtipo_conta_destino'])) ? $_POST['cdtipo_conta_destino'] : '';
	
    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= "     <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "     <tipcta_ori>".$cdtipo_conta_origem."</tipcta_ori>";
    $xml .= "     <tipcta_des>".$cdtipo_conta_destino."</tipcta_des>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_TIPCTA", "TRANSFERIR_TIPO_DE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
        
    }
	
	exibirErro('inform','Transfer&ecirc;ncia realizada com sucesso!','Alerta - Ayllos','estadoInicial();', false);
    
?>