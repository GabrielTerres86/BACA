<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Exibe a tela de Alinea - tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923) 
 *                08/05/2019 - Inclusão botão alterar alinea
 *                           - Validação do botão Alterar Alinea para mostrar apenas para o depto COMPE
 							   e permissão no PERMIS (Luiz Otávio Olinger Momm - AMCOM)
 *                16/05/2019 - Conferido se a permissão deve ser apenas para o botão Alterar Alinea
*							   (Luiz Otávio Olinger Momm - AMCOM)
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Se for Alterar Alinea deve verificar a permissão
	if ($_POST['opcao'] == 'AL') {
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A', false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
		}
	}
?>

<form id="frmAlinea" name="frmAlinea" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Informe a Alinea') ?></legend>
		<br />
		<label for="cdalinea"><? echo utf8ToHtml('C&oacute;digo da Alinea:') ?></label>
		<input name="cdalinea" id="cdalinea" type="text"/>
		<br />
	</fieldset>	
</form>

<div id="divBotoes2">
    <br />
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); btnAA = false; return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="proc_gera_dev(); return false;">Ok</a>
</div>