<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 06/2019
 * OBJETIVO     : P565
 * --------------
 * ALTERAÇÕES   : 
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

	// Inicializa
	$retornoAposErro	= 'cDtinicial.focus();';
	// Recebe a operação que está sendo realizada
	$operacao	= (isset($_POST['operacao']))  ? $_POST['operacao']  : ''; 
	$tpremessa	= (isset($_POST['tpremessa'])) ? $_POST['tpremessa'] : '' ; 
	$tparquivo	= (isset($_POST['tparquivo'])) ? $_POST['tparquivo'] : 0 ; 
	$cdagenci	= (isset($_POST['cdagenci']))  ? $_POST['cdagenci']  : 0 ; 
	$dtinicial	= (isset($_POST['dtinicial'])) ? $_POST['dtinicial'] : '' ; 
	$dtfinal	= (isset($_POST['dtfinal']))   ? $_POST['dtfinal']   : '' ; 
	$nrregist   = (isset($_POST['nrregist']))  ? $_POST['nrregist']  : 0;
	$nriniseq   = (isset($_POST['nriniseq']))  ? $_POST['nriniseq']  : 0;
	$vcooper    = (isset($_POST['vcooper']))   ? $_POST['vcooper']   : -1;

	if ($cdagenci == ''){
		$cdagenci = 0;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$operacao)) <> '') {	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($operacao =='C') {// CONSULTA

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <vcooper>'.$vcooper.'</vcooper>';
		$xml .= '       <tpremessa>'.$tpremessa.'</tpremessa>';		
		$xml .= '       <cdagenci>'.$cdagenci.'</cdagenci>';		
		$xml .= '       <tparquivo>'.$tparquivo.'</tparquivo>';
		$xml .= '       <dtinicial>'.$dtinicial.'</dtinicial>';
		$xml .= '       <dtfinal>'.$dtfinal.'</dtfinal>';
		$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
		$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria(
			$xml,
			"TELA_MOVCMP",
			"CONSULTAMOVCMP",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);		
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) { //erro
			$aux_err = ($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata != '') ? $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata : $xmlObj->roottag->tags[0]->cdata;
			echo 'showError("error","'.$aux_err.'","Alerta - Ayllos","estadoInicial();");';
			return;
		} 

		$registros = $xmlObj->roottag->tags[0]->tags;	

		$total = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
		
		if ($total == 0){
			echo 'showError("error","Registro n&atilde;o encontrado! ","Alerta - Ayllos","estadoInicial();");';
		
		}else{
			if ($tpremessa == 'nr'){
				include("tab_movcmpnr.php");
			}else if ($tpremessa == 'sr'){
				include("tab_movcmpsr.php");
			}

		}		
		
		return;
	}
		
?>

