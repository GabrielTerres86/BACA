<?

/**
* FONTE        : form_cabecalho.php
* CRIAÇÃO      : Otto - RKAM
* DATA CRIAÇÃO : 17/11/2015
* OBJETIVO     : Mostrar tela LDESCO
* --------------
* ALTERAÇÕES   :
* --------------
*/


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
isPostMethod();

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho">


	<label for="cdopcao"><? echo utf8ToHtml("Op&ccedil;&atilde;o:"); ?></label>
	<select id="cdopcao" name="cdopcao" alt="Informe a opcao desejada (A, B, L, C, E ou I)"">
		<option value="A"><? echo utf8ToHtml("A - Alterar linha de descontos.") ?></option>
		<option value="B"><? echo utf8ToHtml("B - Bloquear linha de descontos.") ?></option>
		<option value="C" selected="true"><? echo utf8ToHtml("C - Consultar linha de descontos.") ?></option>
		<option value="L"><? echo utf8ToHtml("L - Liberar linha de descontos bloqueada.") ?></option>
		<option value="E"><? echo utf8ToHtml("E - Excluir linha de descontos.") ?></option>
		<option value="I"><? echo utf8ToHtml("I - Incluir linha de descontos.") ?></option>
	</select>

	<a href="#" class="botao" id="btnOK" >OK</a>
	<br style="clear:both" />	
	<div id="divCab" style="display:none"></div>
    
</form>
