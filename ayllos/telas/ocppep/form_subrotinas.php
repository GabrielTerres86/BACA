<?php
/*****************************************************************
  Fonte        : form_subrotinas.php						Última Alteração: 
  Criação      : Adriano
  Data criação : Fevereiro/2017
  Objetivo     : Mostrar as subrotinas da opção "A" 
  --------------
	Alterações   : 
  --------------
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmSubrotinas" name="frmSubrotinas" class="formulario" style="display:none;">	
	
	<fieldset id="fsetSubrotina" name="fsetSubrotina" style="padding:0px; margin:0px; padding-bottom:10px;display:none;">
	
		<legend> Subrotinas</legend>
		
		<div id="divSubrotina" style="display: none;">
			
			<label for="cdsubrot">Op&ccedil;&otilde;es:</label>
			<select id="cdsubrot" name="cdsubrot" >
				<option value="A"> Alterar </option>
				<option value="C" selected> Consultar </option>					
				<option value="E"> Excluir </option>	
				<option value="I"> Incluir </option>
			</select>
					
			<br style="clear:both" />	
				
		</div>

	</fieldset>
	
</form>

<div id="divBotoesSubRotinas" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V1');return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaLayout('2');return false;">Prosseguir</a>
			
</div>

