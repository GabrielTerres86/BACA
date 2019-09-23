<? 
/*!
 * FONTE        : busca_informacoes_empresa.php
 * CRIAÇÃO      : Kelvin Ott
 * DATA CRIAÇÃO : 05/12/2017
 * OBJETIVO     : Rotina para buscar informacoes da empresa de acordo com o codigo.
 *
 * ALTERACOES   : 09/08/2018 - Incluir conta e titular na chamada da rotina INC0021468 (Heitor - Mouts)
 *				  20/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para	
 *                             corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
 *                07/03/2019 - Nome da empresa sera retornado pelo fonte busca_nome_pessoa.php,
 *                             este fonte ira fazer controle de permissao ou nao de alteracoes.
 *                             Gabriel Marcos (Mouts) - Chamado PRB0040571.
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
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$nrcpfemp = $_POST['nrcpfemp'] == '' ?  0  : $_POST['nrcpfemp'];
	$nmextemp = $_POST['nmextemp'];

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<cdempres>".$cdempres."</cdempres>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<nrdocnpj>".$nrcpfemp."</nrdocnpj>";
	$xml .= "		<nmpessoa>".$nmextemp."</nmpessoa>";
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
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$result = $xmlObjeto->roottag->tags;

	$nmpessoa = substr(getByTagName($result,'nmpessoa'),0,40);
	$idaltera = getByTagName($result,'idaltera');
	$nrcnpjot = getByTagName($result,'nrcnpjot');
	$cdemprot = getByTagName($result,'cdemprot');
	$nmempout = getByTagName($result,'nmempout');
	
	if(!isset($operacao)){
		
		if($idaltera == 1){			
			echo "$('#nmresemp').val('".$nmempout."');";
			echo "$('#cdempres').val('".$cdemprot."');";
		    //echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', false).addClass('campo').removeClass('campoTelaSemBorda').attr('readonly', false);";
			echo "$('#nrcpfemp').val('".$nrcnpjot."').prop('disabled', false).addClass('campo').removeClass('campoTelaSemBorda').attr('readonly', false);";
			// [PJ485.6] Validação para empregador PF
			if ($cdemprot == 9998) {
				echo "$('label[for=\"nrcpfemp\"]').html('CPF:');";
				echo "$('#nrcpfemp').addClass('cpf').removeClass('cnpj');";
				//echo "$('#nmextemp').habilitaCampo();";
				
			} else {
				echo "$('label[for=\"nrcpfemp\"]').html('CNPJ:');";
				echo "$('#nrcpfemp').addClass('cnpj').removeClass('cpf');";
				//echo "$('#nmextemp').desabilitaCampo();";
			}
			
		}else{			
			echo "$('#nmresemp').val('".$nmempout."');";		
			echo "$('#cdempres').val('".$cdemprot."');";
			echo "$('#nmextemp').val('".$nmpessoa."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
			echo "$('#nrcpfemp').val('".$nrcnpjot."').prop('disabled', true).addClass('campoTelaSemBorda').removeClass('campo');";
		}
		echo "controlaCpfCnpj();";
	}
?>	
