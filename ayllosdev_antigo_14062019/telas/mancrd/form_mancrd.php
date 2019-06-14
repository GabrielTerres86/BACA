<?php
/*
   FONTE        : form_mancrd.php
   CRIAÇÃO      : Kelvin Souza Ott
   DATA CRIAÇÃO : 28/06/2017
   OBJETIVO     : Tela de exibicao detalhamento de cartoes
   --------------
   ALTERAÇÕES   : 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
   				  24/07/2018 - Adicionado situacao ESTUDO no select de Situacao (Mateus Z / Mouts - PRB0040198)
				 
				  25/07/2018 - Adicionado campo insitdec na tela. PRJ345(Lombardi).
				  
				  31/07/2018 - Ajustado select insitcrd com as devidas situações. (Reinert)
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
$insitcrd = (isset($_POST['insitcrd'])) ? $_POST['insitcrd'] : 0;
$dtsol2vi = (isset($_POST['dtsol2vi'])) ? $_POST['dtsol2vi'] : "";
$flgprcrd = (isset($_POST['flgprcrd'])) ? $_POST['flgprcrd'] : 0;
$insitdec = (isset($_POST['insitdec'])) ? $_POST['insitdec'] : 0;
$flgdebit = (isset($_POST['flgdebit'])) ? $_POST['flgdebit'] : 0;
$nrctrcrd = (isset($_POST['nrctrcrd'])) ? $_POST['nrctrcrd'] : 0;
$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;
$nmempres = (isset($_POST['nmempres'])) ? $_POST['nmempres'] : "";

?>

<div id="divForm" style="display: inline-block">
	<form id="frmDetalheCartao" name="frmDetalheCartao" class="formulario" >
	    <input type="hidden" id="nrctrcrd" name="nrctrcrd" value="<?php echo $nrctrcrd; ?>"/>
		<input type="hidden" id="inpessoa" name="inpessoa" value="<?php echo $inpessoa; ?>"/>
		
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
		<label for="nmempres">Emp. do Plastico:</label>
		<input type="text" id="nmempres" name="nmempres" value="<?php echo $nmempres; ?> " maxlength="40"/>
		<label for="insitcrd">Situacao:</label>	
		<select name="" id="insitcrd" class="campo">										
			<option value='0' <? if($insitcrd == 0){echo " selected";} ?>>ESTUDO</option>										
			<option value='1' <? if($insitcrd == 1){echo " selected";} ?>>APROVADO</option>
			<option value='2' <? if($insitcrd == 2){echo " selected";} ?>>SOLICITADO</option>
			<option value='3' <? if($insitcrd == 3){echo " selected";} ?>>LIBERADO</option>
			<option value='4' <? if($insitcrd == 4){echo " selected";} ?>>EM USO</option>
			<option value='5' <? if($insitcrd == 5){echo " selected";} ?>>BLOQUEADO</option>
			<option value='6' <? if($insitcrd == 6){echo " selected";} ?>>CANCELADO</option>
			<option value='7' <? if(($insitcrd == 7) || ($insitcrd == 4 && $dtsol2vi != "")){echo " selected";} ?>>SOL.2V</option>
			<option value='9' <? if($insitcrd == 9){echo " selected";} ?>>ENVIADO BANCOOB</option>
		</select>		
		<label for="flgdebit">Funcao Debito:</label>
		<input type="checkbox" name="flgdebit" style="margin-top:7px !important" <?php if ($flgdebit == 1) { echo "checked "; } ?> />		
		<label for="flgprcrd">Titular:</label>
		<input type="checkbox" name="flgprcrd" style="margin-top:7px !important" <?php if ($flgprcrd == 1) { echo "checked "; } ?> />		
		<label for="insitdec">Sit. Decisao:</label>	
		<select name="" id="insitdec" class="campo">										
			<option value='1' <? if($insitdec == 1){echo " selected";} ?>>SEM APROVACAO</option>
			<option value='2' <? if($insitdec == 2){echo " selected";} ?>>APROVADA AUTO</option>
			<option value='3' <? if($insitdec == 3){echo " selected";} ?>>APROVADA MANUAL</option>
			<option value='4' <? if($insitdec == 4){echo " selected";} ?>>ERRO</option>
			<option value='5' <? if($insitdec == 5){echo " selected";} ?>>REJEITADA</option>
			<option value='6' <? if($insitdec == 6){echo " selected";} ?>>REFAZER</option>
			<option value='7' <? if($insitdec == 7){echo " selected";} ?>>EXPIRADA</option>
			<option value='8' <? if($insitdec == 8){echo " selected";} ?>>EFETIVADA</option>
		</select>		
	</form>
</div>
<br/>	
<div id="divBotoesDetalhe" style="padding-bottom:10px; ">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;" >Voltar</a>
	<a href="#" class="botao" id="btConfirmar" onClick="confirmaAtualizaCartao();">Confirmar</a>
</div>