<?
/*!
 * FONTE        : form_conta_corrente.php
 * CRIAÇÃO      : Heitor (Mouts)
 * DATA CRIAÇÃO : Julho/2017
 * OBJETIVO     : Formulário da rotina Liberar/Bloquear da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *                15/03/2018 - Campo de selecao de cancelamento automatico de credito (Marcel Kohls / AMCom)
 * --------------
 */
?>
<form name="frmContaCorrente" id="frmContaCorrente" class="formulario" >

    <label for="flgrenli"><? echo utf8ToHtml(' Renova Limite Cr&eacute;dito/Desconto Cheque Autom&aacute;tico:') ?></label>
	<select id="flgrenli" name="flgrenli" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>

	<br \>
	<br \>

	<label for="flmajora"><? echo utf8ToHtml(' Permite Majora&ccedil;&atilde;o de Cr&eacute;dito:') ?></label>
	<select id="flmajora" name="flmajora" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>

	<br \>
	<br \>

    <label for="flcnaulc"><? echo utf8ToHtml(' Cancelamento Autom&aacute;tico do Limite de Cr&eacute;dito:') ?></label>
	<select id="flcnaulc" name="flcnaulc" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>

	<br \>
	<br \>

	<label for="motivo_bloqueio_maj"><? echo utf8ToHtml('Motivo do bloqueio da Majora&ccedil;&atilde;o:') ?></label>
	<input type="text" id="motivo_bloqueio_maj" name="motivo_bloqueio_maj" />

	<br \>
	<br \>

	<label for="cdopemaj"><? echo utf8ToHtml(' Operador &uacute;ltima altera&ccedil;&atilde;o:') ?></label>
	<input type="text" id="cdopemaj" name="cdopemaj" />
	<input type="text" id="nmopemaj" name="nmopemaj" />

</form>

<div id="divBotoes">
	<? if ( in_array($operacao,array('AM',''))){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('MA')" />
	<? } else if ( $operacao == 'MA' ){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AM')" />
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('ALTERARM')" />
	<? }?>
</div>
