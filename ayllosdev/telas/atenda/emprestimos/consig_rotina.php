<?
/*!
 * FONTE        : consig_rotina.php 
 * CRIAÇÃO      : JDB - AMcom
 * DATA CRIAÇÃO : 03/2019
 * OBJETIVO     : Execução de operações da tela CONSIG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */
?>

<?
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '' ;
		
	
	
if ($operacao == 'SIMULA_CONSIGNADO'){
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>'; 
		$xml .= '       <cdlcremp>'.$cdlcremp.'</cdlcremp>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_ATENDA_SIMULACAO",
			"SIMULA_VALIDA_CONSIGNADO",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");
			
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","erConsig();");';
			return;
		}else if ( strtoupper($xmlObj->roottag->tags[0]->name) == "DSMENSAG"){
			$js  = 'ret = 0;';	
			echo $js;
			return;
		}
		else{			
			$js  = 'ret = 1;';									
			
			$js .= '_dtlibera = "'.getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags,'dtliberacao').'";';			
			$js .= '_dtdpagto = "'.getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags,'dtvencimento').'";';	
			echo $js;
			return;				
		} 
		
	}
	
	
	
?>