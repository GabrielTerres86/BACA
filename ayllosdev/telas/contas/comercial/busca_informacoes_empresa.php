<? 
/*!
 * FONTE        : busca_informacoes_empresa.php
 * CRIAÇÃO      : Kelvin Ott
 * DATA CRIAÇÃO : 05/12/2017
 * OBJETIVO     : Rotina para buscar informacoes da empresa de acordo com o codigo.
 *
 * ALTERACOES   : 
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
    $cdempres = $_POST['cdempres'] == '' ?  0  : $_POST['cdempres'];

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<cdempres>".$cdempres."</cdempres>";	
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0008", "BUSCA_INFO_EMPRESA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	$result = $xmlObjeto->roottag->tags;

	$nmpessoa = getByTagName($result,'nmpessoa');
	$idaltera = getByTagName($result,'idaltera');
	$nrdocnpj = getByTagName($result,'nrdocnpj');
    
    $nmpessoa = substr($nmpessoa,0,40);
	
	if(!isset($operacao)){
		
		if($idaltera == 1){			
			echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
			echo "$('#nrcpfemp').val('".$nrdocnpj."').prop('disabled', false).addClass('campo').removeClass('campoTelaSemBorda').attr('readonly', false);";
		}else{
			
			echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
			echo "$('#nrcpfemp').val('".$nrdocnpj."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
		}
	}
?>	
