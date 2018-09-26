<?
/*!
 * FONTE        : busca_titulares.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : Abril/2014
 * OBJETIVO     : Consulta de titulares
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000:
 */
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);	
	}			
	
	// Verifica se o número da conta ou sequencial de titular foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	
	
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
		
	// Verifica se o número do titular é um inteiro válido
	if (!validaInteiro($idseqttl)) exibirErro('error','Titular inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);

	// Monta o xml de requisição
	$xmlGetCartao  = "";
	$xmlGetCartao .= "<Root>";
	$xmlGetCartao .= "	<Cabecalho>";
	$xmlGetCartao .= "		<Bo>b1wgen0059.p</Bo>";
	$xmlGetCartao .= "		<Proc>busca_crapttl</Proc>";
	$xmlGetCartao .= "	</Cabecalho>";
	$xmlGetCartao .= "	<Dados>";
	$xmlGetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCartao .= "		<nrregist>1</nrregist>";
	$xmlGetCartao .= "		<nriniseq>".$idseqttl."</nriniseq>";
	$xmlGetCartao .= "	</Dados>";
	$xmlGetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro,false);	
	} 	

	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	// Mostra a mensagem de informação para verificar atualização cadastral se for adm BB
	if ($idconfir == 1) {
		echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false)");';
	} else{
		$nrcgccpf = formatar($xmlObjCartao->roottag->tags[0]->tags[0]->tags[3]->cdata,'cpf',true);
		$dsmensag = "Titular inexistente";
		
		if ($nrcgccpf != null){
			echo ('$("#nrcpfcgc","#frmNovoCartao").val("'.$nrcgccpf.'");');
			echo ('$("#nmtitcrd","#frmNovoCartao").val("'.$xmlObjCartao->roottag->tags[0]->tags[0]->tags[2]->cdata.'");');
			echo ('$("#nmextttl","#frmNovoCartao").val("'.$xmlObjCartao->roottag->tags[0]->tags[0]->tags[2]->cdata.'");');
			echo ('$("#nrdoccrd","#frmNovoCartao").val("'.$xmlObjCartao->roottag->tags[0]->tags[0]->tags[8]->cdata.'");');
			echo ('$("#dtnasccr","#frmNovoCartao").val("'.$xmlObjCartao->roottag->tags[0]->tags[0]->tags[12]->cdata.'");');		
		}else{
			echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false)");';
		}		
	}		
?>