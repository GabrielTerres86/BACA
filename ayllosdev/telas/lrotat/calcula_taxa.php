<?php
/*!
 * FONTE        : calcula_taxa.php                        Última Alteração: 
 * CRIAÇÃO      : Andrei - RKAM
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Realiza o cálculo da taxa
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
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";
    $xml       .= "     <txjurvar>".$txjurvar."</txjurvar>";    
    $xml       .= "     <txjurfix>".$txjurfix."</txjurfix>";    
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", "CALCTAXA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjTaxa = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
                    
    }
	
	$txmensal  = $xmlObjTaxa->roottag->attributes["TXMENSAL"];

	echo '$("#txmensal","#frmLrotat").val("'.$txmensal.'");';
	echo 'formataFormularioLrotat();';
	echo "trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'manterLrotat();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');";
	        
	
?>
