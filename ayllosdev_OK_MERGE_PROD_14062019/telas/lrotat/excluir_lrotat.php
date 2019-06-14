<?php
/*!
 * FONTE        : excluir_lrotat.php                        Última Alteração: 12/07/2016
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 06/07/2016
 * OBJETIVO     : Responsável pela exclusão de linhas de crédito rotativo
 * --------------
 * ALTERAÇÕES   :  12/07/2016 - Ajustes para finzaliZação da conversáo 
                                (Andrei - RKAM)
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
    
    validaDados();

    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";
    $xml       .= "     <cddlinha>".$cddlinha."</cddlinha>";    
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", "EXCLUILROTAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
                    
    } else {
        
        exibirErro('inform','Cr&eacute;dito rotativo removido com sucesso.','Alerta - Ayllos','btnVoltar(2);',false);     

    }

    function validaDados(){
        
         //Codigo
        if ( $GLOBALS["cddlinha"] == 0){ 
            exibirErro('error','C&oacute;digo inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLrotat\').focus();',false);
        }
    
    }
?>
