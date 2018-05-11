<?php
/*!
 * FONTE        : form_consulta.php				Última alteração:
 * CRIAÇÃO      : Antonio R. Junior (mouts)
 * DATA CRIAÇÃO : 18/11/2017
 * OBJETIVO     : Filtros de consulta da tela PRVSAQ
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

<form id="frmFiltro" name="frmFiltro" class="formulario">
	<div id="divFiltro" style="display:none">				
		<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px; width:850px;">
			<div id="divFiltroConsulta" style="display:none">
				<label for="dtPeriodoIni" id="lbDtPeriodoIni"><? echo utf8ToHtml('Período:') ?></label>
				<input id="dtPeriodoIni" name="dtPeriodoIni" type="text" class="campo data" value="<? echo utf8ToHtml($dtperiodoini); ?>"/>	
				<label for="dtPeriodoFim" id="lbDtPeriodoFim"><? echo utf8ToHtml('a') ?></label>
				<input id="dtPeriodoFim" name="dtPeriodoFim" type="text" class="campo data" value="<? echo utf8ToHtml($dtperiodofim); ?>"/>						

				<br style="clear:both" />

				<label for="nrPA" id="lbNrPA"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPA" name="nrPA" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>

				<label for="tpSituacao" id="lbTpsituacao"><? echo utf8ToHtml('Situação:') ?></label>
				<select id="tpSituacao" name="tpSituacao" class="campo" style="width: 90px;">
					<option value="0"><? echo utf8ToHtml('Todos') ?></option>
					<option value="1" selected><? echo utf8ToHtml('Pendente') ?></option>
					<option value="2"><? echo utf8ToHtml('Realizada') ?></option>
					<option value="3"><? echo utf8ToHtml('Cancelada') ?></option>
				</select>

				<label for="tpOrigem" id="lbTpOrigem"><? echo utf8ToHtml('Origem:') ?></label>
				<select id="tpOrigem" name="tpOrigem" class="campo" style="width: 100px;">
					<option value="0"><? echo utf8ToHtml('Todos') ?></option>
					<option value="5" selected><? echo utf8ToHtml('Presencial') ?></option>
					<option value="3"><? echo utf8ToHtml('Conta Online') ?></option>
					<!--<option value="14"><? echo utf8ToHtml('Site') ?></option>-->
				</select>
			</div>
			<div id="divFiltroExclusao" style="display:none">
				<label for="dtDataExc" id="lbDtDataExc"><? echo utf8ToHtml('Data:') ?></label>
				<input id="dtDataExc" name="dtDataExc" type="text" class="campo data" value="<? echo utf8ToHtml($dtDataExc); ?>"/>
				<label for="nrPAExc" id="lbNrPAExc"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPAExc" name="nrPAExc" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>
				<label for="nrCpfCnpjExc" id="lbNrCpfCnpjExc" class="lbSolic"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
				<input id="nrCpfCnpjExc" name="nrCpfCnpjExc" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrCpfCnpj); ?>"/>
			</div>
			<div id="divFiltroAlt" style="display:none">
				<label for="dsProtAlt" id="lbDsProtAlt"><? echo utf8ToHtml('Protocolo:') ?></label>
				<input id="dsProtAlt" name="dsProtAlt" type="text" style = "width:200px" class="campo" value="<? echo utf8ToHtml($dtDataAlt); ?>"/>
				<label for="dtDataAlt" id="lbDtDataAlt"><? echo utf8ToHtml('Data:') ?></label>
				<input id="dtDataAlt" name="dtDataAlt" type="text" class="campo data" value="<? echo utf8ToHtml($dtDataAlt); ?>"/>
				<label for="nrPAAlt" id="lbNrPAAlt"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPAAlt" name="nrPAAlt" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>
				<label for="nrCpfCnpjAlt" id="lbNrCpfCnpjAlt" class="lbSolic"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
				<input id="nrCpfCnpjAlt" name="nrCpfCnpjAlt" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrCpfCnpj); ?>"/>
			</div>
		</fieldset>
	</div>
</form>