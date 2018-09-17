<?php
/*!
 * FONTE        : form_consulta.php				Última alteração:
 * CRIAÇÃO      : Antonio R. Junior (mouts)
 * DATA CRIAÇÃO : 18/11/2017
 * OBJETIVO     : Filtros de consulta da tela PRVSAQ
 * --------------
 * ALTERAÇÕES   : 29/05/2018 - Incluido novos campos PRJ 420 - Mateus Z (Mouts).
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
		<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px; width:950px;">
			<div id="divFiltroConsulta" style="display:none">

				<label for="dtPeriodoIni" id="lbDtPeriodoIni"><? echo utf8ToHtml('Data do Saque:') ?></label>
				<input id="dtPeriodoIni" name="dtPeriodoIni" type="text" class="campo data" value="<? echo utf8ToHtml($dtperiodoini); ?>"/>	
				<label for="dtPeriodoFim" id="lbDtPeriodoFim"><? echo utf8ToHtml('a') ?></label>
				<input id="dtPeriodoFim" name="dtPeriodoFim" type="text" class="campo data" value="<? echo utf8ToHtml($dtperiodofim); ?>"/>

				<label for="vlSaqPagto" id="lbVlSaqPagto"><? echo utf8ToHtml('Valor:') ?></label>
				<input id="vlSaqPagto" name="vlSaqPagto" type="text" class="campo" value="<? echo utf8ToHtml($vlSaqPagto); ?>"/>

				<br style="clear:both" />

				<label for="nrPA" id="lbNrPA"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPA" name="nrPA" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>

				<label for="tpSituacao" id="lbTpsituacao"><? echo utf8ToHtml('Situação:') ?></label>
				<select id="tpSituacao" name="tpSituacao" class="campo" style="width: 90px;">
					<option value="0" selected><? echo utf8ToHtml('Todos') ?></option>
					<option value="1"><? echo utf8ToHtml('Pendente') ?></option>
					<option value="2"><? echo utf8ToHtml('Realizada') ?></option>
					<option value="3"><? echo utf8ToHtml('Cancelada') ?></option>
				</select>

				<label for="tpOrigem" id="lbTpOrigem"><? echo utf8ToHtml('Origem:') ?></label>
				<select id="tpOrigem" name="tpOrigem" class="campo" style="width: 100px;">
					<option value="0" selected><? echo utf8ToHtml('Todos') ?></option>
					<option value="5"><? echo utf8ToHtml('Presencial') ?></option>
					<option value="3"><? echo utf8ToHtml('Conta Online') ?></option>
					<!--<option value="14"><? echo utf8ToHtml('Site') ?></option>-->
				</select>

				<br style="clear:both" />

				<label for="nrPAConta" id="lbNrPAConta"><? echo utf8ToHtml('PA da conta:') ?></label>
				<input id="nrPAConta" name="nrPAConta" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPAConta); ?>"/>

				<label for="nrdconta" id="lbNrdconta"><? echo utf8ToHtml('Conta do titular:') ?></label>
				<input id="nrdconta" name="nrdconta" type="text" class="campo conta" value="<? echo utf8ToHtml($nrdconta); ?>"/>

				<label for="nrcpf_sacador" id="lbNrcpf_sacador"><? echo utf8ToHtml('CPF do sacador:') ?></label>
				<input id="nrcpf_sacador" name="nrcpf_sacador" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrcpf_sacador); ?>"/>

			</div>
			<div id="divFiltroExclusao" style="display:none">
				
				<label for="dtDataExc" id="lbDtDataExc"><? echo utf8ToHtml('Data do saque:') ?></label>
				<input id="dtDataExc" name="dtDataExc" type="text" class="campo data" value="<? echo utf8ToHtml($dtDataExc); ?>"/>
				
				<label for="nrPAExc" id="lbNrPAExc"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPAExc" name="nrPAExc" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>

				<label for="nrcpf_sacadorExc" id="lbNrcpf_sacadorExc"><? echo utf8ToHtml('CPF do sacador:') ?></label>
				<input id="nrcpf_sacadorExc" name="nrcpf_sacadorExc" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrcpf_sacador); ?>"/>

				<label for="vlSaqPagtoExc" id="lbVlSaqPagtoExc"><? echo utf8ToHtml('Valor:') ?></label>
				<input id="vlSaqPagtoExc" name="vlSaqPagtoExc" type="text" class="campo" value="<? echo utf8ToHtml($vlSaqPagtoExc); ?>"/>

				<br style="clear:both" />

				<label for="tpOrigemExc" id="lbTpOrigemExc"><? echo utf8ToHtml('Origem:') ?></label>
				<select id="tpOrigemExc" name="tpOrigemExc" class="campo" style="width: 100px;">
					<option value="0" selected><? echo utf8ToHtml('Todos') ?></option>
					<option value="5"><? echo utf8ToHtml('Presencial') ?></option>
					<option value="3"><? echo utf8ToHtml('Conta Online') ?></option>
					<!--<option value="14"><? echo utf8ToHtml('Site') ?></option>-->
				</select>

				<label for="nrPAContaExc" id="lbNrPAContaExc"><? echo utf8ToHtml('PA da conta:') ?></label>
				<input id="nrPAContaExc" name="nrPAContaExc" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPAConta); ?>"/>
				
				<label for="nrCpfCnpjExc" id="lbNrCpfCnpjExc" class="lbSolic"><? echo utf8ToHtml('CPF/CNPJ do titular:') ?></label>
				<input id="nrCpfCnpjExc" name="nrCpfCnpjExc" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrCpfCnpj); ?>"/>

				<label for="nrdcontaExc" id="lbNrdcontaExc"><? echo utf8ToHtml('Conta do titular:') ?></label>
				<input id="nrdcontaExc" name="nrdcontaExc" type="text" class="campo conta" value="<? echo utf8ToHtml($nrdconta); ?>"/>
			
			</div>
			<div id="divFiltroAlt" style="display:none">

				<label for="dtPeriodoIniAlt" id="lbDtPeriodoIniAlt"><? echo utf8ToHtml('Data do Saque:') ?></label>
				<input id="dtPeriodoIniAlt" name="dtPeriodoIniAlt" type="text" class="campo data" value="<? echo utf8ToHtml($dtPeriodoIniAlt); ?>"/>	
				<label for="dtPeriodoFimAlt" id="lbDtPeriodoFimAlt"><? echo utf8ToHtml('a') ?></label>
				<input id="dtPeriodoFimAlt" name="dtPeriodoFimAlt" type="text" class="campo data" value="<? echo utf8ToHtml($dtPeriodoFimAlt); ?>"/>
				
				<label for="dsProtAlt" id="lbDsProtAlt"><? echo utf8ToHtml('Protocolo:') ?></label>
				<input id="dsProtAlt" name="dsProtAlt" type="text" style = "width:200px" class="campo" value="<? echo utf8ToHtml($dtDataAlt); ?>"/>

				<label for="vlSaqPagtoAlt" id="lbVlSaqPagtoAlt"><? echo utf8ToHtml('Valor:') ?></label>
				<input id="vlSaqPagtoAlt" name="vlSaqPagtoAlt" type="text" class="campo" value="<? echo utf8ToHtml($vlSaqPagtoAlt); ?>"/>

				<br style="clear:both" />
				
				<label for="nrPAAlt" id="lbNrPAAlt"><? echo utf8ToHtml('PA do saque:') ?></label>
				<input id="nrPAAlt" name="nrPAAlt" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>

				<label for="nrcpf_sacadorAlt" id="lbNrcpf_sacadorAlt"><? echo utf8ToHtml('CPF do sacador:') ?></label>
				<input id="nrcpf_sacadorAlt" name="nrcpf_sacadorAlt" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrcpf_sacador); ?>"/>

				<label for="tpOrigemAlt" id="lbTpOrigemAlt"><? echo utf8ToHtml('Origem:') ?></label>
				<select id="tpOrigemAlt" name="tpOrigemAlt" class="campo" style="width: 100px;">
					<option value="0" selected><? echo utf8ToHtml('Todos') ?></option>
					<option value="5"><? echo utf8ToHtml('Presencial') ?></option>
					<option value="3"><? echo utf8ToHtml('Conta Online') ?></option>
					<!--<option value="14"><? echo utf8ToHtml('Site') ?></option>-->
				</select>

				<br style="clear:both" />

				<label for="nrPAContaAlt" id="lbNrPAContaAlt"><? echo utf8ToHtml('PA da conta:') ?></label>
				<input id="nrPAContaAlt" name="nrPAContaAlt" type="text" class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPAConta); ?>"/>
				
				<label for="nrCpfCnpjAlt" id="lbNrCpfCnpjAlt" class="lbSolic"><? echo utf8ToHtml('CPF/CNPJ do titular:') ?></label>
				<input id="nrCpfCnpjAlt" name="nrCpfCnpjAlt" type="text" class="campo inteiro" value="<? echo utf8ToHtml($nrCpfCnpj); ?>"/>

				<label for="nrdcontaAlt" id="lbNrdcontaAlt"><? echo utf8ToHtml('Conta do titular:') ?></label>
				<input id="nrdcontaAlt" name="nrdcontaAlt" type="text" class="campo conta" value="<? echo utf8ToHtml($nrdconta); ?>"/>
			
			</div>
		</fieldset>
	</div>
</form>