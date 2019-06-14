<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 20/04/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de Ativo/Passivo da tela de CONTAS
 *
 * ALTERACOES   : [05/08/2015] Gabriel (RKAM) : Reformulacao cadastral.
 *
 *                [01/12/2016] Renato (Supero): P341-Automatização BACENJUD - Retirado o envio do
 *                                              parametro do departamento ao invés pois não é 
 *                                              utilizado na BO 
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
	$mesdbase = (isset($_POST['mesdbase'])) ? $_POST['mesdbase'] : '';
	$anodbase = (isset($_POST['anodbase'])) ? $_POST['anodbase'] : '';
	$vlcxbcaf = (isset($_POST['vlcxbcaf'])) ? $_POST['vlcxbcaf'] : '';
	$vlctarcb = (isset($_POST['vlctarcb'])) ? $_POST['vlctarcb'] : '';
	$vlrestoq = (isset($_POST['vlrestoq'])) ? $_POST['vlrestoq'] : '';
	$vloutatv = (isset($_POST['vloutatv'])) ? $_POST['vloutatv'] : '';
	$vlrimobi = (isset($_POST['vlrimobi'])) ? $_POST['vlrimobi'] : '';
	$vlfornec = (isset($_POST['vlfornec'])) ? $_POST['vlfornec'] : '';
	$vloutpas = (isset($_POST['vloutpas'])) ? $_POST['vloutpas'] : '';
	$vldivbco = (isset($_POST['vldivbco'])) ? $_POST['vldivbco'] : '';
	$cdopejfn = (isset($_POST['cdopejfn'])) ? $_POST['cdopejfn'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	
	// exibirErro('error','ano= '.$data,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
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
	$xml .= "		<Bo>b1wgen0066.p</Bo>";
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
	$xml .= "		<mesdbase>".$mesdbase."</mesdbase>";
	$xml .= "		<anodbase>".$anodbase."</anodbase>";	
	$xml .= "		<vlcxbcaf>".$vlcxbcaf."</vlcxbcaf>";
	$xml .= "		<vlctarcb>".$vlctarcb."</vlctarcb>";
	$xml .= "		<vlrestoq>".$vlrestoq."</vlrestoq>";
	$xml .= "		<vloutatv>".$vloutatv."</vloutatv>";
	$xml .= "		<vlrimobi>".$vlrimobi."</vlrimobi>";
	$xml .= "		<vlfornec>".$vlfornec."</vlfornec>";
	$xml .= "		<vloutpas>".$vloutpas."</vloutpas>";
	$xml .= "		<vldivbco>".$vldivbco."</vldivbco>";
	$xml .= "		<cdopejfn>".$cdopejfn."</cdopejfn>";
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

	// Se é Validação
	if( $operacao == 'AV' ) {
		
		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);
		
	// Se é Inclusão ou Alteração
	} else {
		
		if($msgAtCad != '' && $flgcadas != 'M') {
					
			if($operacao=='VA') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0066.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
			
			// Chama o controla Operação Finalizando a Alteração
			if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
				
		}
	}
	
	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmAtivoPassivo").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

		// Campos Data basa
		if (!validaInteiro($GLOBALS['mesdbase']) || $GLOBALS['mesdbase'] < 1 || $GLOBALS['mesdbase'] > 12 ) exibirErro('error','Valor deve ser mês v&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'mesdbase\',\'frmAtivoPassivo\')',false);
        if (!validaInteiro($GLOBALS['anodbase']) || $GLOBALS['anodbase'] < 1970 || $GLOBALS['anodbase'] > date("Y")  ) exibirErro('error','Valor deve ser um ano v&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'anodbase\',\'frmAtivoPassivo\')',false);
	}	
?>									 