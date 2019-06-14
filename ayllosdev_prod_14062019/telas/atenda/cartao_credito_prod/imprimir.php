<?php 

	/************************************************************************
	 Fonte: imprimir.php
	 Autor: Guilherme
	 Data : Marco/2008                        Última Alteração: 26/08/2015

	 Objetivo  : Mostrar opção Imprimir da rotina de Cartões de Crédito da 
	             tela ATENDA

	 Alterações: 28/10/2010 - Adaptações para PJ (David).
	 
				 08/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
				 
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cdadmcrd"]) || !isset($_POST["inpessoa"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$cdadmcrd = $_POST["cdadmcrd"];
	$inpessoa = $_POST["inpessoa"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("Administradora inv&aacute;lida.");
	}
	
	// Verifica se o tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lida.");
	}
	
	if ($cdadmcrd == 1) { /* Credicard */
		$idimpres = 5; 
	} elseif ($cdadmcrd == 2) { /* BRADESCO/VISA */
		$idimpres = 2; 
	} elseif ($cdadmcrd == 3) { /* CECRED/VISA */ 
		$idimpres = 2; 
	} elseif ($cdadmcrd >= 83 && $cdadmcrd <= 88) { /* MULTIPLO BB */
		$idimpres = 7; 
	} else {
		$idimpres = $inpessoa == 1 ? 0 : 2;
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
			<legend><? echo utf8ToHtml('Impressão') ?></legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/proposta.gif" onClick="gerarImpressao(1,3,0,0,0);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/contrato.gif" onClick="gerarImpressao(1,<?php echo $idimpres .",". $cdadmcrd; ?>,0,0);return false;" />
			<?php if ($inpessoa == "2") { ?>
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/emissao.gif" onClick="gerarImpressao(1,10,0,0,0);return false;" />
			<?php } ?>
			
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
