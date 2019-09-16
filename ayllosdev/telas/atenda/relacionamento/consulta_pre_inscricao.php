<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 12/12/2018;
 * Ultima alteração: 05/07/2019 - Destacar evento do cooperado - P484.2 - Gabriel Marcos (Mouts).
 * 
 * Alterações:
 */

    session_start();

    // Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
    require_once("../../../includes/config.php");
    require_once("../../../includes/funcoes.php");		
    require_once("../../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m&eacute;todo POST
    isPostMethod();	
        
    // Classe para leitura do xml de retorno
    require_once("../../../class/xmlfile.php");

    $nrdconta = $_POST['nrdconta'];
    $nmdgrupo = $_POST['nmdgrupo'];
    $cdcooper = $glbvars['cdcooper'];
    //$nrcpfcgc = $_POST['nrcpfcgc'];
    $nrcpfcgc = preg_replace( '/[^0-9]/', '', $_POST["nrcpfcgc"]);

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "	<Dados>";
    $xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";
		
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "RETORNA_GRUPO_CPF",  //   LISTA_FORNECEDORES
                            $glbvars["cdcooper"],
                            $glbvars["cdagenci"], 
                            $glbvars["nrdcaixa"], 
                            $glbvars["idorigem"], 
                            $glbvars["cdoperad"], 
                            "</Root>");
    
    //$xmlObj = getObjectXML($xmlResult);
    $xmlObj = new SimpleXMLElement($xmlResult);

    $retorno = array(
        'retorno' => array(),
        'erro' => ''
    );

    if(isset($xmlObj->{'Erro'})){
        $retorno['erro'] = (string) $xmlObj->{'Erro'}->{'Registro'}->{'dscritic'};
    }else{
        $grupo = "";
        $retorno['retorno']['nmdgrupo'] = (string) $xmlObj->{'inf'}->{'nmdgrupo'};
    }

    echo json_encode($retorno);
?>