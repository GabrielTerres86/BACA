<?php
	/*!
	 * FONTE        : gerar_relatorio_historico.php                 Última alteração: 14/07/2016
	 * CRIAÇÃO      : Andrei - RKAM
	 * DATA CRIAÇÃO : Maio/2016
	 * OBJETIVO     : Rotina para gerar relatorio de histórico dos gravames
	 * --------------
	 * ALTERAÇÕES   :  14/07/2016 - Ajuste na mensagem de erro ao validar a conta (Andrei - RKAM).
	 * -------------- 
	 */		

  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
  $nrctrpro = isset($_POST["nrctrpro"]) ? $_POST["nrctrpro"] : 0;
  $cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
  $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
  $xml .= "   <nrctrpro>".$nrctrpro."</nrctrpro>";
  $xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";				
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "GRVM0001", "RELHISTORICO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
    
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltroHistorico(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	$nmarquiv  =  $xmlObj->roottag->attributes["NMARQUIV"];

	echo 'Gera_Impressao("'.$nmarquiv.'","estadoInicial();");';			
		
	
	
	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','formataFiltroHistorico();focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
		}
    
    IF($GLOBALS["nrctrpro"] == 0 ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos','formataFiltroHistorico();focaCampoErro(\'nrctrpro\',\'frmFiltro\');',false);
		}
				
	}	
		
?>
