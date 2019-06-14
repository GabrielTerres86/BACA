<?php
/*****************************************************************
  Fonte        : form_filtro.php				
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Agosto/2018
  Objetivo     : Mostrar os filtros para a tela SPBMSG
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
		
		<label for="cdfase">Fase:</label>
		<select name="cdfase" id="cdfase" class="campo">
		</select>

		<label for="cdcooper">Cooperativa:</label>
		<select name="cdcooper" id="cdcooper" class="campo">
		</select>

		<br style="clear:both" />

		<label for="mensagem">Mensagem:</label>
        <input name="mensagem" id="mensagem" type="text"/>
		
		<label for="valorini">Valor de:</label>
        <input name="valorini" id="valorini" type="text" />

        <label for="valorfim">Até:</label>
        <input name="valorfim" id="valorfim" type="text" />

        <label for="horarioini">Horário de:</label>
        <input name="horarioini" id="horarioini" type="text" />

        <label for="horariofim">Até:</label>
        <input name="horariofim" id="horariofim" type="text" />

		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Consultar</a>	
				
</div>


