<?
/*!
 * FONTE        : form_debito.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 07/06/2011 
 * OBJETIVO     : Tela de seleção do Identificador
 * --------------
 * ALTERAÇÕES   :
 * 001: [30/11/2012] David (CECRED) : Não utilizar session
 * 001: [21/01/2013] Daniel (CECRED): Implantacao novo layout.
 */		
?>

	<form name="frmCadgpsDebito" id="frmCadgpsDebito" class="formulario" onSubmit="return false;">										

	<label for="flgdbaut"><? echo utf8ToHtml('Débito Autorizado:') ?></label>
	<select id="flgdbaut" name="flgdbaut" >
	<option value=""></option>
	<option value="yes" <? echo getByTagName($registro,'flgdbaut') == 'yes' ? 'selected' : '' ?> >Sim</option>
	<option value="no"  <? echo getByTagName($registro,'flgdbaut') == 'no' ? 'selected' : '' ?> >Nao</option>
	</select>	
	<a href="#" class="botao">OK</a>

	<label for="inpessoa"><? echo utf8ToHtml('Tp. natureza guia:') ?></label>
	<select id="inpessoa" name="inpessoa" >
	<option value=""></option>
	<option value="1" <? echo getByTagName($registro,'inpessoa') == '1' ? 'selected' : '' ?> >1-Fisica</option>
	<option value="2" <? echo getByTagName($registro,'inpessoa') == '2' ? 'selected' : '' ?> >2-Juridica</option>
	</select>	

	<br />

	<label for="nrctadeb"><? echo utf8ToHtml('Conta/dv para débito:') ?></label>
	<input name="nrctadeb" id="nrctadeb" type="text" value="<? echo getByTagName($registro,'nrctadeb')?>" />		
	<a style="margin-top:5px" href="#" onClick="controlaPesquisas(5);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	
	<label for="nmctadeb"><? echo utf8ToHtml('Títular:') ?></label>
	<input name="nmctadeb" id="nmctadeb" type="text" value="<? echo getByTagName($registro,'nmctadeb')?>" />		
	
	<br />	
	
	<label for="vlrdinss"><? echo utf8ToHtml('Valor INSS:') ?></label>
	<input name="vlrdinss" id="vlrdinss" type="text" value="<? echo getByTagName($registro,'vlrdinss')?>" />		
	
	<br />	
	
	<label for="vloutent"><? echo utf8ToHtml('Valor outras entidades:') ?></label>
	<input name="vloutent" id="vloutent" type="text" value="<? echo getByTagName($registro,'vloutent')?>" />		

	<br />		

	<label for="vlrjuros"><? echo utf8ToHtml('Valor ATM/Juros/Multa:') ?></label>
	<input name="vlrjuros" id="vlrjuros" type="text" value="<? echo getByTagName($registro,'vlrjuros')?>" />		
	
	<br />	
	
	<label for="vlrtotal"><? echo utf8ToHtml('Valor total:') ?></label>
	<input name="vlrtotal" id="vlrtotal" type="text" value="<? echo getByTagName($registro,'vlrtotal')?>" />		

	<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar">Concluir</a>
	</div>
	
	</form>
	
<script>
	highlightObjFocus( $('#frmCadgpsDebito') );
	$('#flgdbaut','#frmCadgpsDebito').focus();
	controlafrmCadgpsDebito();
	
</script>	
	