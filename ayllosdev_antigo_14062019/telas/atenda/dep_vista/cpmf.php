<?php 

	 /************************************************************************
	      Fonte: cpmf.php
	      Autor: Guilherme
	      Data : Fevereiro/2008                 &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

	      Objetivo  : Mostrar opcao CPMF da rotina de Dep. Vista
                      da tela ATENDA

	      Altera&ccedil;&otilde;es:
				    29/06/2011 - Alterado para layout padrão (Rogerius - DB1).
		  
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetCPMF  = "";
	$xmlGetCPMF .= "<Root>";
	$xmlGetCPMF .= "	<Cabecalho>";
	$xmlGetCPMF .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlGetCPMF .= "		<Proc>obtem-cpmf</Proc>";
	$xmlGetCPMF .= "	</Cabecalho>";
	$xmlGetCPMF .= "	<Dados>";
	$xmlGetCPMF .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCPMF .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCPMF .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCPMF .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCPMF .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCPMF .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetCPMF .= "		<idseqttl>1</idseqttl>";
	$xmlGetCPMF .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCPMF .= "	</Dados>";
	$xmlGetCPMF .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCPMF);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetCPMF = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlGetCPMF->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetCPMF->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$cpmf = $xmlGetCPMF->roottag->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<form action="" method="" name="frmCPMF" id="frmCPMF" class="formulario">

	<br /><br /><br /><br />

	<label for="execicio">
	Exerc&iacute;cio: <?php echo $cpmf[0]->tags[0]->tags[0]->cdata ?>
	&nbsp;
	Exerc&iacute;cio: <?php echo $cpmf[0]->tags[1]->tags[0]->cdata ?>
	</label> 

	<br />

	<label for="base1">Base de C&aacute;lculo:</label>
	<input id="base1" type="text" value="<?php echo number_format(str_replace(",",".",$cpmf[0]->tags[0]->tags[1]->cdata),2,",","."); ?>" />

	<label for="base2"></label>
	<input id="base2" type="text" value="<?php echo number_format(str_replace(",",".",$cpmf[0]->tags[0]->tags[2]->cdata),2,",","."); ?>" />

	<br />

	<label for="valor1">Valor Pago:</label>
	<input id="valor1" type="text" value="<?php echo number_format(str_replace(",",".",$cpmf[0]->tags[1]->tags[1]->cdata),2,",","."); ?>" />
	<label for="valor2"></label>
	<input id="valor2" type="text" value="<?php echo number_format(str_replace(",",".",$cpmf[0]->tags[1]->tags[2]->cdata),2,",","."); ?>" />

</form>


<script type="text/javascript">

//
controlaLayout('frmCPMF');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
