<?php 

	/************************************************************************
	 Fonte: titulos_limite_cancelar.php                               
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 09/06/2010 
	                                                                  
	 Objetivo  : Cancelar um limite de desconto de títulos            
	                                                                  	 
	 Alterações: 09/06/2010 - Adaptação para RATING (David).
		         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
                 12/02/2019 - Alteração para verificar se existem borderôs que ainda não foram liberados, antes do cancelamento do contrato (Cássia de Oliveira - GFT)

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$confirma = $_POST["confirma"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	if($confirma == 0){

		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";	
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		

		$xmlResult = mensageria($xml, 'TELA_ATENDA_DESCTO', 'VERIFICA_BORDERO_CONTRATO',  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		
		$xmlObj = getClassXML($xmlResult);

	    $root = $xmlObj->roottag;

	    // Se ocorrer um erro, mostra crítica
		if ($root->erro){

			exibeErro(htmlentities($root->erro->registro->dscritic));
			
			exit;

		} else if ($root->dados->fltembdt == '1') {

			echo 'showConfirmacao("Este contrato tem border&ocirc;s que ainda n&atilde;o foram liberados. Deseja continuar?","Confirma&ccedil;&atilde;o - Aimaro","cancelaLimiteDscTit(1);","hideMsgAguardo();","sim.gif","nao.gif");';
			exit;

		} 
	}
	
	// Monta o xml de requisição
	$xmlExcluir  = "";
	$xmlExcluir .= "<Root>";
	$xmlExcluir .= "	<Cabecalho>";
	$xmlExcluir .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlExcluir .= "		<Proc>efetua_cancelamento_limite</Proc>";
	$xmlExcluir .= "	</Cabecalho>";
	$xmlExcluir .= "	<Dados>";
	$xmlExcluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluir .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlExcluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlExcluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlExcluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluir .= "		<idseqttl>1</idseqttl>";
	$xmlExcluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlExcluir .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlExcluir .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlExcluir .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlExcluir .= "	</Dados>";
	$xmlExcluir .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExcluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExcluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExcluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'idLinhaL = 0;';
	echo 'hideMsgAguardo();';
	echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - 	Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); fecharRotinaGenerico(\'CONTRATO\');");';	

	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
