<?php 
	/************************************************************************
	  Fonte: entregar_cartao_bancoob.php
	  Autor: James Prust Junior
	  Data : Maio/2014                 Última Alteração: 21/05/2014

	  Objetivo:   Mostra a opção da tela entregar cartões do bancoob

	  Alterações: 
	************************************************************************/	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	include('form_entrega_cartao_bancoob.php');
?>
<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart&otilde;es
$("#divConteudoCartoes").css("display","none");
// Acao do formulario
nomeacao = 'ENTREGAR_CARTAO';

controlaLayout('frmEntregaCartaoBancoob');

$('#fieldEntregar legend').text('Entregar');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>