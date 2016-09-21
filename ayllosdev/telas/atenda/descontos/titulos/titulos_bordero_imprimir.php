<?php 

	/************************************************************************
	 Fonte: titulos_bordero_imprimir.php
	 Autor: Guilherme
	 Data : November/2008                 Última Alteração: 12/07/2011

	 Objetivo  : Mostrar opção Imprimir da rotina de Descontos de títulos
				 subrotina borderôs

	 Alterações: 22/09/2010 - Ajuste para enviar impressoes via email para 
				              o PAC Sede (David).
							  
							  
			     12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend><? echo utf8ToHtml('Impressão') ?></legend>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="carregaBorderosTitulos();return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/completa.gif" onClick="gerarImpressao(5,2,'no');return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/titulos.gif" onClick="gerarImpressao(7,2,'no');return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/proposta.gif" onClick="gerarImpressao(6,2,'no');return false;" />
			
		</fieldset>
	</form>
</div>

<?php 
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
