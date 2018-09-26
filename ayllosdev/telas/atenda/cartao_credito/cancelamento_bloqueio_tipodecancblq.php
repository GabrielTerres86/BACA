<?php 

	/************************************************************************
	  Fonte: cancelamento_bloqueio_tipodecancblq.php
	  Autor: Guilherme
	  Data : Marco/2008                 Última Alteração: 26/08/2015

	  Objetivo  : Mostrar rotina de cancelamento/bloqueio de cartao de 
		          credito.

	  Alterações: 24/05/2010 - Incluida opção "Por Fraude" para motivo de 
		                       cancelamento (Elton).

			      08/11/2010 - Adaptação para cartão PJ (David).
				  
			      07/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
				  
				  26/08/2015 - Remover o form da impressao. (James)
				  				  
		          17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
				  				  
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrcrcard"]) ||
		!isset($_POST["nrctrcrd"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["cancbloq"]) ||
		!isset($_POST["inpessoa"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrcrcard = $_POST["nrcrcard"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrdconta = $_POST["nrdconta"];
	$cancbloq = $_POST["cancbloq"];
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
	$xmlSetCartao .= "		<Proc>verifica_canc_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
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
<form action="" name="frmCanBlqCartao" id="frmCanBlqCartao">
	<fieldset>
		<legend><?php if ($cancbloq == "1") { echo "Motivo do Cancelamento"; } else { echo "Motivo do Bloqeuio"; } ?></legend>
					
			<?php if ($inpessoa == "2") { ?>
				<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
				<select name="repsolic" id="repsolic">
					<?php for ($i = 0; $i < count($repsolic); $i++) { ?>
					<option value="<?php echo $cpfrepre[$i]; ?>"<?php if ($i == 0) echo " selected"; ?>><?php echo $repsolic[$i]; ?></option>
					<?php } ?>
				</select>
				<br />
			<?php } ?>
			
			<label for="nrcrcard"><? echo utf8ToHtml('Cartão:') ?></label>
			<input type="text" name="nrcrcard" id="nrcrcard" value="<?php echo $nrcrcard ?>" />
			<br />
			
			<label for="tpcanblq"><? echo utf8ToHtml('Motivo:') ?></label>
			<select name="tpcanblq" id="tpcanblq">
				<option value="1">Pelo S&oacute;cio</option>
				<option value="2">Pela Cooperativa</option>
				<option value="3">Por Fraude</option> 
			</select>
			
	</fieldset>
</form>
<div class="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4);return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/<?php if ($cancbloq == "1"){ echo "cancelar"; } else { echo "bloquear"; } ?>.gif" onClick="showConfirmacao('Deseja' + <?php if ($cancbloq == "1"){ echo "' cancelar '"; } else { echo "' bloquear '"; } ?> + 'o cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','cancelarBloquearCartao(<?php if ($cancbloq == "1"){ echo "1"; } else { echo "2"; } ?>)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
</div>


<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao2").css("display","block");
// Esconde os cartões e avalistas
$("#divOpcoesDaOpcao1").css("display","none");

controlaLayout('frmCanBlqCartao');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>