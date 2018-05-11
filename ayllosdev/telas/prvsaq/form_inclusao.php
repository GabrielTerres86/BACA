<?php
/*!
 * FONTE        : form_inclusao.php
 * CRIAÇÃO      : Antonio R. Junior (Mouts)
 * DATA CRIAÇÃO : 08/11/2017
 * OBJETIVO     : Tela cadastro PRVSAQ
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

	$regCddregio = (isset($_POST["regCddregio"])) ? $_POST["regCddregio"] : '';
	$regDsdregio = $_POST["regDsdregio"];
	$regCdopereg = $_POST["regCdopereg"];
	$regNmoperad = $_POST["regNmoperad"];
	$regDsdemail = $_POST["regDsdemail"];
?>

<form id="frmInclusao" name="frmInclusao" class="formulario">	
	<div id="divInclusao" style="display:block" >
		<input type="hidden" id="indPessoa"/>
		<input type="hidden" id="dsprotocolo" name="dsprotocolo"/>
		<input type="hidden" id="sidlogin" name="sidlogin" />
		<fieldset>	
			<legend><? echo utf8ToHtml('Dados da provisão') ?></legend>												
		
			<label for="dtSaqPagto"><? echo utf8ToHtml('Data do saque:') ?></label>
			<input id="dtSaqPagto" name="dtSaqPagto" class='campo data' type="text" value="<? echo utf8ToHtml($dtSaqPagto); ?>"/>

			<label for="hrSaqPagto"><? echo utf8ToHtml('Horário saque:') ?></label>
			<input id="hrSaqPagto" name="hrSaqPagto" class = 'campo inteiro' type="time" maxlength="5" value="<? echo utf8ToHtml($hrSaqPagto); ?>"/>
			
			<br style="clear:both" />
							
			<label for="vlSaqPagto"><? echo utf8ToHtml('Valor saque:') ?></label>
			<input id="vlSaqPagto" name="vlSaqPagto" class='campo' type="text" value="<? echo utf8ToHtml($vlSaqPagto); ?>"/>						
			<br style="clear:both" />

			<div id="divCheque" style="display:block">
				<label for="selSaqCheq"><? echo utf8ToHtml('Saque com cheque:') ?></label>
				<select id="selSaqCheq" name="selSaqCheq" class="campo" onchange="liberaDadosCheque(); return false;" style="width: 50px;">
					<option value="1"><? echo utf8ToHtml('Sim') ?></option>
					<option id="optNaoCheq" value="0" selected><? echo utf8ToHtml('Não') ?></option>
				</select>	
				<div id="divDadosCheque" style="display:none">
					<br style="clear:both" />

					<label for="nrBanco"><? echo utf8ToHtml('Banco:') ?></label>
					<input id="nrBanco" name="nrBanco" type="text" disabled="true" class="campo codigo" maxlength="3" value="<? echo utf8ToHtml($nrBanco); ?>"/>	

					<label for="nrAgencia" id="lbNrAgencia"><? echo utf8ToHtml('Agência:') ?></label>
					<input id="nrAgencia" name="nrAgencia" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrAgencia); ?>"/>	

					<br style="clear:both" />

					<label for="nrContCheq"><? echo utf8ToHtml('Conta Cheque:') ?></label>
					<input id="nrContCheq" name="nrContCheq" type="text" class="campo conta" value="<? echo utf8ToHtml($nrContCheq); ?>"/>	

					<label for="nrCheque" id="lbNrCheque"><? echo utf8ToHtml('Número Cheque:') ?></label>
					<input id="nrCheque" name="nrCheque" type="text" class="campo cheque" value="<? echo utf8ToHtml($nrCheque); ?>"/>
				</div>		
			</div>
		</fieldset>

		<fieldset>	
			<legend><? echo utf8ToHtml('Dados Solicitante') ?></legend>												
		
			<label for="nrContTit" id="lbNrContTit" class="lbSolic"><? echo utf8ToHtml('Conta Titular:') ?></label>
			<input id="nrContTit" name="nrContTit" type="text" class="campo conta" value="<? echo utf8ToHtml($nrContTit); ?>"/>

			<label for="nrTit" id="lbNrTit" class="lbSolic"><? echo utf8ToHtml('Titular:') ?></label>
			<input id="nrTit" name="nrTit" type="text" disabled class="campo inteiro" maxlength="4" value="<? echo utf8ToHtml($nrTit); ?>"/>

			<label for="nrCpfCnpj" id="lbNrCpfCnpj" class="lbSolic"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
			<input id="nrCpfCnpj" name="nrCpfCnpj" readonly="true" type="text" class="campo" value="<? echo utf8ToHtml($nrCpfCnpj); ?>"/>
			
			<br style="clear:both" />
							
			<label for="nmSolic" class="lbSolic"><? echo utf8ToHtml('Nome:') ?></label>
			<input id="nmSolic" name="nmSolic" type="text" readonly="true" class="campo alphanum" value="<? echo utf8ToHtml($nmSolic); ?>"/>										
		</fieldset>

		<fieldset>	
			<legend><? echo utf8ToHtml('Dados do Sacador') ?></legend>												

			<label for="nrCpfSacPag"><? echo utf8ToHtml('CPF do sacador:') ?></label>
			<input id="nrCpfSacPag" name="nrCpfSacPag" type="text" maxlength="14" class="campo cpf" value="<? echo utf8ToHtml($nrCpfSacPag); ?>"/>
			
			<br style="clear:both" />
							
			<label for="nmSacPag"><? echo utf8ToHtml('Nome do sacador:') ?></label>
			<input id="nmSacPag" name="nmSacPag" type="text" class="campo alphanum" value="<? echo utf8ToHtml($nmSacPag); ?>"/>										
		</fieldset>

		<fieldset>	
			<legend><? echo utf8ToHtml('Informações gerais') ?></legend>												

			<label for="nrPA" id="lbNrPA"><? echo utf8ToHtml('PA que será realizado o saque:') ?></label>
			<input id="nrPA" name="nrPA" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>
			
			<br style="clear:both" />
							
			<label for="txtFinPagto" id="lbTxtFinPagto"><? echo utf8ToHtml('Finalidade do saque:') ?></label>
			<textarea name="txtFinPagto" id="txtFinPagto" class="campo" style="overflow-y: scroll; overflow-x: hidden; width: 820px; height: 100px; margin-left:10px;margin-right:10px;" ><?php echo trim($txtFinPagto) ?></textarea>			

			<br style="clear:both" />
							
			<label for="txtObs" id="lbTxtObs"><? echo utf8ToHtml('Observações:') ?></label>
			<textarea name="txtObs" id="txtObs" class="campo" style="overflow-y: scroll; overflow-x: hidden; width: 820px; height: 100px;margin-left:10px;margin-right:10px;" ><?php echo trim($txtObs) ?></textarea>			

			<br style="clear:both" />

			<label for="selQuais" id="lbSelQuais"><? echo utf8ToHtml('Foi ofertado outros meios de transações:') ?></label>
			<select id="selQuais" name="selQuais" class="campo" style="width: 50px;" onchange="liberaCampoQuais(); return false;">
				<option value="1"><? echo utf8ToHtml('Sim') ?></option>
				<option value="0" id="optNaoQuais" selected><? echo utf8ToHtml('Não') ?></option>
			</select>

			<br style="clear:both" />
			<div id="divTxtQuais" style="display:none">				
				<label for="txtQuais" id="lbTxtQuais"><? echo utf8ToHtml('Quais:') ?></label>
				<textarea name="txtQuais" id="txtQuais" class="campo" readonly style="overflow-y: scroll; overflow-x: hidden; width: 820px; height: 100px;margin-left:10px;margin-right:10px;" ><?php echo trim($txtQuais) ?></textarea>			
			</div>
		</fieldset>
	</div>
</form>