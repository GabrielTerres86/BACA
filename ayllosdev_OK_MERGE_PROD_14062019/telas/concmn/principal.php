<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 04/2019
 * OBJETIVO     : P530
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
	$retornoAposErro	= 'cNrdconta.focus();';
	
	// Recebe a operação que está sendo realizada
	$operacao	= (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrcpfcnpj	= (isset($_POST['nrcpfcnpj'])) ? $_POST['nrcpfcnpj'] : 0 ; 
	$nrregist   = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq   = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
	$vcooper    = (isset($_POST['vcooper'])) ? $_POST['vcooper'] : -1;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$operacao)) <> '') {	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($operacao =='C') {// CONSULTA

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '       <nrcpfcgc>'.$nrcpfcnpj.'</nrcpfcgc>';
		$xml .= '       <vcooper>'.$vcooper.'</vcooper>';
		$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
		$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';


		$xmlResult = mensageria(
			$xml,
			"TELA_CONCMN",
			"CONSULTACONCMN",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","estadoInicial();");';
			return;
		} //erro
		$xml = simplexml_load_string($xmlResult);
		$total = xml_attribute($xml->dados[0], 'qtregist');	
		
		if ($total == 0){
			echo 'showError("error","Registro n&atilde;o encontrado! ","Alerta - Ayllos","estadoInicial();");';
		
		}else{
			//root/dados/inf
			$registros = $xml->inf;
			include("tab_concmn.php");
		}		
		
		return;
	}
	

function xml_attribute($object, $attribute)
{
    if(isset($object[$attribute]))
        return (string) $object[$attribute];
}	
?>

