<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Abril/2018
  Objetivo     : Mostrar os filtros para a tela REPEXT
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">	
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Filtros"; ?></legend>

		<label for="dtinicio"><? echo utf8ToHtml('Período de:') ?></label>
		<input id="dtinicio" name="dtinicio" type="text"/>
		
		<label for="dtfinal"><? echo utf8ToHtml('Até:') ?></label>
		<input id="dtfinal" name="dtfinal" type="text" />

		<label for="insituacao"><? echo utf8ToHtml('Situação:') ?></label>
		<select name="insituacao" id="insituacao" class="campo">
			<option value="P">Pendente</option>
			<option value="A">Analisada</option>
		</select>

		<label for="inreportavel"><? echo utf8ToHtml('Reportável:') ?></label>
		<select name="inreportavel" id="inreportavel" class="campo">
			<option value="A">Ambos</option>
			<option value="S">Sim</option>
			<option value="N"><? echo utf8ToHtml('Não') ?></option>
		</select>
		
		<label for="nrcpfcgc">Cooperado:</label>
        <input name="nrcpfcgc" id="nrcpfcgc" type="text" class="pesquisa" />        
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="nmpessoa" id="nmpessoa" type="text" />
			
		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Prosseguir</a>	
				
</div>
