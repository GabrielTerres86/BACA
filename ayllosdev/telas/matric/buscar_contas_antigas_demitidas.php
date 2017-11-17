<?php
/*!
 * FONTE        : buscar_contas_antigas_demitidas.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Novembro/2017
 * OBJETIVO     : Rotina responsável por buscar as contas antigas demitidas  - Opção "H" da tela Matric
 * --------------
 * ALTERAÇÕES   :  
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"G")) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
	
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
  $nrdconta = isset($_POST["numeroConta"]) ? $_POST["numeroConta"] : 0;
	  
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
  $xml .= "     <nrregist>".$nrregist."</nrregist>";	
	$xml .= "     <nriniseq>".$nriniseq."</nriniseq>";
  $xml .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADA0003", "LISTA_CONTAS_ANT_DEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaVoltar();',false);		
							
	}   	
	
	$registros = $xmlObj->roottag->tags;
	$qtregist  = $xmlObj->roottag->attributes['QTREGIST'];
  $vlrtotal  = $xmlObj->roottag->attributes['VLRTOTAL'];
  $qtdContas = count($registros);	
			
	include('tab_contas_antigas_demitidas.php');	

 ?>
