<? 
/*!
 * FONTE        : form_grupo_economico_integrantes.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Formulário de inclusao de integrantes do grupo economico
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<form name="frmGrupoEconomicoIntegrantes" id="frmGrupoEconomicoIntegrantes" class="formulario">

	<fieldset>

		<label for="tppessoa">Tipo Pessoa:</label>
		<select name="tppessoa" id="tppessoa" class="campo">
			<option value="1"><?= utf8ToHtml('Física') ?></option>
			<option value="2"><?= utf8ToHtml('Jurídica') ?></option>
		</select>
		
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" class="campo" value="" />

		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" class="campo" />
		<a style="padding: 3px 0 0 3px;" id="lupa_nrdconta"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nmprimtl">Nome</label>
		<input name="nmprimtl" id="nmprimtl" type="text" class="campo" value="" />
		
		<label for="tpvinculo"><?= utf8ToHtml('Tipo Vínculo:') ?></label>
		<select name="tpvinculo" id="tpvinculo" class="campo">
			<option value="1"><?= utf8ToHtml('Conta PJ') ?></option>
			<option value="2"><?= utf8ToHtml('Sócio(a)') ?></option>
			<option value="3"><?= utf8ToHtml('Cônjuge') ?></option>
			<option value="4"><?= utf8ToHtml('Companheiro') ?></option>
			<option value="5"><?= utf8ToHtml('Parente primeiro grau') ?></option>
			<option value="6"><?= utf8ToHtml('Parente segundo grau') ?></option>
			<option value="7"><?= utf8ToHtml('Outro') ?></option>
		</select>
		
		<label for="peparticipacao"><?= utf8ToHtml('% Participação:') ?></label>
		<input name="peparticipacao" id="peparticipacao" type="text" class="campo moeda" value="" />
		
	</fieldset>	
	
</form>
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divUsoGenerico'), $('#divRotina')); return false;">Voltar</a>	
	<a href="#" class="botao" id="btIncluir" onclick="incluirIntegranteGrupoEconomico(); return false;">Incluir</a>	
</div>	