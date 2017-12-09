<?php 

	/****************************************************************
	 Fonte: principal.php                                            
	 Autor: Jonta - RKAM                                                    
	 Data : Dezembro/2017                 Última Alteração:  
	                                                                 
	 Objetivo  : Mostrar opcao Principal da rotina de Valores a Devolver da tela ATENDA                                   
	                                                                 
	 Alter.:  
																   	 
	*****************************************************************/
	
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
	
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0004", "VALORESADEVOLVER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);fechaRotina(divRotina);');
	}
				
	$cotas = $xmlObj->roottag->tags[0]->tags;
	$deposito = $xmlObj->roottag->tags[1]->tags;
	
	
?>
<form name="frmValoresDevolver" id="frmValoresDevolver" class="formulario">

	<label for="vlcapital">Capital:</label>
	<input name="vlcapital" id="vlcapital" type="text" value="<?php echo number_format(str_replace(",",".",$cotas[0]->cdata),2,",","."); ?>" />
	
	<br style="clear:both" />
	
	<label for="vldeposito"><? echo utf8ToHtml('Depósito à Vista:') ?></label>
	<input name="vldeposito" id="vldeposito" type="text" value="<?php echo number_format(str_replace(",",".",$deposito[0]->cdata),2,",","."); ?>" />
		
	<br style="clear:both" />
		
	<label for="dscapital"><? echo $cotas[1]->cdata ?></label>
	
	<br style="clear:both" />
	
	<label for="dscdeposito"><? echo $deposito[1]->cdata ?></label>
	
	<br style="clear:both" />
	
</form>

<script type="text/javascript">
// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","150px");

controlaLayout();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>