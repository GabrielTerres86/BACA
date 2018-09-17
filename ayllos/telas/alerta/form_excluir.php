<?
/************************************************************************************
  Fonte        : form_excluir.php
  Criação      : Adriano
  Data criação : Fevereiro/2013
  Objetivo     : Form da opção "Excluir" da tela ALERTA.
  --------------
  Aalterações  :
  --------------
 ************************************************************************************/ 
?>

<form id="frmExcluir" name="frmExcluir" class="formulario" style="display:none;">	
		
	<fieldset id="fsetExcluir" name="fsetExcluir" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> <? echo utf8ToHtml('Excluir'); ?> </legend>
		
		<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
			
		<br />
			
		<label for="nmpessoa"><? echo utf8ToHtml('Nome:') ?></label>
		<input name="nmpessoa" id="nmpessoa" type="text" />
			
		<br />
						
		<label for="tporigem"><? echo utf8ToHtml('Motivo da Restri&ccedil;&atilde;o:') ?></label>
		<select id="tporigem" name="tporigem">
			<option value="1">Interno</option>
			<option value="2">Externo</option>
		</select>
		
		<br />
					
		<label for="nmpessol"><? echo utf8ToHtml('Solicitado por:') ?></label>
		<input name="nmpessol" id="nmpessol" type="text" />
		
		<br />	
		
		<label for="cdbccxlt">Instiui&ccedil;&atilde;o Financeira:</label>
		<input name="cdbccxlt" id="cdbccxlt" type="text" />
		<a style="padding: 3px 0 0 3px;" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="nmextbcc"></label>
		<input name="nmextbcc" id="nmextbcc" type="text" />
		
		<br />
			
		<label for="dtinclus"><? echo utf8ToHtml('Data da Inclus&atilde;o:') ?></label>
		<input name="dtinclus" id="dtinclus" type="text" />
		
		<br />
		
		<label for="dsjusinc"><? echo utf8ToHtml('Justificativa da Inclus&atilde;o:') ?></label>
		<textarea name="dsjusinc" id="dsjusinc" ></textarea>
		
		<br />
			
		<label for="nmcopinc"><? echo utf8ToHtml('Cadastrado por:') ?></label>
		<input name="nmcopinc" id="nmcopinc" type="text" />
			
		<br />
			
		<label for="dsjusexc"><? echo utf8ToHtml('Justificativa da Exclus&atilde;o:') ?></label>
		<textarea name="dsjusexc" id="dsjusexc" ></textarea>
	
		<br />
		<br />
			
	</fieldset>
		
	
</form>

<div id="divBotoesExcluir" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

	<a href="#" class="botao" id="btVoltar"  onclick="controlaLayout('V1');return false;">Voltar</a>
	<a href="#" class="botao" id="btExcluir"  onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluir();','controlaLayout(\'V1\');','sim.gif','nao.gif');return false;">Excluir</a>

</div>

