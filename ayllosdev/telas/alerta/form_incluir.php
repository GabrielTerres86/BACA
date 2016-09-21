<?
/**********************************************************************
  Fonte        : form_incluir_alerta.php
  Criação      : Adriano
  Data criação : Fevereiro/2013
  Objetivo     : Form da opção "Incluir" da tela ALERTA.
  --------------
  Alterações   :
  --------------
 *********************************************************************/ 
?>

<form id="frmIncluir" name="frmIncluir" class="formulario" style="display:none;">	
		
	<fieldset id="fsetIncluir" name="fsetIncluir" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> <? echo utf8ToHtml('Incluir'); ?> </legend>
		
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
		
		<label for="cdbccxlt">Instiui&ccedil;&atilde;o Financeira:</label>
		<input name="cdbccxlt" id="cdbccxlt" type="text" />
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="nmextbcc"></label>
		<input name="nmextbcc" id="nmextbcc" type="text" />
		
		<br />
				
		<label for="cdcopsol">Cooperativa:</label>
		<select name="cdcopsol" id="cdcopsol" alt="Selecione a Cooperativa">
		</select>
				
		<br />
			
		<label for="nmpessol"><? echo utf8ToHtml('Nome Solicitante:') ?></label>
		<input name="nmpessol" id="nmpessol" type="text" />
		
		<br />
		
		<label for="dsjusinc"><? echo utf8ToHtml('Justificativa:') ?></label>
		<textarea name="dsjusinc" id="dsjusinc" ></textarea>
		
		<br />
		
	</fieldset>
		
	
</form>

<div id="divBotoesIncluir" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

	<a href="#" class="botao" id="btVoltar"   onclick="estadoInicial();return false;">Voltar</a>
	<a href="#" class="botao" id="btIncluir"  onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluir();','','sim.gif','nao.gif');return false;">Incluir</a>

</div>
	



	
	
