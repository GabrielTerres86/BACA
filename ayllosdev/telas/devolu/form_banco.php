<?php
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Formulario de tela de Opcoes de Banco - tela DEVOLU
 * --------------
 * ALTERAÇÕES   :
 * 
 * --------------
 */ 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmBanco" name="frmBanco" class="formulario" onsubmit="return false;">

	<fieldset>
        <br style="clear:both" />
        <label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
        <select id="cddopcao" name="cddopcao">
		<option value="1"><? echo utf8ToHtml('Devolucoes BANCOOB') ?></option>
        <option value="2"><? echo utf8ToHtml('Devolucoes CONTA BASE') ?></option>
		<option value="3"><? echo utf8ToHtml('Devolucoes CONTA INTEGRACAO') ?></option>
        </select><br style="clear:both" />
	</fieldset>
</form>

<div id="divBotoes2">
    <br style="clear:both" />
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="verifica_solicitacao_processo(); return false;">Ok</a>
</div>