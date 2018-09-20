<?php 

	/************************************************************************
	 Fonte: cheques_bordero_imprimir.php
	 Autor: Guilherme
	 Data : November/2008                   Última Alteração: 12/09/2016

	 Objetivo  : Mostrar opção Imprimir da rotina de Descontos de CHEQUES
				 subrotina borderôs

	 Alterações: 21/09/2010 - Ajuste para enviar impressoes via email para 
				              o PAC Sede (David).
							  
				 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)

				 12/09/2016 - Removido o botao Completa. (Jaison/Daniel)
                 
                 30/05/2017 - Incluir idimpres 10 para impressão bordero cooperado.
                              PRJ300 - Desconto de Cheque(Odirlei-AMcom)
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
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<!--style="clear: both; border: 1px solid #bbb; margin: 3px; padding: 0px 3px 5px 3px; padding-bottom: 10px;"-->

<div id="divBotoes" style="width: 500px;">
	<fieldset style="clear: both; border: 1px solid #bbb; margin: 3px; padding: 0px 3px 5px 3px; padding-bottom: 10px;">
		<legend style="font-size: 11px; color: #333; margin-left: 5px; padding: 0px 2px;"><? echo utf8ToHtml('Impressão') ?></legend>
			
			<a href="#" class="botao" id="btVoltar" onClick="carregaBorderosCheques();return false;">Voltar</a>
		<a href="#" class="botao" id="btCheques" onClick="gerarImpressao(10,2,'no','',0);return false;">Border&ocirc; Cooperado</a>
			<a href="#" class="botao" id="btCheques" onClick="gerarImpressao(7,2,'no','',1);return false;">Border&ocirc; Cooperativa</a>
			<a href="#" class="botao" id="btProposta" onClick="gerarImpressao(6,2,'no');return false;">Proposta</a>
			
		</fieldset>
</div>

<?php 
// Form com os dados para fazer a chamada da geração de PDF	
include("impressao_form_dscchq.php"); 
?>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
