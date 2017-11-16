<?php
/*!
 * FONTE        : manter_lrotat.php                        Última alteração: 11/10/2017
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 06/07/2016
 * OBJETIVO     : Responsável por realizar a inclusão/alteração da linha de crédito rotativo
 * --------------
 * ALTERAÇÕES   : 12/07/2016 - Ajustes para finzaliZação da conversáo 
 *                             (Andrei - RKAM) 
 *
 *				  11/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
 * --------------
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    require_once("../../includes/carrega_permissoes.php");

    $acao = "";

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
    $cddlinha = (isset($_POST["cddlinha"])) ? $_POST["cddlinha"] : 0;

    $dsdlinha = (isset($_POST["dsdlinha"])) ? $_POST["dsdlinha"] : '';
    $tpdlinha = (isset($_POST["tpdlinha"])) ? $_POST["tpdlinha"] : 0;
    $qtvezcap = (isset($_POST["qtvezcap"])) ? $_POST["qtvezcap"] : 0;
    $qtvcapce = (isset($_POST["qtvcapce"])) ? $_POST["qtvcapce"] : 0;
    $vllimmax = (isset($_POST["vllimmax"])) ? $_POST["vllimmax"] : 0;
    $vllmaxce = (isset($_POST["vllmaxce"])) ? $_POST["vllmaxce"] : 0;
    
    $tpctrato = (isset($_POST["tpctrato"])) ? $_POST["tpctrato"] : 0;
    $permingr = (isset($_POST["permingr"])) ? $_POST["permingr"] : 0;
    
    $qtdiavig = (isset($_POST["qtdiavig"])) ? $_POST["qtdiavig"] : 0;
    $txjurfix = (isset($_POST["txjurfix"])) ? $_POST["txjurfix"] : 0;
    $txjurvar = (isset($_POST["txjurvar"])) ? $_POST["txjurvar"] : 0;
    $txmensal = (isset($_POST["txmensal"])) ? $_POST["txmensal"] : 0;
    $dsencfin1 = (isset($_POST["dsencfin1"])) ? $_POST["dsencfin1"] : '';
    $dsencfin2 = (isset($_POST["dsencfin2"])) ? $_POST["dsencfin2"] : '';
    $dsencfin3 = (isset($_POST["dsencfin3"])) ? $_POST["dsencfin3"] : '';
    $origrecu = (isset($_POST["origrecu"])) ? $_POST["origrecu"] : '';
    $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : '';
    $cdsubmod = (isset($_POST["cdsubmod"])) ? $_POST["cdsubmod"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    if($cddopcao == "A") {
    
        $acao = "ALTERALROTAT";  
        $mensagem = 'alterada';
          
        
    } else {
        $acao = "INCLUILROTAT";
        $mensagem = 'incluida';
    }
    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";  
    $xml       .= "     <cddlinha>".$cddlinha."</cddlinha>";        
    $xml       .= "     <tpdlinha>".$tpdlinha."</tpdlinha>";        
    $xml       .= "     <dsdlinha>".$dsdlinha."</dsdlinha>";
    $xml       .= "     <qtvezcap>".$qtvezcap."</qtvezcap>";
    $xml       .= "     <qtdiavig>".$qtdiavig."</qtdiavig>";
    $xml       .= "     <vllimmax>".$vllimmax."</vllimmax>";
    $xml       .= "     <txjurfix>".$txjurfix."</txjurfix>";
    $xml       .= "     <txjurvar>".$txjurvar."</txjurvar>";
    $xml       .= "     <txmensal>".$txmensal."</txmensal>";
    $xml       .= "     <qtvcapce>".$qtvcapce."</qtvcapce>";
    $xml       .= "     <vllmaxce>".$vllmaxce."</vllmaxce>";
    $xml       .= "     <dsencfin1>".$dsencfin1."</dsencfin1>";
    $xml       .= "     <dsencfin2>".$dsencfin2."</dsencfin2>";
    $xml       .= "     <dsencfin3>".$dsencfin3."</dsencfin3>";
    $xml       .= "     <origrecu>".$origrecu."</origrecu>";
    $xml       .= "     <cdmodali>".$cdmodali."</cdmodali>";
    $xml       .= "     <cdsubmod>".$cdsubmod."</cdsubmod>";
    if($cddopcao == "I") {
		$xml   .= "     <tpctrato>".$tpctrato."</tpctrato>";
	}
    $xml       .= "     <permingr>".$permingr."</permingr>";
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		    if(empty ($nmdcampo)){ 
			    $nmdcampo = "nrdconta";
		    }
		
		    if($msgErro == null || $msgErro == ''){
			    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		    }  
            
        exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioLrotat(); focaCampoErro(\''.$nmdcampo.'\',\'frmLrotat\');',false);		
		 
    } 
           
    exibirErro('inform','Linha de cr&eacute;dito '.$mensagem.' com sucesso.','Alerta - Ayllos','estadoInicial();',false);  
    
       
    function validaDados(){
        
        //Codigo
        if ( $GLOBALS["cddlinha"] == 0){ 
            exibirErro('error','C&oacute;digo inv&aacute;lido.','Alerta - Ayllos','formataFormularioLrotat();focaCampoErro(\'cddlinha\',\'frmLrotat\');',false);
        }
        
        //Descrição da linha
        if ( $GLOBALS["dsdlinha"] == ''){ 
            exibirErro('error','Descri&ccedil;&atilde;o da linha inv&aacute;lida.','Alerta - Ayllos','formataFormularioLrotat();focaCampoErro(\'dsdlinha\',\'frmLrotat\');',false);
        }
        
        //Quantidade de dia vigência
        if ( $GLOBALS["qtdiavig"] == 0){ 
            exibirErro('error','Dias de vig&ecirc;ncia do contrato inv&aacute;lido.','Alerta - Ayllos','formataFormularioLrotat();focaCampoErro(\'qtdiavig\',\'frmLrotat\');',false);
        }
		
		IF($GLOBALS["tpctrato"] != 1 && $GLOBALS["tpctrato"] != 4){ 
			exibirErro('error','Modelo de contrato inv&aacute;lido.','Alerta - Ayllos','formataFormularioConsulta();focaCampoErro(\'tpctrato\',\'frmLrotat\');',false);
		}
		
		IF(($GLOBALS["permingr"] < 0.01 && $GLOBALS["tpctrato"] == 4) || $GLOBALS["permingr"] > 300){ 
			exibirErro('error','Percentual minimo da cobertura da garantia de aplicacao inv&aacute;lido. Deve ser entre \"0.01\" e \"300\".','Alerta - Ayllos','formataFormularioConsulta();focaCampoErro(\'permingr\',\'frmLrotat\');',false);
        }
        
        //Código da modalidade
        if ( $GLOBALS["cdmodali"] == 0){ 
            exibirErro('error','C&oacute;digo da modalidade deve ser informado.','Alerta - Ayllos','formataFormularioLrotat();focaCampoErro(\'cdmodali\',\'frmLrotat\');',false);
        }
        
        //Código da submodalidade
        if ( $GLOBALS["cdsubmod"] == 0){ 
            exibirErro('error','C&oacute;digo da submodalidade deve ser informado.','Alerta - Ayllos','formataFormularioLrotat();focaCampoErro(\'cdsubmod\',\'frmLrotat\');',false);
        }
    
    }

?> 
