<?php 

	/************************************************************************
	 Fonte: cheques_limite_imprimir.php
	 Autor: Guilherme
	 Data : Março/2009                 Última Alteração: 22/07/2014

	 Objetivo  : Mostrar opção Imprimir da rotina de Descontos de CHEQUES
				 subrotina limite

	 Alterações: 14/06/2010 - Adaptação para RATING (David).
	 
	             21/09/2010 - Ajuste para enviar impressoes via email para 
                                  o PAC Sede (David).

	             12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)

	             22/07/2014 - Ajustes para incluir botao do cet e ajustado 
                                  novo padrao os botoes (Lucas R./Gielow - Projeto CET)

	             01/02/2019 - Remover a impressão do Rating Atual conforme estória: Product Backlog Item 13986:
                                  Rating - Ajustes em Telas Desabilitar impressão
                                  P450 - Luiz Otávio Olinger Momm (AMCOM)

                     02/07/2019 - PRJ 438 - Sprint 14 - Removido a opção 'Nota Promissoria' da tela de Impressão  (Mateus Z / Mouts)
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


<div id="divBotoes" style="width:550px" >
	
	<a href="#" class="botao" id="btVoltar"   		 onClick="carregaLimitesCheques(); return false;">Voltar </a>
	<a href="#" class="botao" id="btCompleta" 		 onClick="verificaEnvioEmail(1,1);return false;">Completa</a>
	<a href="#" class="botao" id="btContrato" 		 onClick="verificaEnvioEmail(2,1);return false;">Contrato</a>
	<a href="#" class="botao" id="btCet"      		 onClick="verificaEnvioEmail(9,1);return false;">CET     </a>
	<a href="#" class="botao" id="btProposta"        onClick="verificaEnvioEmail(3,1);return false;">Proposta</a>

	<br/>
	<br/>
	
</div>


<?php 
// Forms com os dados para fazer a chamada da geração de PDF	
include("impressao_form_dscchq.php"); 
include("../../../../includes/rating/rating_formulario_impressao.php"); 
?>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
