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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$tpconta = (isset($_POST['tpconta'])) ? $_POST['tpconta'] : '';
	
    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <inpessoa>"	.$inpessoa	."</inpessoa>";
    $xml .= "     <tpconta>"	.$tpconta	."</tpconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0006", "EXCLUIR_TIPO_CONTA_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
        
    }
	
	exibirErro('inform','Tipo de Conta exclu&iacute;do com sucesso.','Alerta - Ayllos','consultaTipoConta();', false);
    
?>