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
    $taxamora = (isset($_POST["taxamora"])) ? str_replace(',','.',$_POST["taxamora"]) : '';
    $qtvias = (isset($_POST["qtvias"])) ? str_replace(',','.',$_POST["qtvias"]) : '';
    $taxamensal = (isset($_POST["taxamensal"])) ? str_replace(',','.',$_POST["taxamensal"]) : '';
    $tarifa = (isset($_POST["tarifa"])) ? str_replace(',','.',$_POST["tarifa"]) : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    if($cddopcao == "A") {
        $acao = "LDESCO_ALTERAR_LINHA";
    } else {
        $acao = "LDESCO_INCLUIR_LINHA";
    }
    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";    
    $xml       .= "     <cddlinha>".$cdcodigo."</cddlinha>";    
    $xml       .= "     <tpdescto>".$tdesconto."</tpdescto>"; 
    $xml       .= "     <dsdlinha>".$descricao."</dsdlinha>";
    $xml       .= "     <txmensal>".$taxamensal."</txmensal>";
    $xml       .= "     <txjurmor>".$taxamora."</txjurmor>";
    $xml       .= "     <nrdevias>".$qtvias."</nrdevias>";
    $xml       .= "     <flgtarif>".$tarifa."</flgtarif>";
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LDESCO", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);     
                    
    } else {
        // exibirErro('inform','Cadastro efetuado com sucesso.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
    }
        
    $linhas   = $xmlObjMotivos->roottag->tags[0]->tags[0];


    function validaDados(){
        
        //Codigo
        if ($GLOBALS["cdcodigo"] == 0){ 
            exibirErro('error','Código inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').focus();',false);
        }

        if ($GLOBALS["descricao"] == ''){ 
            exibirErro('error','Informe uma descrição.','Alerta - Ayllos','$(\'#descricao\',\'#frmLdesco\').focus();',false);
        }

        if ($GLOBALS["qtvias"] == 0 || $GLOBALS["qtvias"] == ''){ 
            exibirErro('error','Informe a quantidade de vias.','Alerta - Ayllos','$(\'#qtvias\',\'#frmLdesco\').focus();',false);
        }
    
    }

?> 




<script type="text/javascript">
    
    buscaLinhaDesconto();
            
</script>