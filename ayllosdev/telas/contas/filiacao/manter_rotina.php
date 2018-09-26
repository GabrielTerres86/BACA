<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 05/04/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados do FILIAÇÃO da tela de CONTAS
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;		
	$nmmaettl = (isset($_POST['nmmaettl'])) ? $_POST['nmmaettl'] : '' ;
	$nmpaittl = (isset($_POST['nmpaittl'])) ? $_POST['nmpaittl'] : '' ;
	
	if(in_array($operacao,array('AV','VA'))) validaDados();
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; break;
		case 'VA': $procedure = 'grava_dados'; break;
		default: return false;
	}	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0054.p</Bo>";
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
	$xml .= "		<nmmaettl>".retiraAcentos(removeCaracteresInvalidos($nmmaettl))."</nmmaettl>";
	$xml .= "		<nmpaittl>".retiraAcentos(removeCaracteresInvalidos($nmpaittl))."</nmpaittl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];
	
	
	
	// Se é Validação
	if( $operacao == 'AV' ) {
		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacaoFiliacao(\'VA\');','bloqueiaFundo(divRotina)',false);		
	// Se é Inclusão ou Alteração
	} else {
	
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {
			if($operacao=='VA') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0054.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoFiliacao(\"FA\")\');',false);			
						
		// Se não existe necessidade de Revisão Cadastral
		} else {	
		
			// Chama o controla Operação Finalizando a Inclusão ou Alteração
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoFiliacao(\"FA\")\');';			
			
		}
	}
	
	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmDadosFiliacao").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

		// Valida nome da mãe - Obrigatório
		if ($GLOBALS['nmmaettl'] == '') exibirErro('error','O nome da M&atilde;e &eacute; de preenchimento obrigat&oacute;rio.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmmaettl\',\'frmDadosFiliacao\')',false);
	}		
?>