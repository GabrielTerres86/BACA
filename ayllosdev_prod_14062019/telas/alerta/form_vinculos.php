<?
/************************************************************************************
  Fonte        : form_vinculos.php
  Criação      : Adriano
  Data criação : Março/2013
  Objetivo     : Form da opção "Vinculos" da tela ALERTA.
  --------------
  Aalterações  :
  --------------
 ************************************************************************************/ 
?>

<form id="frmVinculos" name="frmVinculos" class="formulario" style="display:none;">	
		
	<fieldset id="fsetVinculos" name="fsetVinculos" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> <? echo utf8ToHtml('V&iacute;nculos'); ?> </legend>
		
		<label for="nrcpfcgc"><? echo utf8ToHtml('Digite o n&uacute;mero do CPF/CNPJ:') ?></label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
		
		
		<br />
		<br />
			
	</fieldset>
	
	
</form>

<div id="divBotoesVinculos" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">

	<a href="#" class="botao" id="btVoltar"  onclick="estadoInicial();return false;">Voltar</a>
	<a href="#" class="botao" id="btConsultar"  onclick="consultaVinculo('C',$('#nrcpfcgc','#frmVinculos').val(),1,30);return false;">Consultar</a>
	
</div>

