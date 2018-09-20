<?php 

	//************************************************************************//
	//*** Fonte: 2via_solicitacao_carregadados.php                         ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Mar&ccedil;o/2008            Última Alteração: 26/08/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar os dados para efetuar a solicitação de      ***//
	//***             segunda via de Cartões de Crédito                    ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/09/2008 - Adaptação para solicitação de 2 via de  ***//
	//***                          senha de cartão de crédito (David)      ***//
	//***                                                                  ***//
    //***             08/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***																   ***//
	//***             06/07/2011 - Alterado para layout padrão             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
	//***																   ***//
    //***			  10/07/2012 - Alterado label do campo para 'Nome no   ***//
	//***   					   Plástico do Cartão' (Guilherme Maba).   ***//
	//***																   ***//
	//***	     	 26/08/2015 - Remover o form da impressao. (James) 	   ***//	
	//***																   ***//
	//************************************************************************//		
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["inpessoa"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}

	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>carrega_dados_solicitacao2via_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$dados = $xmlObjCartao->roottag->tags[0]->tags;
	
	if ($inpessoa == "2") {
		// Monta o xml de requisição
		$xmlGetRepresen  = "";
		$xmlGetRepresen .= "<Root>";
		$xmlGetRepresen .= "	<Cabecalho>";
		$xmlGetRepresen .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlGetRepresen .= "		<Proc>carrega_representante</Proc>";
		$xmlGetRepresen .= "	</Cabecalho>";
		$xmlGetRepresen .= "	<Dados>";
		$xmlGetRepresen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
		$xmlGetRepresen .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetRepresen .= "		<nrdconta>".$nrdconta."</nrdconta>";		
		$xmlGetRepresen .= "	</Dados>";
		$xmlGetRepresen .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetRepresen);

		// Cria objeto para classe de tratamento de XML
		$xmlObjRepresen = getObjectXML($xmlResult);
		
		$repsolic = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["REPRESEN"]);
		$cpfrepre = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["CPFREPRE"]);
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">
	function voltar(){
		$("#divMotivoSolicitacao").css("display","block");
		$("#divNovoNome").css("display","none");
	}
</script>
<form action="" class="formulario" name="frmSolicitacao" id="frmSolicitacao">
	<div id="divMotivoSolicitacao">
	
		<fieldset>
			<legend><? echo utf8ToHtml('Solicitar Segunda Via de Cartão:') ?></legend>
	
			<?php if ($inpessoa == "2") { ?>
					<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
					<select name="repsolic" id="repsolic">
						<?php for ($i = 0; $i < count($repsolic); $i++) { ?>
						<option value="<?php echo $cpfrepre[$i]; ?>"<?php if ($i == 0) echo " selected"; ?>><?php echo $repsolic[$i]; ?></option>
						<?php } ?>
					</select>
			<?php } ?>
			
			<label for="slmotivo"><? echo utf8ToHtml('Motivo:') ?></label>
			<select name="slmotivo" id="slmotivo" onchange="alteraMotivo()">
			<?php for ($i = 0; $i < count($dados); $i++) { ?>
				<option value="<?php echo $dados[$i]->tags[1]->cdata; ?>"><?php echo $dados[$i]->tags[0]->cdata; ?></option>
			<?php } ?>
			</select>
				
		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,2,4);return false;" />
			<input type="image" name="linkTela" id="linkTela" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" />
		</div>		
	</div>
	<div id="divNovoNome">
		<fieldset>
			<legend><? echo utf8ToHtml('Solicitar Segunda Via de Cartão:') ?></legend>
			
			<label for="nmtitcrd"><? echo utf8ToHtml('Nome no Plástico do Cartão:') ?></label>
			<input id="nmtitcrd" name="nmtitcrd" type="text" />
			
		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltar();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="showConfirmacao('Deseja efetuar a solicita&ccedil;&atilde;o de segunda via do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','efetuaSolicitacao2viaCartao(5)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
		</div>
			
	</div>
</form>

<script type="text/javascript">
//Mostra o div com o motivo da solicitação e esconde o div do novo nome
$("#divMotivoSolicitacao").css("display","block");
$("#divNovoNome").css("display","none");

// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao3").css("display","block");
// Esconde os cartões
$("#divOpcoesDaOpcao2").css("display","none");

controlaLayout('frmSolicitacao');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>