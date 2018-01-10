<? 
/*!
 * FONTE        : busca_nome_pessoa.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 05/12/2017
 * OBJETIVO     : Rotina para buscar o nome da pessoa a partir do campo CPF/CNPJ.
 *
 */
?>
 
<?	
    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
    $nrdocnpj = $_POST['nrdocnpj'] == '' ?  0  : $_POST['nrdocnpj'];
    $nmdcampo = $_POST['nmdcampo'] == '' ?  0  : $_POST['nmdcampo'];
    $nmdoform = $_POST['nmdoform'] == '' ?  0  : $_POST['nmdoform'];
    
    

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<nrcpfcgc>".$nrdocnpj."</nrcpfcgc>";	
    $xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0008", "BUSCA_NOME_PESSOA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	$result = $xmlObjeto->roottag->tags;

	$nmpessoa = getByTagName($result,'nmpessoa');
	$idaltera = getByTagName($result,'idaltera');
    
    $nmpessoa = substr($nmpessoa,0,40);
    
    if ($nmpessoa != ""){
        echo "$('#".$nmdcampo."','#".$nmdoform."').val('".$nmpessoa."');";
    }
	
	if($idaltera == 1){
		echo "$('#".$nmdcampo."','#".$nmdoform."').prop('disabled', false).addClass('campo').removeClass('campoTelaSemBorda');";
	}else{
		echo "$('#".$nmdcampo."','#".$nmdoform."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
	}
?>	

