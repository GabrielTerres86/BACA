<? 
/*!
 * FONTE        : busca_remessas.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : Setembro/2017 
 * OBJETIVO     : Busca os registros de remessas
 * --------------
 * ALTERAÇÕES   : 
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
	$nmarquiv = isset($_POST["nmarquiv"]) ? $_POST["nmarquiv"] : "";
	$nrremess = isset($_POST["nrremess"]) ? $_POST["nrremess"] : 0;
	$dtiniper = isset($_POST["dtiniper"]) ? $_POST["dtiniper"] : "";
	$dtfimper = isset($_POST["dtfimper"]) ? $_POST["dtfimper"] : "";

	//$nrdconta = "8879737";
	//$nmarquiv = "243";
	//$tpdata = "";
	//$idstatus = "";
	//pr_nrdconta, pr_nrconven, pr_nmtabela, pr_nmarquivo, pr_dtinilog, pr_dtfimlog
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrconven>1</nrconven>";
	$xml .= "   <nmtabela>CRAPHPT</nmtabela>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nmarquivo>".$nmarquiv."</nmarquivo>";
	$xml .= "   <nrremret>".$nrremret."</nrremret>";	
	$xml .= "   <dtinilog>".$dtiniper."</dtinilog>";
	$xml .= "   <dtfimlog>".$dtfimper."</dtfimlog>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PGTA0001", "CONSULTARLOGARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmConsultaLog\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmConsultaLog\');',false);		
		exit();
		
	} 
	
	$registros =  $xmlObj->roottag->tags[0]->tags;

	if (count($registros) == 0) { 		
		exibirErro('inform','Nenhum Log de Remessa foi encontrado para estas condi&ccedil;&otilde;es.','Alerta - Ayllos','$(\'input,select\',\'#frmConsultaLog\').habilitaCampo();$(\'#nmprimtl\',\'#frmConsultaLog\').desabilitaCampo();$(\'#nrdconta\',\'#frmConsultaLog\').focus();');		
	} else {      
	
		include('tab_registros_log.php'); 	

		?>
		<script type="text/javascript">

			$('#divTabela').css('display','block');			
			trocaBotao('LOG');
			
			formataTabelaRemessasLog();
			
		</script>

		<?
			
	}	
		
?>
