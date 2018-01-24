<? 
/*!
 * FONTE        : manter_rotina.php								Última alteração: 08/03/2017
 * CRIAÇÃO      : Carlos Henrique
 * DATA CRIAÇÃO : 22/12/2015 
 * OBJETIVO     : Rotina para validar/alterar os dados da PPE da tela de CONTAS, Comercial
 *
 * ALTERACOES   :  08/03/2017 - Ajuste para receber a informação nmemporg (Adriano - SD 614408).
 */
session_cache_limiter("private");
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	
	$tpexposto        = (isset($_POST['tpexposto'])) ?        $_POST['tpexposto']        : '';
	$cdocpttl         = (isset($_POST['cdocpttl'])) ?         $_POST['cdocpttl']         : '';	
	$cdrelacionamento = (isset($_POST['cdrelacionamento'])) ? $_POST['cdrelacionamento'] : '';
	$dtinicio         = (isset($_POST['dtinicio'])) ?         $_POST['dtinicio']         : '';
	$dttermino        = (isset($_POST['dttermino'])) ?        $_POST['dttermino']        : '';
	$nmempresa        = (isset($_POST['nmempresa'])) ?        $_POST['nmempresa']        : '';
	$nmemporg         = (isset($_POST['nmemporg'])) ?         $_POST['nmemporg']         : '';
	$nrcnpj_empresa   = (isset($_POST['nrcnpj_empresa'])) ?   $_POST['nrcnpj_empresa']   : '';
	$nmpolitico       = (isset($_POST['nmpolitico'])) ?       $_POST['nmpolitico']       : '';
	$nrcpf_politico   = (isset($_POST['nrcpf_politico'])) ?   $_POST['nrcpf_politico']   : '';	
												
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";	
	
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; break;				
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; break;
		case 'PPE': $procedure = 'valida_dados_ppe'; $cddopcao = 'A'; break;
		case 'PPE_ABA': $procedure = 'grava_dados_ppe'; $cddopcao = 'A'; break;
		default: return false;
	}
	
	$nmendter = session_id();
	
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0075.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<dtmvtolt>".$dtmvtolt."</dtmvtolt>";	
	$xml .= "       <tpexposto>".$tpexposto."</tpexposto>";
	$xml .= "       <cdocpttl>".$cdocpttl."</cdocpttl>";
	$xml .= "       <cdrelacionamento>".$cdrelacionamento."</cdrelacionamento>";
	$xml .= "       <dtinicio>"        .$dtinicio."</dtinicio>";
	$xml .= "       <dttermino>"       .$dttermino."</dttermino>";	
	
	if($tpexposto == '1'){

	$xml .= "       <nmempresa>"       .retiraAcentos(removeCaracteresInvalidos($nmempresa))."</nmempresa>";
		
	}else {

		$xml .= "       <nmempresa>"       .retiraAcentos(removeCaracteresInvalidos($nmemporg))."</nmempresa>";
		
	}	
	
	$xml .= "       <nrcnpj_empresa>"  .$nrcnpj_empresa."</nrcnpj_empresa>";
	$xml .= "       <nmpolitico>"      .retiraAcentos(removeCaracteresInvalidos($nmpolitico))."</nmpolitico>";
	$xml .= "       <nrcpf_politico>"  .$nrcpf_politico."</nrcpf_politico>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	$msgRvcad   = $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'];
	
	if ($msgRetorno!=='') $msg[] = $msgRetorno;
	if ($msgAlerta!=='' ) $msg[] = $msgAlerta;
	if ($msgRvcad!=='' )  $msg[] = $msgRvcad;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];

	function validaDados(){	
		
		echo '$("input,select","#frmDadosComercial").removeClass("campoErro");';	
		
		// Campo Nat. da Ocupação
		if ( ($GLOBALS['cdnatopc'] == '' ) || ($GLOBALS['cdnatopc'] == 0 ) ) exibirErro('error','Natureza da Ocupação inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdnatopc\',\'frmDadosComercial\')',false);
		
		//Campo Ocupação
		if ( ($GLOBALS['cdocpttl'] == '' ) || ($GLOBALS['cdocpttl'] == 0 ) ) exibirErro('error','Ocupação inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdocpttl\',\'frmDadosComercial\')',false);		
		
		//Campo Tp. Ctr. Trb.
		if ( $GLOBALS['tpcttrab'] == '' ) exibirErro('error','Tipo Ctr. Trb. inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'tpcttrab\',\'frmDadosComercial\')',false);		

	}
		
?>