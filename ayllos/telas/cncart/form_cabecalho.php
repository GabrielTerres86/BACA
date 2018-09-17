<?
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : Setembro/2011
 * OBJETIVO     : Cabeçalho para a tela CNCART
 * --------------
 * ALTERAÇÕES   : 17/12/2012 - Ajuste para layout padrao (Daniel).
 *				  10/05/2016 - Adicionado opcao para consultar pela conta ITG conforme solicitado no		
 *							   chamado 445575. (Kelvin)				
 * --------------
 */ 
?>

<form id="frmCabCncart" name="frmCabCncart" class="formulario cabecalho" style="display:none">	
	
	<label for="tppesq">Procurar Por:</label>
	<input type="radio" name="tppesq" id="nrcrcard" value="1" /> <label for="nrcrcard"> N&uacute;mero do Cart&atilde;o </label>
	<input type="radio" name="tppesq" id="nmprimtl" value="2" /> <label for="nmprimtl"> Nome do Titular </label>
	<input type="radio" name="tppesq" id="nmtitcrd" value="3" /> <label for="nmtitcrd"> Nome do Pl&aacute;stico </label>
	<input type="radio" name="tppesq" id="nrdctitg" value="4" /> <label for="nrdctitg"> Conta ITG </label>

	<br style="clear:both" />	
	
	<label for="dscartao" id="ttpesq">N&uacute;mero do Cart&atilde;o:</label>
	<input type="text" id="dscartao" name="dscartao" alt="Informe o n&uacute;mero do cart&atilde;o"/>
	<a href="#" class="botao" id="btOK" onClick="carrega_dados(1,30,0); return false;" >OK</a>
	
	<br style="clear:both" />	
	
</form>
