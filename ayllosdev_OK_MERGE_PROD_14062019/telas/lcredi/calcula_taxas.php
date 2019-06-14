<?php
/*!
 * FONTE        : calcula_taxas.php                        Última alteração: 
 * CRIAÇÃO      : Andrei - RKAM
 * DATA CRIAÇÃO : Julho/2016
 * OBJETIVO     : Calcula a taxa mensal
 * --------------
 * ALTERAÇÕES   :  
 * --------------
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    require_once("../../includes/carrega_permissoes.php");

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
    $txjurvar = (isset($_POST["txjurvar"])) ? $_POST["txjurvar"] : 0;
    $txjurfix = (isset($_POST["txjurfix"])) ? $_POST["txjurfix"] : 0;
    $txminima = (isset($_POST["txminima"])) ? $_POST["txminima"] : 0;
    $txmaxima = (isset($_POST["txmaxima"])) ? $_POST["txmaxima"] : 0;
    $nmdcampo = (isset($_POST["nmdcampo"])) ? $_POST["nmdcampo"] : '';
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }    
            
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";   
    $xml       .= "     <txjurvar>".$txjurvar."</txjurvar>"; 
    $xml       .= "     <txjurfix>".$txjurfix."</txjurfix>"; 
    $xml       .= "     <txminima>".$txminima."</txminima>"; 
    $xml       .= "     <txmaxima>".$txmaxima."</txmaxima>"; 
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LCREDI", "CALCTAXAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjTaxa = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjTaxa->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjTaxa->roottag->tags[0]->tags[0]->tags[4]->cdata;
        
		    if(empty ($nmdcampo)){ 
			    $nmdcampo = "txjurvar";
		    }

		    exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioConsulta();focaCampoErro(\''.$nmdcampo.'\',\'frmConsulta\');',false);		
			                            
    } 
        
    $txmensal  = $xmlObjTaxa->roottag->attributes["TXMENSAL"];
    $txdiaria  = $xmlObjTaxa->roottag->attributes["TXDIARIA"];

    echo "$('#txmensal','#frmConsulta').val('".$txmensal."');";
    echo "$('#txdiaria','#frmConsulta').val('".$txdiaria."');";
    
    echo 'formataFormularioConsulta();';  
    echo "$('#".$nmdcampo."','#frmConsulta').focus();";
 ?>




