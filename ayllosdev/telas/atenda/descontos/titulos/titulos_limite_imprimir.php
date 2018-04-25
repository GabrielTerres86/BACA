<?php 

	/************************************************************************
	 Fonte: titulos_limite_imprimir.php
	 Autor: Guilherme
	 Data : Novembro/2008                 Última Alteração: 24/07/2014

	 Objetivo  : Mostrar opção Imprimir da rotina de Descontos de títulos
				subrotina limite

     Alterações: 09/06/2010 - Adaptação para RATING (David).
	 
	             22/09/2010 - Ajuste para enviar impressoes via email para 
				              o PAC Sede (David).
							  
				 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
				 
				 24/07/2014 - Ajustes para incluir botao do cet e ajustado 
							  novo padrao os botoes (Lucas R./Gielow - Projeto CET)

				 15/04/2018 - Correção botão voltar (Leonardo Oliveira - GFT)
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

	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);



	if(!in_array("M", $opcoesTela)){

		$msgError = "Operador nao possui permissao de acesso.";
		exibeErro($msgError);		
	}



	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";


	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divBotoes" style="width:550px" >
	
	<a href="#" class="botao" id="btVoltar"   		 onClick="fecharRotinaGenerico('<?php echo $tipo ?>');return false;">Voltar </a>
	<a href="#" class="botao" id="btCompleta" 		 onClick="verificaEnvioEmail(1,1);return false;">Completa</a>
	<a href="#" class="botao" id="btContrato" 		 onClick="verificaEnvioEmail(2,1);return false;">Contrato</a>
	<a href="#" class="botao" id="btCet"      		 onClick="verificaEnvioEmail(9,1);return false;">CET     </a>
	<a href="#" class="botao" id="btProposta"        onClick="verificaEnvioEmail(3,1);return false;">Proposta</a>
	<a href="#" class="botao" id="btNotaPromissoria" onClick="verificaEnvioEmail(4,1);return false;">Nota Promissoria</a>
	<a href="#" class="botao" id="btRating" 		 onClick="gerarImpressao(8,1,'no','mostraImprimirGenerico()');return false;">Rating</a>
	<br/>
	<br/>
	
</div>

<?php 
// Forms com os dados para fazer a chamada da geração de PDF	
include("impressao_form.php"); 
include("../../../../includes/rating/rating_formulario_impressao.php"); 
?>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

function mostraImprimirGenerico(){
	mostraImprimirLimite('<?php echo $tipo ?>');
	return false;
}
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>