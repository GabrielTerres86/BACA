<?php
/*!
 * FONTE        : form_desligamento.php
 * CRIAÇÃO      : Mateus Zimmermann (MoutS)
 * DATA CRIAÇÃO : 25/07/2017
 * OBJETIVO     : Retornar dados para o formulario de desligamento
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	
    require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
  
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;

    // Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml  .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_CADMAT", "BUSCA_DADOS_DESLIGAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
    if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {    
        $msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;          
        exibirErro('error',$msgErro,'Alerta - Cadmat','estadoInicial();',false);
        exit();
    }

    $registro = ( isset($xmlObjeto->roottag->tags) ) ? $xmlObjeto->roottag->tags : array();
  
	include('form_desligamento.php');

?>
