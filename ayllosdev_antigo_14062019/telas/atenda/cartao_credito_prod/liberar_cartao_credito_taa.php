<?
/*!
 * FONTE        : liberar_cartao_credito_taa.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Julho/2015
 * OBJETIVO     : Liberar o cartao de credito para o TAA
 * --------------
 * ALTERA��ES   :
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta = $_POST["nrdconta"]; // N�mero da conta
	$nrctrcrd = $_POST["nrctrcrd"]; // N�mero da proposta	
	$nrcrcard = $_POST["nrcrcard"]; // N�mero do cartao de credito	
	$dssentaa = $_POST["dssentaa"]; // Senha
	$dssencfm = $_POST["dssencfm"]; // Confirmacao de senha		
	$operacao = $_POST['operacao'];
	$opcao    = 'O';
	
	// Quando a tela for acessada pela tela "ENTREGA", sera verificado o privilegio da entrega
	if ($operacao == 'entregarCartao'){
	   $opcao = 'F';
	}   
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>liberar_cartao_credito_taa</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dssentaa>".$dssentaa."</dssentaa>";
	$xmlSetCartao .= "		<dssencfm>".$dssencfm."</dssencfm>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}
	
	$oDados   = $xmlObjCartao->roottag->tags[0];
	$flgcadas = $oDados->attributes["FLGCADAS"];	
	
	// Operacao da tela de Liberacao de acesso ao TAA
	if ($operacao == 'liberarAcessoTaa'){
		
		// Verifica se jah possui senha das letras cadastradas
		if ($flgcadas == 'yes'){
			echo "showError('inform','Cart�o liberado com sucesso.','Alerta - Aimaro','opcaoTAA()');";
		}else{
			echo "showError('inform','Cart�o liberado com sucesso! Favor cadastrar as letras de seguran�a.','Alerta - Aimaro','validaDadosSenhaLetrasTAA(\'".$operacao."\')');";
		}	
		
	// Operacao da tela de entrega de cartao de credito 
	}else if ($operacao == 'entregarCartao'){
		
		// Verifica se jah possui senha das letras cadastradas
		if ($flgcadas == 'yes'){
			echo "abreTelaLimiteSaque();";
		}else{
			echo "entregaCartaoCarregaTelaSenhaLetrasTaa();";
		}		
	}	
?>