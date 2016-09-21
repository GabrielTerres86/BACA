<?php 
	/************************************************************************
	  Fonte: 2via_senha_cartao_chip.php
	  Autor: James Prust Junior
	  Data : Julho/2014                 �ltima Altera��o:

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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}
	
	include('form_entrega_cartao_bancoob.php');	
?>
<script type="text/javascript">
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart&otilde;es
$("#divConteudoCartoes").css("display","none");
// Acao do formulario
nomeacao = '2VIA_CARTAO_CHIP';

controlaLayout('frmEntregaCartaoBancoob');

$('#fieldEntregar legend').text('Alterar senha');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� atr�s do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>