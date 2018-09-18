<?php 

	/************************************************************************
	 Fonte: liberar_liberacao.php
	 Autor: Guilherme
	 Data : Abril/2008                 Últimas alterações: 11/04/2013

	 Objetivo  : Efetuar a libera&ccedil;&atilde;o da rotina de Cart&otilde;es de Cr&eacute;dito da tela 
			ATENDA

	      Alterações: 09/09/2011 - Incluido a chamada para a procedure
								   alerta_fraude (Adriano).
								   
					  11/04/2013 - Retirado a chamada da procedure alerta_fraude
								   (Adriano).
	  ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrcrd"]) ||
		!isset($_POST["inconfir"]) ||
		!isset($_POST["nrcpfcgc"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inconfir = $_POST["inconfir"];
	$nrcpfcgc = $_POST["nrcpfcgc"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n&uacute;mero do contrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se o indicador do tipo de cancelamento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetLiberacao  = "";
	$xmlSetLiberacao .= "<Root>";
	$xmlSetLiberacao .= "	<Cabecalho>";
	$xmlSetLiberacao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetLiberacao .= "		<Proc>libera_cartao</Proc>";
	$xmlSetLiberacao .= "	</Cabecalho>";
	$xmlSetLiberacao .= "	<Dados>";
	$xmlSetLiberacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLiberacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetLiberacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLiberacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLiberacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLiberacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLiberacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetLiberacao .= "		<idseqttl>1</idseqttl>";
	$xmlSetLiberacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLiberacao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetLiberacao .= "		<inconfir>".$inconfir."</inconfir>";	
	$xmlSetLiberacao .= "	</Dados>";
	$xmlSetLiberacao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLiberacao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLiberacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjLiberacao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$mensagem = $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$idconfir = $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	
	if ($mensagem == "") {
							
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo '</script>';
				
		// Procura ind&iacute;ce da op&ccedil;&atilde;o "@" - Principal
		$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
		// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado - Carrega o principal novamente.
		if (!($idPrincipal === false)) {
			echo '<script type="text/javascript">';
			echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
			echo '</script>';
		} else {
			echo '<script type="text/javascript">';
			echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
			echo '</script>';
		}
		exit();
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();

//Confirma se deseja mesmo efetuar a libera&ccedil;&atilde;o
showConfirmacao(' <?php echo $mensagem ?> ','Confirma&ccedil;&atilde;o - Aimaro','liberacaoCartao(<?php echo $idconfir?>)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');
</script>
