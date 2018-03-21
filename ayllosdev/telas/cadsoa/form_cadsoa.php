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

	<label for="vlmincapi"> <? echo utf8ToHtml('Valor M&iacute;nimo de Capital:'); ?></label>
	<input type="text" id="vlmincapi" name="vlmincapi" alt="p6p3c2D">
	
	<label for="tpServico" id= "servico"> Tipo de Servi&ccedil;o:</label>
	
	<input name="tpServico" id="tpObrigatorio" type="radio" class="radio" value="1" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>	
	<label for="tpObrigatorio" class="radio">Essencial</label>
	
	<input name="tpServico" id="tpOpcional" type="radio" class="radio" value="2" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>	
	<label for="tpOpcional" class="radio">Adicional</label>	
	
	<label for="dsservico"> <? echo utf8ToHtml('Produtos Disponíveis'); ?></label>
	<label for="dsaderido"> <? echo utf8ToHtml('Produtos Aderidos'); ?> </label>
    <br/><br/>
	<select id= "dsservico" name="dsservico" multiple>
	</select>	
	<a href="#" id="btLeft" class="botao">&#9668;</a>
	<a href="#" id="btRigth" class="botao">&#9658;</a>
	
	<select id= "dsaderido" name="dsaderido" multiple>
	</select>	
	<a href="#" id="btAcima" class="botao">&#9650;</a>
	<a href="#" id="btAbaixo" class="botao">&#9660;</a>
	<br/>
	<br/>
	
	<label for="vlrminimo"> <? echo utf8ToHtml('Valor M&iacute;nimo:'); ?></label>
	<input type="text" id="vlrminimo" name="vlrminimo">
	
	<label for="vlrmaximo"> <? echo utf8ToHtml('Valor M&aacute;ximo:'); ?></label>
	<input type="text" id="vlrmaximo" name="vlrmaximo">
	<br/>
	<a href="#" id="btGravar" class="botao">Gravar</a>
	<a href="#" id="btnExcluir" class="botao">Excluir</a>

</form>


