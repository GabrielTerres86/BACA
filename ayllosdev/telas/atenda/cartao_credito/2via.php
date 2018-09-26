<?php 

	//************************************************************************//
	//*** Fonte: 2via.php                                                  ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Março/2008                   Última Alteração: 05/07/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Segunda via da rotina de Cartões de    ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/09/2008 - Adaptação para solicitação de 2 via de  ***//
	//***                          senha de cartão de crédito (David)      ***//	
	//***                                                                  ***//	 
	//***             21/11/2008 - Não permitir solicitação de 2via quando ***//
	//***                          número do cartão estiver zerado (David) ***//	 
	//***                                                                  ***//	 
	//***             23/04/2009 - Acerto no acesso a opção 2via (David)   ***//	
	//***                                                                  ***//	 
	//***             05/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***                                                                  ***//	 
	//***             05/07/2011 - Alterado para layout padrão             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
	//***																   ***//
	//***             05/12/2012 - Incluido novo parametro dtmvtolt        ***//
	//***                          (David Kruger)                          ***//
	//***																   ***//
	//***			  24/04/2013 - Implementado 2 via de senha			   ***//
	//***						   (Jean Michel - Cecred).				   ***//
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"])) {
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
	$xmlSetCartao .= "		<Proc>verifica_acesso_2via</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
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

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend style="margin-bottom: 5px">Segunda Via</legend>
			
			<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;">
			<input type="image" id="btnsegse" src="<?php echo $UrlImagens; ?>botoes/2via_senha.gif" onClick="opcao2viaSenha();return false;">
			<input type="image" id="btnsegct" src="<?php echo $UrlImagens; ?>botoes/2via_cartao.gif" onClick="opcao2viaCartao();return false;">
		</fieldset>
	</form>
	
	<br />
	
</div>
<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cartões
$("#divConteudoCartoes").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que esta átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>