<? 
/*!
 * FONTE        : form_inclusao_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Formulário da rotina do Grupo Economico da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form name="frmInclusaoGrupoEconomico" id="frmInclusaoGrupoEconomico" class="formulario">

	<fieldset>	
		
		<label for="nmgrupo">Nome:</label>
		<input type="text" id="nmgrupo" name="nmgrupo" class="campo" />		
		
	</fieldset>
</form>
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divUsoGenerico'), $('#divRotina')); return false;">Voltar</a>
	<a href="#" class="botao" id="btIncluirGrupo" onclick="manterRotina('IncluirGrupo','frmInclusaoGrupoEconomico'); return false;">Incluir Grupo</a>	
</div>