<?php
	/*
 * FONTE        : form_contratos.php
 * CRIAÇÃO      : Daniel Zimmermann
	* DATA CRIACAO : 17/08/2015
 * OBJETIVO     : Tela do formulario de Boletos Emprestimos
	* ALTERACOES	: 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmContratos" name="frmContratos" class="formulario" onSubmit="return false;" >

    <label for="nrdconta">Conta/DV:</label>
    <input type="text" id="nrdconta" name="nrdconta" class="conta" />	
    <input type="hidden" id="cdagenci" name="cdagenci" />	
    <a href="#" onclick="pesquisaAssociados(); return false;" ><img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
    <input type="text" name="nmprimtl" id="nmprimtl" readonly />
    <br style="clear:both" />

</form>

<div id="divTabfrmContratos" name="divTabfrmContratos" style="display:none; margin-top:15px;"></div>	

<div id="divBotoesfrmContratos" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btGerarBoleto" onClick="validaGerarBoleto(); return false;">Gerar Boleto</a>
    <a href="#" class="botao" id="btCobrança" onClick="chamaRotinaManutencao();return false;">Cobran&ccedil;a</a>
    <a href="#" class="botao" id="btTelefones" onClick="consultarTelefone(1, 10);return false;"  style="margin-left: 30px;">Telefones</a>
    <a href="#" class="botao" id="btEmails"  	 onClick="consultarEmail(1, 10);return false;">E-mails</a>
</div>