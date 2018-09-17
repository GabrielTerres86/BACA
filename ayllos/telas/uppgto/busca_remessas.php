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
	$nrremess = isset($_POST["nrremess"]) ? $_POST["nrremess"] : "";
	$nmarquiv = isset($_POST["nmarquiv"]) ? $_POST["nmarquiv"] : "";
	$nmbenefi = isset($_POST["nmbenefi"]) ? $_POST["nmbenefi"] : "";
	$dscodbar = isset($_POST["dscodbar"]) ? $_POST["dscodbar"] : "";
	$idstatus = isset($_POST["idstatus"]) ? $_POST["idstatus"] : 1;
	$tpdata   = isset($_POST["dtrefere"]) ? $_POST["dtrefere"] : 1;
	$dtiniper = isset($_POST["dtiniper"]) ? $_POST["dtiniper"] : "";
	$dtfimper = isset($_POST["dtfimper"]) ? $_POST["dtfimper"] : "";
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrremess>".$nrremess."</nrremess>";	
	$xml .= "   <nmarquiv>".$nmarquiv."</nmarquiv>";
	$xml .= "   <nmbenefi>".$nmbenefi."</nmbenefi>";
	$xml .= "   <dscodbar>".$dscodbar."</dscodbar>";
	$xml .= "   <idstatus>".$idstatus."</idstatus>";
	$xml .= "   <tpdata>".$tpdata."</tpdata>";
	$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
	$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <iniconta>".$nriniseq."</iniconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PGTA0001", "CONSULTARTITCONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmConsulta\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmConsulta\');',false);		
		
	} 
	
	$registros =  $xmlObj->roottag->tags[0]->tags[1]->tags;
	$qtregist  =  $xmlObj->roottag->tags[0]->tags[0]->cdata;

	if (count($registros) == 0) { 		
		exibirErro('inform','Nenhuma Remessa foi encontrada para estas condi&ccedil;&atilde;es.','Alerta - Ayllos','$(\'input,select\',\'#frmConsulta\').habilitaCampo();$(\'#nrdconta\',\'#frmConsulta\').focus();');		
	} else {      
	
		include('tab_registros.php'); 	

		?>
		<script type="text/javascript">

			$('#divTabela').css('display','block');
			$('#frmDetalhes').css('display','block');
			
			trocaBotao('CONSULTA');
			
			formataDetalhes();
			formataTabelaRemessas();
			
		</script>

		<?
			
	}	

	function validaDados(){
		IF(($GLOBALS["cddopcao"] == 'C' && $GLOBALS["nrdconta"] == 0)){ 
			exibirErro('error','Conta deve ser informada.','Alerta - Ayllos','$(\'input,select\',\'#frmConsulta\').habilitaCampo();focaCampoErro(\'cdagenci\',\'frmConsulta\');',false);
		}
	}	
		
?>
