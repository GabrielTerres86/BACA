<?php 

	/************************************************************************
	 Fonte: cheques_limite_confirmar_novo_limite.php	 
	 Autor: Lombardi
	 Data : Setembro/2016                         �ltima Altera��o: 07/03/2018
	
	 Objetivo  : Excluir um limite de desconto de cheques
	
	 Altera��es: 07/03/2018 - Adicionado valida��o da cobertura de bloqueio da
							  garantia do contrato de limite. (PRJ404 Reinert)
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�odo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"]) || !isset($_POST["vllimite"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$vllimite = $_POST["vllimite"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	
	  
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;
	$cddopera = (isset($_POST['cddopera'])) ? $_POST['cddopera'] : 0;
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : 0;
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <nmdatela>ATENDA</nmdatela>';
	$xml .= '       <idcobert>'.$idcobope.'</idcobert>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "BLOQ0001", "REVALIDA_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {		
		echo "showConfirmacao('Garantia de aplica&ccedil;&atilde;o resgatada/bloqueada. Deseja alterar o limite proposto?', 'Confirma&ccedil;&atilde;o - Ayllos', 'mostraTelaAltera();', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'))', 'sim.gif', 'nao.gif');";
		exit();
	}
	
    $xmlRenovaLimite  = "";
	$xmlRenovaLimite .= "<Root>";
	$xmlRenovaLimite .= "   <Dados>";
	$xmlRenovaLimite .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRenovaLimite .= "	   <nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlRenovaLimite .= "	   <vllimite>".$vllimite."</vllimite>";
	$xmlRenovaLimite .= "	   <cddopera>".$cddopera."</cddopera>";
	$xmlRenovaLimite .= "   </Dados>";
	$xmlRenovaLimite .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlRenovaLimite, "TELA_ATENDA_DESCTO", "CONFIRMA_NOVO_LIMITE", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjRenovaLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRenovaLimite->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->cdata;
		}
		exibeErro(htmlentities($msgErro));
	}
	
	if (strtoupper($xmlObjRenovaLimite->roottag->tags[0]->name) == "MSG") {
		
		$mensagem_01 = $xmlObjRenovaLimite->roottag->tags[0]->tags[0]->cdata;
		$mensagem_02 = $xmlObjRenovaLimite->roottag->tags[0]->tags[1]->cdata;
		$mensagem_03 = $xmlObjRenovaLimite->roottag->tags[0]->tags[2]->cdata;
		$mensagem_04 = $xmlObjRenovaLimite->roottag->tags[0]->tags[3]->cdata;
		$qtctarel    = '';
		
		if ($mensagem_03 != '') {
			$tab_grupo   = $xmlObjRenovaLimite->roottag->tags[0]->tags[4]->tags;
			$qtctarel    = $xmlObjRenovaLimite->roottag->tags[0]->tags[5]->cdata;
		}
		
		$grupo = '';
		if ($mensagem_03 != '') {
			foreach( $tab_grupo as $reg ) { 
				$grupo .= ($reg->cdata).";";
			}
			if ($grupo != '')
				$grupo = substr($grupo,0,-1);
		}
		echo 'verificaMensagens("'.$mensagem_01.'","'.$mensagem_02.'","'.$mensagem_03.'","'.$mensagem_04.'","'.$qtctarel.'","'.$grupo.'");';
	}
	else
	{
		if ($xmlObjRenovaLimite->roottag->tags[0]->cdata == 'OK') {
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaLimitesCheques();");';
		}
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>