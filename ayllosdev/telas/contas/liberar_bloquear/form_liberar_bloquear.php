<? 
/*!
 * FONTE        : form_liberar_bloquear.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Formulário da rotina Liberar/Bloquear da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 05/01/2016 - Adicionar campo para Liberar credito pre-aprovado, flgcrdpa (Anderson)
 * --------------
 */	
?>
<form name="frmLiberarBloquear" id="frmLiberarBloquear" class="formulario" >

    <label for="flgrenli"><? echo utf8ToHtml(' Renova Limite Credito Automatico:') ?></label>
	<select id="flgrenli" name="flgrenli" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>
	<br \>
	<br \>
	<label for="flgcrdpa"><? echo utf8ToHtml(' Libera Credito Pre-Aprovado:') ?></label>
	<select id="flgcrdpa" name="flgcrdpa" >
        <option value="yes">Sim</option>
		<option value="no">Não</option>
	</select>

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
