<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas R.         
 * DATA CRIAÇÃO : 02/05/2013
 * OBJETIVO     : Cabecalho para a tela CADBND
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (I, A ou E).">
		<option value="I"> <? echo utf8ToHtml('I - Incluir contas BNDES.') ?> </option>
		<option value="A"> <? echo utf8ToHtml('A - Alterar contas BNDES.') ?> </option>
		<option value="E"> <? echo utf8ToHtml('E - Excluir contas BNDES.') ?> </option>
	</select>
	<br>	
			
	<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<a href="#" class="botao" id="btOk" onclick="consultaInicial();return false;">Ok</a>
	
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl ?>" />
	
	<br>
	<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo $nrcpfcgc ?>" />
	
	<br style="clear:both" /> 
</form>

<script type='text/javascript'>
	formataCabecalho();
</script>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btContinuar" onClick="btnContinuar(); return false;">Prosseguir</a>
</div>