<?php
/*!
 * FONTE        : buscar_contas_rateio_ted_capital.php                    �ltima altera��o:
 * CRIA��O      : Jonata (RKAM)
 * DATA CRIA��O : Junho/2017
 * OBJETIVO     : Rotina respons�vel por buscar as contas da op��o "G" da tela SOL030
 * --------------
 * ALTERA��ES   :  
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

    // Carrega permiss�es do operador
    require_once('../../includes/carrega_permissoes.php');

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';    
	
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
	
	$flctadst = isset($_POST["flctadst"]) ? $_POST["flctadst"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	  
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= "       <flctadst>".$flctadst."</flctadst>";	
	$xml .= "       <nrregist>".$nrregist."</nrregist>";	
	$xml .= "       <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SOL030", "BUSCAR_CONTA_RATEIO_TED_CAPITAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjResult = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjResult->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjResult->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}	
	
	$registros = $xmlObjResult->roottag->tags[0]->tags;
	$qtregist  = $xmlObjResult->roottag->attributes['QTREGIST'];
	$vlrtotal  = $xmlObjResult->roottag->attributes['VLRTOTAL'];
	
			
	include('tab_contas_rateio_ted_capital.php');	

 ?>
