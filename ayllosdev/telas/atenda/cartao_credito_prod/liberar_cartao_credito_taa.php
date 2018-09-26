<?
/*!
 * FONTE        : liberar_cartao_credito_taa.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Liberar o cartao de credito para o TAA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta = $_POST["nrdconta"]; // Número da conta
	$nrctrcrd = $_POST["nrctrcrd"]; // Número da proposta	
	$nrcrcard = $_POST["nrcrcard"]; // Número do cartao de credito	
	$dssentaa = $_POST["dssentaa"]; // Senha
	$dssencfm = $_POST["dssencfm"]; // Confirmacao de senha		
	$operacao = $_POST['operacao'];
	$opcao    = 'O';
	
	// Quando a tela for acessada pela tela "ENTREGA", sera verificado o privilegio da entrega
	if ($operacao == 'entregarCartao'){
	   $opcao = 'F';
	}   
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}
	
	$oDados   = $xmlObjCartao->roottag->tags[0];
	$flgcadas = $oDados->attributes["FLGCADAS"];	
	
	// Operacao da tela de Liberacao de acesso ao TAA
	if ($operacao == 'liberarAcessoTaa'){
		
		// Verifica se jah possui senha das letras cadastradas
		if ($flgcadas == 'yes'){
			echo "showError('inform','Cartão liberado com sucesso.','Alerta - Aimaro','opcaoTAA()');";
		}else{
			echo "showError('inform','Cartão liberado com sucesso! Favor cadastrar as letras de segurança.','Alerta - Aimaro','validaDadosSenhaLetrasTAA(\'".$operacao."\')');";
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