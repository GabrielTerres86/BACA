<?
/************************************************************************************
  Fonte        : form_liberar.php
  Criação      : Adriano
  Data criação : Fevereiro/2013
  Objetivo     : Form da opção "Liberar" da tela ALERTA.
  --------------
  Alterações   :
                 09/08/2013 - Carlos (Cecred) : Alteração da sigla PAC para PA.
  --------------
 ************************************************************************************/ 
?>

<form id="frmLiberar" name="frmLiberar" class="formulario" style="display:none;">	
		
	<fieldset id="fsetLiberar" name="fsetLiberar" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> <? echo utf8ToHtml('Liberar'); ?> </legend>
			
		<label for="cdcopsol">Cooperativa:</label>
		<select name="cdcopsol" id="cdcopsol" alt="Selecione a Cooperativa">
		</select>
				
		<br />	
		
		<label for="cdagepac">PA Autorizado:</label>
		<input name="cdagepac" id="cdagepac" type="text" />
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="nmresage"></label>
		<input name="nmresage" id="nmresage" type="text"  />
		
		<br />	
		
		<label for="cdopelib">Operador Autorizado:</label>
		<input name="cdopelib" id="cdopelib" type="text" />
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
		<label for="nmoperad"></label>
		<input name="nmoperad" id="nmoperad" type="text"  />
		
		<br />

		<label for="nrdconta">Conta Autorizada:</label>
		<input name="nrdconta" id="nrdconta" type="text" />
				
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
		
		<br />	
		
		<label for="cdoperac">Opera&ccedil;&atilde;o:</label>
		<input name="cdoperac" id="cdoperac" type="text" />
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
		<label for="dsoperac"></label>
		<input name="dsoperac" id="dsoperac" type="text"  />
		
		<br />		
		
		<label for="dsjuslib"><? echo utf8ToHtml('Justificativa de Libera&ccedil;&atilde;o:') ?></label>
		<textarea name="dsjuslib" id="dsjuslib" ></textarea>
		
		
		<br />
		<br />
			
	</fieldset>
	
	
</form>

<div id="divBotoesLiberar" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

	<a href="#" class="botao" id="btVoltar"  onclick="limpaCampos('L');estadoInicial();return false;">Voltar</a>
	<a href="#" class="botao" id="btLiberar"  onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','liberar();','','sim.gif','nao.gif');return false;">Liberar</a>
	
</div>

