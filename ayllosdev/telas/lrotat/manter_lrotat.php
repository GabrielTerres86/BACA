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

    $acao = "";


    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
    $cdcodigo = (isset($_POST["cdcodigo"])) ? $_POST["cdcodigo"] : '';
    $tdesconto = (isset($_POST["tdesconto"])) ? $_POST["tdesconto"] : '';

    $descricao = (isset($_POST["descricao"])) ? $_POST["descricao"] : '';
    $QtxCapOp = (isset($_POST["QtxCapOp"])) ? str_replace(',','.',$_POST["QtxCapOp"]) : '';
    $DVcontOp = (isset($_POST["DVcontOp"])) ? str_replace(',','.',$_POST["DVcontOp"]) : '';
    $DVcontCe = (isset($_POST["DVcontCe"])) ? str_replace(',','.',$_POST["DVcontCe"]) : '';
    $qtdiavig = (isset($_POST["qtdiavig"])) ? str_replace(',','.',$_POST["qtdiavig"]) : '';
    $Tfixa = (isset($_POST["Tfixa"])) ? str_replace(',','.',$_POST["Tfixa"]) : '';
    $Tvar = (isset($_POST["Tvar"])) ? str_replace(',','.',$_POST["Tvar"]) : '';
    $dsencfin1 = (isset($_POST["dsencfin1"])) ? $_POST["dsencfin1"] : '';
    $dsencfin2 = (isset($_POST["dsencfin2"])) ? $_POST["dsencfin2"] : '';
    $dsencfin3 = (isset($_POST["dsencfin3"])) ? $_POST["dsencfin3"] : '';



    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    if($cddopcao == "A") {
        $acao = "ALTERALROTAT";
    } else {
        $acao = "INCLUILROTAT";
    }
    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddlinha>".$cdcodigo."</cddlinha>";        
    $xml       .= "     <dsdlinha>".$descricao."</dsdlinha>";
    $xml       .= "     <qtvezcap>".$QtxCapOp."</qtvezcap>";
    $xml       .= "     <qtdiavig>".$qtdiavig."</qtdiavig>";
    $xml       .= "     <vllimmax>".$DVcontOp."</vllimmax>";
    $xml       .= "     <txjurfix>".$Tfixa."</txjurfix>";
    $xml       .= "     <txjurvar>".$Tvar."</txjurvar>";
    $xml       .= "     <txmensal>".$Tvar."</txmensal>";
    $xml       .= "     <qtvcapce>".$QtxCapOp."</qtvcapce>";
    $xml       .= "     <vllmaxce>".$DVcontCe."</vllmaxce>";
    $xml       .= "     <dsencfin1>".$dsencfin1."</dsencfin1>";
    $xml       .= "     <dsencfin2>".$dsencfin2."</dsencfin2>";
    $xml       .= "     <dsencfin3>".$dsencfin3."</dsencfin3>";
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
                    
    } else {
        exibirErro('inform','Cadastro efetuado com sucesso.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
    }
        
    $linhas   = $xmlObjMotivos->roottag->tags[0]->tags[0];


    function validaDados(){
        
        //Codigo
        if ( $GLOBALS["cdcodigo"] == 0){ 
            exibirErro('error','Código inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').focus();',false);
        }
    
    }

?> 




<script type="text/javascript">
    
    buscaLinhaRotativo();
            
</script>