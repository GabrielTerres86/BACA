<?php 

	/************************************************************************
	 Fonte: titulos_limite_cancelar.php                               
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                �ltima Altera��o: 09/06/2010 
	                                                                  
	 Objetivo  : Cancelar um limite de desconto de t�tulos            
	                                                                  	 
	 Altera��es: 09/06/2010 - Adapta��o para RATING (David).
		         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
                 12/02/2019 - Altera��o para verificar se existem border�s que ainda n�o foram liberados, antes do cancelamento do contrato (C�ssia de Oliveira - GFT)

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$confirma = $_POST["confirma"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
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

	    // Se ocorrer um erro, mostra cr�tica
		if ($root->erro){

			exibeErro(htmlentities($root->erro->registro->dscritic));
			
			exit;

		} else if ($root->dados->fltembdt == '1') {

			echo 'showConfirmacao("Este contrato tem border&ocirc;s que ainda n&atilde;o foram liberados. Deseja continuar?","Confirma&ccedil;&atilde;o - Aimaro","cancelaLimiteDscTit(1);","hideMsgAguardo();","sim.gif","nao.gif");';
			exit;

		} 
	}
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjExcluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExcluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'idLinhaL = 0;';
	echo 'hideMsgAguardo();';
	echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - 	Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); fecharRotinaGenerico(\'CONTRATO\');");';	

	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
