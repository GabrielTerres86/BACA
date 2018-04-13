<?php 

	//************************************************************************//
	//*** Fonte: obtem_dados_habilitacao.php                               ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2008                   Última Alteração: 01/05/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Habilitação da rotina de Internet da   ***//
	//****						tela ATENDA     						   ***//
	//***                                                                  ***//	 
	//*** Alterações: 03/09/2009 - Melhorias na rotina de Internet (David) ***//
	//***			  10/01/2011 - Retirar a parte de cobranca. (Gabriel)  ***//
	//***                                                                  ***//	 
	//***             13/07/2011 - Alterado para layout padrão             ***//	 
	//***             			   (Gabriel Capoia - DB1)                  ***//	 
	//***                                                                  ***//	 
	//***             01/05/2012 - Projeto TED Internet (Lucas).           ***//
	//***                                                                  ***//	 
    //***             05/09/2017 - Alteração referente ao Projeto          ***//
	//***                          Assinatura conjunta (Proj 397)          ***//
	//***                                                                  ***//	 
    //***             06/04/2018 - Adicionada chamada para a function      ***//
	//***                          validaAdesaoProduto. PRJ366 (Lombardi). ***//
	//***                                                                  ***//	 
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
    $idastcjt = $_POST["idastcjt"];
	


	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
		
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>

<div id="divHabilitacao">
<form action="" method="post" name="frmOpHabilitacao" id="frmOpHabilitacao" onSubmit="return false;">
		<fieldset>
			<legend><? echo utf8ToHtml('Habilitação') ?></legend>
			<div id="divBotoes">
				<a class="botao" href="#" style='padding:2px 5px;' onClick="validaAdesaoProduto(<?php echo $nrdconta ?>, 14, 'obtemDadosLimites();');return false;">Cadastramento de Limite</a>
				<a class="botao" href="#" style='padding:2px 5px;' onClick="carregaContas();return false;">Cadastramento de Contas</a>
				<?php if($idastcjt == 1){?>
				<a class="botao" href="#" style='padding:2px 5px;' onClick="obtemDadosLimitesprep();return false;">Limites de Preposto</a>
				<?php }?>
				<br />
				<a class="botao" href="#" style='margin:10px; padding:2px 5px;' onClick = "acessaOpcaoAba('<? echo count($glbvars["opcoesTela"])?>','<? echo $idPrincipal ?>','<? echo $glbvars["opcoesTela"][$idPrincipal]?>');">Voltar</a>
			</div>
		</fieldset>
	</form>
</div>

<script type="text/javascript">
controlaLayout('frmOpHabilitacao');

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","85");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>