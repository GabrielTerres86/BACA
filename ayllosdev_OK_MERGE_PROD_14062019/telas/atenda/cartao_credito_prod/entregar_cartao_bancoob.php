<?php 
	/************************************************************************
	  Fonte: entregar_cartao_bancoob.php
	  Autor: James Prust Junior
	  Data : Maio/2014                 �ltima Altera��o: 21/05/2014

	  Objetivo:   Mostra a op��o da tela entregar cart�es do bancoob

	  Altera��es: 
	************************************************************************/	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	include('form_entrega_cartao_bancoob.php');
?>
<script type="text/javascript">
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart&otilde;es
$("#divConteudoCartoes").css("display","none");
// Acao do formulario
nomeacao = 'ENTREGAR_CARTAO';

controlaLayout('frmEntregaCartaoBancoob');

$('#fieldEntregar legend').text('Entregar');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� atr�s do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>