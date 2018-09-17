<?php
/*!
 * FONTE        : bsuca_lrotat.php                        Última alteração: 12/07/2016
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 06/07/2016
 * OBJETIVO     : Busca as linhas de crédito rotativo
 * --------------
 * ALTERAÇÕES   :  12/07/2016 - Ajustes para finzaliZação da conversáo 
 *                              (Andrei - RKAM)
 *
 *                 05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                              departamento como parametros e passar o o código e alterar a validação
 *                              do deparetamento para tratar pelo código do mesmo (Renato Darosci)
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
    $cddlinha = (isset($_POST["cddlinha"])) ? $_POST["cddlinha"] : '';
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    if($cddopcao != 'A' && $cddopcao != 'C'){
    
		    if($glbvars["cddepart"] != 8  &&  /* COORD.ADM/FINANCEIRO */
		       $glbvars["cddepart"] != 14 &&  /* PRODUTOS */
		       $glbvars["cddepart"] != 20) {  /* TI */
          
          exibirErro('error','Sistema liberado apenas para Consulta e Altera&ccedil;&atilde;o!','Alerta - Ayllos','formataFormularioFiltro();focaCampoErro(\'cddlinha\',\'frmFiltro\');',false);
        }
        
    }
        
    validaDados();
    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";    
    $xml       .= "     <cddlinha>".$cddlinha."</cddlinha>";   
    $xml       .= "     <cddepart>".$glbvars['cddepart']."</cddepart>"; 
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", "CONSULTALROTAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjLinhas = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjLinhas->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjLinhas->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $nmdcampo = $xmlObjLinhas->roottag->tags[0]->attributes["NMDCAMPO"];

		    if(empty ($nmdcampo)){ 
			    $nmdcampo = "cddlinha";
		    }

		    exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioFiltro();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
			                            
    } 
        
    $linhas   = $xmlObjLinhas->roottag->tags[0]->tags[0];

    include('form_lrotat.php'); 		

    function validaDados(){
        
        //Codigo
        if ( $GLOBALS["cddlinha"] == 0){ 
            exibirErro('error','C&oacute;digo inv&aacute;lido.','Alerta - Ayllos','formataFormularioFiltro();focaCampoErro(\'cddlinha\',\'frmFiltro\');',false);
        }
        
    }

?> 




