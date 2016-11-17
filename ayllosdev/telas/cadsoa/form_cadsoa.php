<?
/* * *********************************************************************

  Fonte: form_cadsoa.php
  Autor: Tiago Castro - RKAM
  Data : Jul/2015                       Última Alteração: 

  Objetivo  : Mostrar valores da CADSOA.

  Alterações: 
  

 * ********************************************************************* */
?>
<form id="frmCadsoa" name="frmCadsoa" class="formulario">

	<label for="dsservico"> <? echo utf8ToHtml('Serviços Disponíveis'); ?></label>
	<label for="dsaderido"> <? echo utf8ToHtml('Serviços Aderidos'); ?> </label>
    <br/><br/>
	<select id= "dsservico" name="dsservico" multiple>
	</select>	
	<a href="#" id="btLeft" class="botao">&#9668;</a>
	<a href="#" id="btRigth" class="botao">&#9658;</a>
	
	<select id= "dsaderido" name="dsaderido" multiple>
	</select>	
	<br/>
	<a href="#" id="btGravar" class="botao">Gravar</a>
	<a href="#" id="btAcima" class="botao">&#9650;</a>
	<a href="#" id="btAbaixo" class="botao">&#9660;</a>
	<br/>
	

</form>


