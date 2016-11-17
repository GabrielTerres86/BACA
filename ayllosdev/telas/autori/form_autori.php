<? 
 /*!
 * FONTE        : form_autori.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/05/2011 
 * OBJETIVO     : Formulário de exibição das Autorizações
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Migrado para o Novo Layout (Lucas).
 * --------------
 * 				  19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 *							   Softdesk 148330 (Lucas R.)
 *
 *				  05/02/2015 - Incluir id "lupa_frmAutori" na lupa do historico (Lucas R. #242146).
 *
 *                15/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
<?
	$executandoProdutos = $_POST['executandoProdutos'];
?>

<form name="frmAutori" id="frmAutori" class="formulario">	

	<fieldset>
		<legend><? echo utf8ToHtml('Dados da Autorização') ?></legend>
	
		<label for="flgsicre">Sicredi:</label>
		<select id="flgsicre" name="flgsicre" alt="<? echo utf8ToHtml('Convênio Sicredi, informe Sim ou Não(S/N).') ?> ">
			<option value="N"><? echo utf8ToHtml('Não')?> </option>
			<option value="S">Sim</option>
		</select>
		
		<label for="flgmanua">Manual:</label>
		<select id="flgmanua" name="flgmanua" alt="<? echo utf8ToHtml('Informe Sim ou Não(S/N).') ?> ">
			<option value="N"><? echo utf8ToHtml('Não')?> </option>
			<option value="S">Sim</option>
		</select>
	
		<label for="codbarra"><? echo utf8ToHtml('Cod. Barras:') ?></label>
		<input name="codbarra" id="codbarra" type="text" value="" />
		<br />
		<label for="fatura01"><? echo utf8ToHtml('Fatura:') ?></label>
		<input name="fatura01" id="fatura01" type="text" value="" />
		
		<label for="fatura02"><? echo utf8ToHtml('-') ?></label>
		<input name="fatura02" id="fatura02" type="text" value="" />
		
		<label for="fatura03"><? echo utf8ToHtml('-') ?></label>
		<input name="fatura03" id="fatura03" type="text" value="" />
		
		<label for="fatura04"><? echo utf8ToHtml('-') ?></label>
		<input name="fatura04" id="fatura04" type="text" value="" />
		
	    <br /> 
		<label for="dshistor"><? echo utf8ToHtml('Convênio:') ?></label>
		<input name="dshistor" id="dshistor" type="text" value="<? echo getByTagName($registros[0]->tags,'dshistor'); ?>" />
		<input name="cdhistor" id="cdhistor" type="hidden" value="<? echo getByTagName($registros[0]->tags,'cdhistor'); ?>" />
		<a id="lupa_frmAutori"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>		
		
		<label for="cdrefere"><? echo utf8ToHtml('Ref.') ?></label>
		<input name="cdrefere" id="cdrefere" type="text" value="<? echo getByTagName($registros[0]->tags,'cdrefere') ?>" />
		
		<br />
		
		<label for="dtautori"><? echo utf8ToHtml('Data Aut.') ?></label>
		<input name="dtautori" id="dtautori" type="text" value="<? echo getByTagName($registros[0]->tags,'dtautori') ?>" />

		<label for="dtcancel"><? echo utf8ToHtml('Data Canc.') ?></label>
		<input name="dtcancel" id="dtcancel" type="text" value="<? echo getByTagName($registros[0]->tags,'dtcancel') ?>" />
		
		<label for="dtultdeb"><? echo utf8ToHtml('Último Deb.') ?></label>
		<input name="dtultdeb" id="dtultdeb" type="text" value="<? echo getByTagName($registros[0]->tags,'dtultdeb') ?>" />
		
	</fieldset>		
			
</form>

<div id="divBotoes">	
	<? if ($operacao == 'C1') { ?>
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<a href="#" class="botao" id="btConsultar" onClick="controlaOperacao('C2');">Consultar</a>
	<? } else if ($operacao == 'I1') { ?>
		<? if ($executandoProdutos == 'true') { ?>
			<a href="#" class="botao" id="btVoltar" onClick="voltarAtenda(); return false;">Cancelar</a>
		<? } else { ?>
			<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Cancelar</a>
		<? } ?>
	<a href="#" class="botao" id="btSalvarI5" onClick="controlaOperacao('I4'); return false; ">Incluir</a>
	<? } else if ($operacao == 'E1') { ?>
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvarE5" onClick="showConfirma(); return false;">Continuar</a>
	<? } else if ($operacao == 'R1') { ?>
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('R4'); return false;">Continuar</a>
	<? } else if ($operacao == 'R4') { ?>
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvarR5" onClick="controlaOperacao('R5'); return false;">Concluir</a>
	<? } ?>
</div>