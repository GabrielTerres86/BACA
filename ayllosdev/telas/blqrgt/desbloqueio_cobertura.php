<?php
/*!
 * FONTE        : desbloqueio_cobertura.php                        Última alteração: 
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 10/11/2017
 * OBJETIVO     : Desbloqueia por cobertura de operação de crédito
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

	$idcobertura = (isset($_POST['idcobertura'])) ? $_POST['idcobertura'] : 0;
	$vldesblo    = (isset($_POST['vldesblo']))    ? $_POST['vldesblo']    : 0;
	$cdopelib    = (isset($_POST['cdopelib']))    ? $_POST['cdopelib']    : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'L')) <> '') {
    
        exibirErro('error',$msgError,'Alerta - Aimaro','',false);
    }
    
    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <idcobertura>".$idcobertura."</idcobertura>";
    $xml .= "     <vldesblo>".$vldesblo."</vldesblo>";
    $xml .= "     <cdopelib>".$cdopelib."</cdopelib>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_BLQRGT", "DESBLQ_COBERTURA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#vldesblo\',\'#frmValorDesbloq\').click();',false);
        
    }
	
	echo 'fechaRotina($(\'#divRotina\'));buscaBloqueios();';
	
?> 