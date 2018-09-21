<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 20/04/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de Ativo/Passivo da tela de CONTAS
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
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
	$vlrctbru = (isset($_POST['vlrctbru'])) ? $_POST['vlrctbru'] : '' ;             
	$vlctdpad = (isset($_POST['vlctdpad'])) ? $_POST['vlctdpad'] : '' ;             
	$ddprzpag = (isset($_POST['ddprzpag'])) ? $_POST['ddprzpag'] : '' ;             
	$vldspfin = (isset($_POST['vldspfin'])) ? $_POST['vldspfin'] : '' ;             
	$ddprzrec = (isset($_POST['ddprzrec'])) ? $_POST['ddprzrec'] : '' ;
	$dtaltjfn = (isset($_POST['dtaltjfn'])) ? $_POST['dtaltjfn'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	

		
	if(in_array($operacao,array('AV'))) validaDados();
		
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
	$xml .= "		<Bo>b1wgen0068.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";	
	$xml .= "		<vlrctbru>".$vlrctbru."</vlrctbru>";
	$xml .= "		<vlctdpad>".$vlctdpad."</vlctdpad>";
	$xml .= "		<vldspfin>".$vldspfin."</vldspfin>";
	$xml .= "		<ddprzrec>".$ddprzrec."</ddprzrec>";
	$xml .= "		<ddprzpag>".$ddprzpag."</ddprzpag>";
	$xml .= "		<dtaltjfn>".$dtaltjfn."</dtaltjfn>";	
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
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
	// Se é Alteração
	} else {
		if($msgAtCad!='' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0068.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
		}	
	}
	
	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmDadosResultados").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

	
		// Campos Data basa
		if (!validaInteiro($GLOBALS['ddprzrec']) || $GLOBALS['ddprzrec'] > 999 ) exibirErro('error','Valor deve ser mês v&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'ddprzrec\',\'frmDadosResultados\')',false);
        if (!validaInteiro($GLOBALS['ddprzpag']) || $GLOBALS['ddprzpag'] > 999 ) exibirErro('error','Valor deve ser um ano v&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'ddprzpag\',\'frmDadosResultados\')',false);
	}	
?>									 