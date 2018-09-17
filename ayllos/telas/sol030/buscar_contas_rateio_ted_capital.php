<?php
/*!
 * FONTE        : buscar_contas_rateio_ted_capital.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Rotina responsável por buscar as contas da opção "G" da tela SOL030
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResult->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjResult->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}	
	
	$registros = $xmlObjResult->roottag->tags[0]->tags;
	$qtregist  = $xmlObjResult->roottag->attributes['QTREGIST'];
	$vlrtotal  = $xmlObjResult->roottag->attributes['VLRTOTAL'];
	
			
	include('tab_contas_rateio_ted_capital.php');	

 ?>
