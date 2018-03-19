<?
/* !
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 16/03/2018
 * OBJETIVO     : Form da opcao C da tela CADPCP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 */
	
session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');		
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();		

include('form_cabecalho.php');
?>
<form id="frmOpcao" class="formulario">
    <fieldset>
    	<legend>Conta</legend>
    	
		<label for="nrdconta">Conta:</label>		
		<input id="nrdconta" name="nrdconta" type="text"/>
		<a href="#" style="padding: 3px 0 0 3px;" id="btLupaConta">
			<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
		</a>
		<a href="#" class="botao" id="btnOK1" name="btnOK1" style = "text-align:right;">OK</a>	
		<label for="nmprimtl">Titular:</label>		
		<input id="nmprimtl" name="nmprimtl" type="text"/>
	</fieldset>
	<div id="divPagador">
		<fieldset>
			<legend>Pagador</legend>

	        <label for="nrinssac">CPF/CNPJ:</label>
	        <input type="text" id="nrinssac" name="nrinssac" value="<?php echo $nrinssac ?>"/>

			<a href="#" style="padding: 3px 0 0 3px;" id="btLupaPagador">
				<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
			</a>

	        <label for="nmdsacad">Nome Pagador:</label>
	        <input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo $nmdsacad ?>" />

	        <div id="divPorcentagem">
		        <label for="vlpercen">Porcentagem:</label>
		        <input type="text" id="vlpercen" name="vlpercen" value="<?php echo $vlpercen ?>" />
	        </div>
		</fieldset>
	</div>
</form>
<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();return false;" >Prosseguir</a>
</div>