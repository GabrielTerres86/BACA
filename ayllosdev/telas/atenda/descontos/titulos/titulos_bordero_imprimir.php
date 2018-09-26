<?php 

	/************************************************************************
	 Fonte: titulos_bordero_imprimir.php
	 Autor: Guilherme
	 Data : November/2008                 Última Alteração: 12/09/2016

	 Objetivo  : Mostrar opção Imprimir da rotina de Descontos de títulos
				 subrotina borderôs

	 Alterações: 22/09/2010 - Ajuste para enviar impressoes via email para 
				              o PAC Sede (David).
							  
							  
			     12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)

				 12/09/2016 - Removido o botao Completa. (Jaison/Daniel)
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		exibeErro($msgError);		
	}			
	
	/*Verifica se o borderô deve ser utilizado no sistema novo ou no antigo*/
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","VIRADA_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$flgverbor = $root->dados->flgverbor->cdata;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<?if($flgverbor){?>
	<div id="divBotoes" style="width: 500px;">
		<form class="formulario">
			<fieldset>
				<legend><? echo utf8ToHtml('Impressão') ?></legend>
				<input type="button" class="botao" value="Voltar"  onClick="carregaBorderosTitulos();return false;" />
				<input type="button" class="botao" value="T&iacute;tulos"  onClick="gerarImpressao(7,2,'no');return false;" />
				<input type="button" class="botao" value="Proposta"  onClick="gerarImpressao(6,2,'no');return false;" />
			</fieldset>
		</form>
	</div>
<?}
else{?>
<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend><? echo utf8ToHtml('Impressão') ?></legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="carregaBorderosTitulos();return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/titulos.gif" onClick="gerarImpressao(7,2,'no');return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/proposta.gif" onClick="gerarImpressao(6,2,'no');return false;" />
			
		</fieldset>
	</form>
</div>

<? }

//Form com os dados para fazer a chamada da geração de PDF	
include("impressao_form.php"); 
?>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
