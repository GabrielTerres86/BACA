<?php
/*****************************************************************
  Fonte        : form_incluir.php						Última Alteração:  
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Abril/2018
  Objetivo     : Mostrar o form para incluir uma nova nacionalidade
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmIncluir" name="frmIncluir" class="formulario" style="display:none;">

	<fieldset id="fsetIncluir" name="fsetIncluir" style="padding:0px; margin:0px; padding-bottom:10px;">

		<legend><? echo "Dados"; ?></legend>

		<label for="dsnacion"><? echo utf8ToHtml('Nacionalidade:') ?></label>
		<input type="text" id="dsnacion" name="dsnacion" />

		<input type="hidden" id="cdnacion" name="cdnacion"/>

		<label for="cdpais"><? echo utf8ToHtml('País:') ?></label>
		<input type="text" id="cdpais" name="cdpais" />
		<input type="text" id="nmpais" name="nmpais" />

		<label for="inacordo"><? echo utf8ToHtml('Acordo:') ?></label>
		<select name="inacordo" id="inacordo" class="campo">
			<option value=""></option>
			<option value="fatca">FATCA</option>
			<option value="crs">CRS</option>
		</select>

		<label for="dtinicio"><? echo utf8ToHtml('Data Início:') ?></label>
		<input type="text" id="dtinicio" name="dtinicio" />

		<label for="dtfinal"><? echo utf8ToHtml('Data Fim:') ?></label>
		<input type="text" id="dtfinal" name="dtfinal" />

		<br style="clear:both" />

	</fieldset>
		
</form>

<div id="divBotoesIncluir" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Concluir</a>	
				
</div>
