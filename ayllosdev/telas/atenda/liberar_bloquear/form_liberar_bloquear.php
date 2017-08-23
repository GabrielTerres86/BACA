<? 
/*!
 * FONTE        : form_liberar_bloquear.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Formulário da rotina Liberar/Bloquear da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 05/01/2016 - Adicionar campo para Liberar credito pre-aprovado, flgcrdpa (Anderson)
 *				  27/07/2016 - Adicionados novos campos para a fase 3 do projeto pre aprovado (Lombardi)
 *                03/05/2017 - Ajuste na label do campo flgrenli para o projeto 300. (Lombardi)
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 * --------------
 */	
?>
<form name="frmLiberarBloquear" id="frmLiberarBloquear" class="formulario" >

    <label for="flgcrdpa"><? echo utf8ToHtml(' Libera Cr&eacute;dito Pr&eacute;-Aprovado:') ?></label>
	<select id="flgcrdpa" name="flgcrdpa" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>
	<label for="dtultatt"><? echo utf8ToHtml(' Data &Uacute;ltima Atualiza&ccedil;&atilde;o:') ?></label>
	<input type="text" id="dtultatt" name="dtultatt" />
	
	<label for="motivo_bloqueio"><? echo utf8ToHtml('Motivo do bloqueio:') ?></label>
	<input type="text" id="motivo_bloqueio" name="motivo_bloqueio" />
	
	<fieldset>
	
		<legend><? echo utf8ToHtml('Pr&eacute;-Aprovado Carga Semanal:') ?></legend>
		<label for="liberado_sem"><? echo utf8ToHtml(' Conta com Cr&eacute;dito Pr&eacute;-Aprovado Liberado:') ?></label>
		<select id="liberado_sem" name="liberado_sem" >
			<option value="yes">Sim</option>
			<option value="no">Não</option>
		</select>
		
	</fieldset>
	
	<fieldset>
	
		<legend><? echo utf8ToHtml('Pr&eacute;-Aprovado Carga Manual:') ?></legend>
		<label for="liberado_man"><? echo utf8ToHtml(' Conta com Cr&eacute;dito Pr&eacute;-Aprovado Liberado:') ?></label>
		<select id="liberado_man" name="liberado_man" >
			<option value="yes">Sim</option>
			<option value="no">Não</option>
		</select>

		<label for="dscarga"><? echo utf8ToHtml('Identifica&ccedil;&atilde;o Carga:') ?></label>
		<input type="text" id="dscarga" name="dscarga" />
		
		<label for="dtinicial"><? echo utf8ToHtml('Vig&ecirc;ncia da Carga:') ?></label>
		<input type="text" id="dtinicial" name="dtinicial" />
		
		<label for="dtfinal"><? echo utf8ToHtml('&nbsp;&nbsp;at&eacute;&nbsp;') ?></label>
		<input type="text" id="dtfinal" name="dtfinal" />
		
	</fieldset>
	

</form>

<div id="divBotoes">	
	<? if ( in_array($operacao,array('AC',''))){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
	<? } else if ( $operacao == 'CA' ){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('ALTERAR')" />
	<? }?>
</div>
