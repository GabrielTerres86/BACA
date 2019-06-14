<?php 

	/************************************************************************
	 Fonte: liberar.php
	 Autor: Guilherme
	 Data : Marco/2008                 Última Alteração: 08/07/2011

	 Objetivo  : Mostrar opção Liberar da rotina de Cartões de Crédito da tela 
	             ATENDA

	 Alterações: 17/11/2010 - Adaptação Cartão PJ (David).
	 
				 08/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
   			
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["cdadmcrd"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$cdadmcrd = $_POST["cdadmcrd"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o código da administradora é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("C&oacute;digo da administradora inv&aacute;lido.");
	}	
		
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>verifica_cartao_bb</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";
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
			<legend style="margin-bottom: 5px"><? echo utf8ToHtml('Liberação:') ?></legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/liberar.gif" onClick="liberacaoCartao(1);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer a libera&ccedil;&atilde;o do cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','desfazLiberacaoCartao()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
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

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
