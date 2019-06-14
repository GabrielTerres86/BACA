<?php 

	/***************************************************************************
	 Fonte: form_solicita_talonarios.php
	 Autor: Lombardi
 	 Data : 30/11/2018                    Última Alteração: 

	 Objetivo  : Formulario de solicitacao de talonarios

	 Alterações: 
				
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'S',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
?>

<form id="frmSolicitaTalonarios" name="frmSolicitaTalonarios" class="formulario">
	<fieldset>
		<legend><? echo utf8ToHtml('Solicitação de Talões') ?></legend>
		<div>
			<label for="qtreqtal"><? echo utf8ToHtml('Quantidade de talões:') ?></label>
			<input name="qtreqtal" id="qtreqtal" type="text" />
		</div>
	</fieldset>
</form>

<div id="divBotoes" style="height:25px;">
	<a href="#" class="botao" id="btnVoltar" name="btnVoltar" onClick="voltarConteudo('divConteudoOpcao','divTalionario');return false;">Voltar</a>
	<a href="#" class="botao" id="btnContinuar" name="btnContinuar" onClick="confirmaSolicitarTalonario();">Solicitar</a>
</div>

<script type="text/javascript">

dscShowHideDiv("divTalionario","divConteudoOpcao");

formataLayout('frmSolicitaTalonarios');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
