<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/05/2011
 * OBJETIVO     : Cabeçalho para a tela AUTORI
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Migrado para o Novo Layout (Lucas).
 * --------------
 * 				  19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 *							   Softdesk 148330 (Lucas R.)
 *                26/03/2018 - Alterado para permitir acesso a tela pelo CRM. (Reinert)
 */ 
?>

<form id="frmCabAutori" name="frmCabAutori" class="formulario">

    <input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
    <input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />

	<label for="opcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="opcao" name="opcao" alt="Informe a opcao desejada (A, C, D, E ou S).">
		<option value="C1"> <? echo utf8ToHtml('C - Consultar autorização para débito') ?> </option> 
		<option value="I1"> <? echo utf8ToHtml('I - Incluir autorização para débito') ?> </option>
		<option value="E1"> <? echo utf8ToHtml('E - Excluir autorização para débito') ?> </option>
		<option value="R1"> <? echo utf8ToHtml('R - Recadastrar os débitos automáticos') ?> </option>
		<option value="S1"> <? echo utf8ToHtml('S - Autorização de envio de SMS') ?> </option>
	</select>
	<br>
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btOk" onclick="consultaInicial();return false;">OK</a>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $dsdconta ?>" />
	
	<br style="clear:both" />	
	
</form>

<script type='text/javascript'>
	formataCabecalho();
</script>