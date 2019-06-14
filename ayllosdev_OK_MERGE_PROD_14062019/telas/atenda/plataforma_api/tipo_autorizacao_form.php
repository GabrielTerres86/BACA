<?php
	/*!
	* FONTE        : tipo_autorizacao_form.php
	* CRIAÇÃO      : Andrey Formigari
	* DATA CRIAÇÃO : Abril/2019
	* OBJETIVO     : Mostrar rotina para Termo de Liberação de Condições de Uso.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$cddopcao   = ( ( !empty($_POST['cddopcao']) )   ? $_POST['cddopcao']   : '' );
	
	if ($cddopcao == 'A' || $cddopcao == 'I'){
?>
<fieldset style="padding:5px">
    <legend><? echo utf8ToHtml('Termo de adesão ao serviço de API de Cobrança'); ?></legend>
    <form action="" method="post" name="frmTipoAutorizacao" id="frmTipoAutorizacao" class="formulario">
		<div id="divDados" class="clsCampos">		
			<div class="clsCampos" style="width: 355px;padding-right: 5px;float: left;font-weight: bold;text-align: right;padding: 5px;"><? echo utf8ToHtml('Tipo de Autoriazação:');?></div>
			<div style="margin-top: 3px;width: 295px;float: left;">
				<input style="background: none;" type="radio" value="1" id="tp_autorizacao_1" name="tp_autorizacao" /> <label for="tp_autorizacao_1" class="clsCampos" style="font-weight: 100;margin: -2px 3px;"><? echo utf8ToHtml('Senha');?></label>
				<input style="background: none;" type="radio" value="2" id="tp_autorizacao_2" name="tp_autorizacao" /> <label for="tp_autorizacao_2" class="clsCampos" style="font-weight: 100;margin: -2px 3px;"><? echo utf8ToHtml('Assinatura');?></label>
			</div>
		</div>
	</form>
</fieldset>
<? } ?>
<!-- Botoes -->
<div id="divBotoes" style="padding-bottom:10px" class="divBotoesReferencia">
<? if ($cddopcao == 'A' || $cddopcao == 'I') { ?>
<input id="btContinuar" type="button" class="botao" value="Gravar" onclick="solicitaSenha();" style="margin-left: -16px;" />
<? } ?>
<? if ($cddopcao == 'C' || $cddopcao == 'A') { ?>
<input id="btVoltar" type="button" class="botao" value="Voltar" onclick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina'));if(!$('#divRotina').hasClass('detailDesen')){controlaOperacao('P');}return false;"/>
<? } else { ?>
<input id="btVoltar" type="button" class="botao" value="Voltar" onclick="controlaLayout('F')"/>
<? } ?>
</div>
<script type="text/javascript">
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divUsoGenerico").css("z-index")));
	
	// deixa visível a div
	$('#divTipoAutoriazacao').show();
</script>