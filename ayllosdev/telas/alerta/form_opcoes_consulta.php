<?
/******************************************************************
  Fonte        : form_opcoes_consulta.php
  Criação      : Adriano
  Data criação : Fevereiro/2013
  Objetivo     : Form com as opcoes para consulta da tela ALERTA.
  --------------
  Alterações   :
  --------------
 *****************************************************************/ 
?>

<form id="frmOpcoesConsulta" name="frmOpcoesConsulta" class="formulario" style="display:none;">	
		
	<fieldset id="fsetOpcoesConsulta" name="fsetOpcoesConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> <? echo utf8ToHtml('Consulta'); ?> </legend>
		
		<div id="divRelatorio">
		
			<label for="tprelato"> <? echo utf8ToHtml('Relat&oacute;rio:'); ?> </label>
			<select id="tprelato" name="tprelato" >
				<option value="1"> Alerta de emitidos </option> 
				<option value="2"> <? echo utf8ToHtml('Relat&oacute;rio Geral/Anal&iacute;tico'); ?> </option>	
			</select>
			<a href="#" class="botao" id="btOKRel"  style="text-align: right;">OK</a>

		</div>
		
		<br />
				
		<div id="divNomeCpf" >	
			<label for="tppesqui">Procurar por:</label>
			<input name="tppesqui" id="cpfcgc" type="radio" class="radio" />
			<label for="cpfcgcRadio" class="radio">Número CPF/CNPJ</label>
			<input name="tppesqui" id="nome" type="radio" class="radio" />
			<label for="nomeRadio" class="radio">Nome</label>
		</div>
		
		<br />
			
		<div id="divCpf">
			<label for="consucpf"><? echo utf8ToHtml('Digite o n&uacute;mero do CPF/CNPJ:') ?></label>
			<input name="consucpf" id="consucpf" type="text" />
		</div>
			
		<div id="divNome">
			<label for="consupes"><? echo utf8ToHtml('Informe o nome:') ?></label>
			<input name="consupes" id="consupes" type="text" />
		</div>
		
		<div id="divPeriodo" style="display:none;">
			<label for="dtinicio"><? echo utf8ToHtml('Data inicial:') ?></label>
			<input name="dtinicio" id="dtinicio" type="text" class="data"/>
			<label for="dtdfinal"><? echo utf8ToHtml('Data final:') ?></label>
			<input name="dtdfinal" id="dtdfinal" type="text" class="data" />
		</div>
			
		<br />
		<br />
		
		
	</fieldset>

	
</form>

<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

	<a href="#" class="botao" id="btVoltar"   onClick="controlaLayout('V1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btConsulta" onClick="controlaOperacao($('#cddopcao','#frmCabAlerta').val(),1,30);return false;">Consulta</a>

</div>