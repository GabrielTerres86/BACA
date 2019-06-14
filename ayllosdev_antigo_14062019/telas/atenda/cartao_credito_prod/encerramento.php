<?php 
	
	/************************************************************************
	 Fonte: encerramento.php
	 Autor: Jorge
	 Data : Marco/2011                           Última Alteração: 08/07/2011

	 Objetivo  : Mostrar opção Encerramento da rotina de Cartões de Crédito da 
			     tela ATENDA

	 Alterações: 08/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
	             09/04/2015 - #272659 Adicionada validacao de acesso da opcao (Carlos)
	 	 	 
	*************************************************************************/

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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"Z")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o código do contrato do cartão é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("C&oacute;digo do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>verifica_acesso_enc</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
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
	
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$flgadmbb = $xmlObjCartao->roottag->tags[0]->attributes["FLGADMBB"];
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	if($flgadmbb == "yes"){
		$indposic = 1; 
	}else{ 
		$indposic = 2;
		exibeErro("Op&ccedil;&atilde;o v&aacute;lida somente para CART&Otilde;ES VISA BB");
	}
?>
<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend>Encerramento</legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/encerrar.gif" onClick="encerrarCart('<?php echo $indposic; ?>');return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer o encerramento do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','desfazEncCartao(\'<?php echo $indposic; ?>\')','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
		</fieldset>
	</form>
</div>
<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cartões
$("#divConteudoCartoes").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>