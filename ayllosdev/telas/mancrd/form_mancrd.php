<?php
/*
   FONTE        : form_mancrd.php
   CRIAÇÃO      : Kelvin Souza Ott
   DATA CRIAÇÃO : 28/06/2017
   OBJETIVO     : Tela de exibicao detalhamento de cartoes
   --------------
   ALTERAÇÕES   :
 */		
 
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	

isPostMethod();	

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : "";
$nrcrcard = (isset($_POST['nrcrcard'])) ? $_POST['nrcrcard'] : 0;
$nrcctitg = (isset($_POST['nrcctitg'])) ? $_POST['nrcctitg'] : 0;
$cdadmcrd = (isset($_POST['cdadmcrd'])) ? $_POST['cdadmcrd'] : 0;
$nrcpftit = (isset($_POST['nrcpftit'])) ? $_POST['nrcpftit'] : 0;
$nmtitcrd = (isset($_POST['nmtitcrd'])) ? $_POST['nmtitcrd'] : "";
$listadm = (isset($_POST['listadm'])) ? $_POST['listadm'] : "";
$flgdebit = (isset($_POST['flgdebit'])) ? $_POST['flgdebit'] : 0;

?>

<div id="divForm" style="display: inline-block">
	<form id="frmDetalheCartao" name="frmDetalheCartao" class="formulario" >
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta; ?>"/>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl; ?>"/>
		<label for="nrcrcard">Cartao:</label>
		<input type="text" id="nrcrcard" name="nrcrcard" value="<?php echo $nrcrcard; ?>"/>
		<label for="nrcctitg">Conta Cartao:</label>
		<input type="text" id="nrcctitg" name="nrcctitg" value="<?php echo $nrcctitg; ?>" maxlength="25"/>	
		<label for="dsadmcrd">Administradora:</label>	
		<select name="dsadmcrd" id="dsadmcrd" class="campo">
			<option value="0"></option>	
			<?php 
			$listadm1 = explode('|',$listadm);
			
			foreach($listadm1 as $valor){ 
				$listadm2 = explode(';',$valor);?>				
				<option value="<?php echo $listadm2[0] ?>" <? if ($listadm2[0] == $cdadmcrd) { echo " selected"; } ?>><? echo $listadm2[1]; ?></option>				
			<?php } ?>                 
		
		</select>	
		<label for="nrcpftit">CPF:</label>
		<input type="text" id="nrcpftit" name="nrcpftit" value="<?php echo $nrcpftit; ?>" maxlength="25"/>
		<label for="nmtitcrd">Nome Plastico:</label>
		<input type="text" id="nmtitcrd" name="nmtitcrd" value="<?php echo $nmtitcrd; ?> " maxlength="40"/>	
		<label for="flgdebit">Funcao Debito:</label>
		<input type="checkbox" name="flgdebit" style="margin-top:7px !important" <?php if ($flgdebit == 1) { echo "checked "; } ?> />		
	</form>
</div>
<br/>	
<div id="divBotoesDetalhe" style="padding-bottom:10px; ">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;" >Voltar</a>
	<a href="#" class="botao" id="btConfirmar" onClick="confirmaAtualizaCartao();">Confirmar</a>
</div>