<? 
/*!
 * FONTE        : busca_nome_pessoa.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 05/12/2017
 * OBJETIVO     : Rotina para buscar o nome da pessoa a partir do campo CPF/CNPJ.
 *
 * ALTERACOES   :  12/12/2017 - Ajustado rotina para exibir apenas os primeiros 40 caracts
 *                              pois tamanho da tabela apenas permite.
 *                              PRJ339 - CRM(Odirlei-AMcom)
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
    $nrcpfemp = $_POST['nrcpfemp'] == '' ?  0  : $_POST['nrcpfemp'];

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<nrcpfcgc>".$nrcpfemp."</nrcpfcgc>";	
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
    
    $nmpessoa = substr($nmpessoa,1,40);
	
	if($idaltera == 1){
		echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', false).addClass('campo').removeClass('campoTelaSemBorda');";
	}else{
		echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
	}
?>	
