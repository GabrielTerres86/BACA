<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Adriano - CECRED
  Data criação : Julho/2017
  Objetivo     : Mostrar os filtros para da tela CADCNA
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
		
		<label for="cdcnae">CNAE:</label>
        <input name="cdcnae" id="cdcnae" type="text" class="codigo pesquisa" />        
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="dscnae" id="dscnae" type="text" />
			
		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Prosseguir</a>	
				
</div>


