<?php 

	/************************************************************************
	  Fonte: alterar_dtvenc_carregadados.php
	  Autor: Guilherme
	  Data : Abril/2008                 Última Alteração: 26/08/2015

	  Objetivo  : Carregar os dados para efetuar a troca da data de vencimento 
	              do débito Cartões de Crédito
	              
	  Alterações: 05/11/2010 - Adaptação Cartão PJ (David).		

				  06/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
				  
				  26/08/2015 - Remover o form da impressao. (James)
	************************************************************************/
	
	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
        !isset($_POST["nrctrcrd"]) ||
		!isset($_POST["inpessoa"]) ||
		!isset($_POST["nrcrcard"]) ||
		!isset($_POST["cdadmcrd"]) ||
		!isset($_POST["segundaV"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];
	$nrcrcard = $_POST["nrcrcard"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$segundaV = $_POST["segundaV"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o código do contrato do cartão é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}

	// Verifica se o código da administradora é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("C&oacute;digo da administradora inv&aacute;lido.");
	}		
	
	// Monta o xml de requisição
	$xmlSetDtVenc  = "";
	$xmlSetDtVenc .= "<Root>";
	$xmlSetDtVenc .= "	<Cabecalho>";
	$xmlSetDtVenc .= "		<Bo>b1wgen0028.p</Bo>";
	
	if ($segundaV == "true")
		$xmlSetDtVenc .= "		<Proc>carrega_dados_dtvencimento_cartao_2via</Proc>";
	else
		$xmlSetDtVenc .= "		<Proc>carrega_dados_dtvencimento_cartao</Proc>";
		
	$xmlSetDtVenc .= "	</Cabecalho>";
	$xmlSetDtVenc .= "	<Dados>";
	$xmlSetDtVenc .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetDtVenc .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetDtVenc .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetDtVenc .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetDtVenc .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetDtVenc .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetDtVenc .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetDtVenc .= "		<idseqttl>1</idseqttl>";
	$xmlSetDtVenc .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetDtVenc .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetDtVenc .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";	
	$xmlSetDtVenc .= "	</Dados>";
	$xmlSetDtVenc .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetDtVenc);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDtVenc = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDtVenc->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDtVenc->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
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
	
	// Dias de débito disponíveis da admnistradora
	$diasdebadm = $xmlObjDtVenc->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$eADMDIAS   = explode(";",$diasdebadm);
	
	// Cada dia se torna um registro no array
	$eDDDEBITO = explode(",",$eADMDIAS[1]);
	
	// Dia do débito atual
	$dddebito = $xmlObjDtVenc->roottag->tags[0]->tags[0]->tags[1]->cdata;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<form action="" class="formulario" name="frmDtVencimento" id="frmDtVencimento">

	<fieldset>
		<legend><? echo utf8ToHtml('Representante Solicitante:') ?></legend>
					
		<label for="nrcrcard"><? echo utf8ToHtml('Cartão:') ?></label>
		<input type="text" name="nrcrcard" id="nrcrcard" value="<?php echo $nrcrcard ?>" />
		<br />
		
		<?php if ($inpessoa == "2") { ?>
			<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
			<select name="repsolic" id="repsolic">
				<?php for ($i = 0; $i < count($repsolic); $i++) { ?>
				<option value="<?php echo $cpfrepre[$i]; ?>"<?php if ($i == 0) echo " selected"; ?>><?php echo $repsolic[$i]; ?></option>
				<?php } ?>
			</select>
			<br />
		<?php } ?>
		
		<label for="dddebito"><? echo utf8ToHtml('Dia:') ?></label>
		<select name="dddebito" id="dddebito">
			<?php
			for ($i = 0; $i < count($eDDDEBITO); $i++){
				 ?><option value="<?php echo $eDDDEBITO[$i]; ?>"<?php if ($eDDDEBITO[$i] == $dddebito) { echo " selected"; } ?>><?php echo $eDDDEBITO[$i] ?></option><?php
			}
			?>
		</select>
		
	</fieldset>
	
	<div id="divBotoes" >
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="showConfirmacao('Deseja alterar a data de vencimento do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','alterarDataDeVencimento()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
	</div>

</form>

<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao2").css("display","block");
// Esconde os cartões
$("#divOpcoesDaOpcao1").css("display","none");

controlaLayout('frmDtVencimento');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>