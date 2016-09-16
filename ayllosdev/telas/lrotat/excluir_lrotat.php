<?php
/*!
 * FONTE        : ldesco.php                        Última alteração: 
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 17/11/2016
 * OBJETIVO     : Mostrar tela LDESCO
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

    $cdcodigo = (isset($_POST["cdcodigo"])) ? $_POST["cdcodigo"] : '';
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddlinha>".$cdcodigo."</cddlinha>";    
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
        
        exibirErro('inform','Crédito Rotativo removido com sucesso.','Alerta - Ayllos','$(\'#btnVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     

    }

    function validaDados(){
        
        //Codigo
        if ( $GLOBALS["cdcodigo"] == 0){ 
            exibirErro('error','Código inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').focus();',false);
        }
    
    }
?>

<script type="text/javascript">
    btnVoltar(2);
</script>