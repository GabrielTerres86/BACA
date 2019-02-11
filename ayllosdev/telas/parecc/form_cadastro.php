<?php
/*!
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Luis Fernando (Supero)
 * DATA CRIAÇÃO : 28/01/2019
 * OBJETIVO     : Formulario com os parametros
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<br/>
<form id="frmCadsoa" name="frmCadsoa" class="formulario">

	<a href="#" style="text-decoration: underline;" id="btSelecioneDisponiveis"><? echo utf8ToHtml('Selecionar todos'); ?></a>
	<a href="#" style="text-decoration: underline;" id="btSelecioneAderidos"><? echo utf8ToHtml('Selecionar todos'); ?></a>
	<label for="dsservico"> <? echo utf8ToHtml('Não podem enviar'); ?></label>
	<label for="dsaderido"> <? echo utf8ToHtml('Podem enviar'); ?> </label>
    <br/><br/>
	<select id= "dsservico" name="dsservico" multiple>
	</select>	
	<a href="#" id="btLeft" class="botao">&#9668;</a>
	<a href="#" id="btRigth" class="botao">&#9658;</a>
	
	<select id= "dsaderido" name="dsaderido" multiple>
	</select>	
	<br/>
	<br/>
	
	<a href="#" id="btVoltar" class="botao">Voltar</a>
	<a href="#" id="btSalvar" class="botao">Salvar</a>

</form>