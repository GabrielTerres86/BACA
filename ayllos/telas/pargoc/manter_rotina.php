<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIA��O      : Lucas Afonso
 * DATA CRIA��O : 05/10/2017
 * OBJETIVO     : Rotina para altera��o dos parametros da tela PARGOC
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = isset($_POST["cddopcao"]) ? $_POST["cddopcao"] : "";
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : ""; // Cooperativa selecionada
	$inresgate_automatico = isset($_POST["inresgate_automatico"]) ? $_POST["inresgate_automatico"] : ""; // Resgate Autom�tico
	$qtdias_atraso_permitido = isset($_POST["qtdias_atraso_permitido"]) ? $_POST["qtdias_atraso_permitido"] : ""; // Dias de atraso p/ resgate autom�tico
	$peminimo_cobertura = isset($_POST["peminimo_cobertura"]) ? $_POST["peminimo_cobertura"] : ""; // % M�n Cobertura p/ Garantia
	
	// MESAGERIA
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <inresgate_automatico>".$inresgate_automatico."</inresgate_automatico>";
	$xml .= "   <qtdias_atraso_permitido>".$qtdias_atraso_permitido."</qtdias_atraso_permitido>";
	$xml .= "   <peminimo_cobertura>".$peminimo_cobertura."</peminimo_cobertura>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARGOC", "ALTERA_PARAMS_PARGOC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
		}
	} 
	
	exibirErro('inform','Altera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',"estadoInicial();",false);
?>