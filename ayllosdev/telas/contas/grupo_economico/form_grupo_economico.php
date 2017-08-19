<? 
/*!
 * FONTE        : form_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Formulário da rotina do Grupo Economico da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form name="frmGrupoEconomico" id="frmGrupoEconomico" class="formulario">

	<fieldset>	
		
		<label for="idgrupo"><?= utf8ToHtml('Identif. Grupo Econômico:') ?></label>
		<input type="text" id="idgrupo" name="idgrupo" class="campo" />
				
		<label for="nmgrupo">Nome:</label>
		<input type="text" id="nmgrupo" name="nmgrupo" class="campo" />
		
		<label for="dtinclusao"><?= utf8ToHtml('Data da Criação:') ?></label>
		<input type="text" id="dtinclusao" name="dtinclusao" class="campo" />
	
		<fieldset>	
			<legend><?= utf8ToHtml('Integrantes Grupo Econômico') ?></legend>
		
			<label for="listarTodos">Apresentar Todos:</label>
			<input type="checkbox" name="listarTodos" id="listarTodos" class="clsCheckbox"/>
				
			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta" class="campo" />
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<br /> 
			<br /> 
			
			<div id="divIntegrantesGrupoEconomico"></div>		
		</fieldset>
		
		<label for="dsobservacao"><?= utf8ToHtml('Observação:') ?></label>
		<br /> 
		<textarea name="dsobservacao" id="dsobservacao" class="textarea"></textarea>
	</fieldset>
</form>
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina(divRotina); return false;">Voltar</a>
	<a href="#" class="botao" id="btIncluirIntegrante" onclick="abreTelaInclusaoIntegrante(); return false;">Incluir Integrante</a>
	<a href="#" class="botao" id="btExcluirGrupo"      onclick="solicitaExclusaoIntegrante(); return false;">Excluir Integrante</a>
	<? if (getByTagName($xmlObjeto->roottag->tags[0]->tags,'idgrupo') > 0){ ?>	
			<a href="#" class="botao" id="btIncluirGrupo" onclick="manterRotina('AlterarGrupo','frmGrupoEconomico'); return false;">Alterar Grupo</a>
	<? }else{ ?>
			<a href="#" class="botao" id="btIncluirGrupo" onclick="manterRotina('IncluirGrupo','frmGrupoEconomico'); return false;">Incluir Grupo</a>
	<? } ?>	
	<a href="#" class="botao" id="btImprimir" onclick="imprimirRelatorio(); return false;">Imprimir Grupo</a>
</div>	