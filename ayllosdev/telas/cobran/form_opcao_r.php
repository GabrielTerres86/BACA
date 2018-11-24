<? 
/*!
 * FONTE        : form_opcao_r.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 29/02/2012 
 * OBJETIVO     : Formulario que apresenta o relatorio da opcao R da tela COBRAN
 * --------------
 * ALTERAÇÕES   : 14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *
 *			      30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)		
 * 
 *                17/01/2016 - Alterado para incluir campo Status SMS. PRJ319 - SMS Cobrança (Odirlei-AMcom) 
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" id="cddopcao" name="cddopcao" value=""/>
    <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>"/>

	<fieldset>
		<legend> <? echo utf8ToHtml('Relatório');  ?> </legend>	
		
		<label for="flgregis">Cob.Regis:</label>
		<select id="flgregis" name="flgregis" onchange="tipoOptionR();">
		<option value="yes"<?php echo $flgregis == 'yes' ? 'selected' : '' ?> ><? echo utf8ToHtml('Sim') ?></option>
		<option value="no" <?php echo $flgregis == 'no'  ? 'selected' : '' ?> ><? echo utf8ToHtml('Não') ?></option>
		</select>

		<label for="tprelato"><? echo utf8ToHtml('Relatório:');  ?></label>
		<select id="tprelato" name="tprelato">
		</select>

	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Filtro');  ?> </legend>	
		
		<label for="inidtmvt"><? echo utf8ToHtml('Período');  ?>:</label>
		<input type="text" id="inidtmvt" name="inidtmvt" value="<?php echo $inidtmvt ?>"/>

		<label for="fimdtmvt"><? echo utf8ToHtml('Até:');  ?></label>
		<input type="text" id="fimdtmvt" name="fimdtmvt" value="<?php echo $fimdtmvt ?>" />

		<label for="cdstatus"><? echo utf8ToHtml('Status:');  ?></label>
		<select id="cdstatus" name="cdstatus">
		<option value="1"><? echo utf8ToHtml('1-Em Aberto');  	?></option>
		<option value="2"><? echo utf8ToHtml('2-Baixado');  	?></option>
		<option value="3"><? echo utf8ToHtml('3-Liquidado');  	?></option>
		<option value="4"><? echo utf8ToHtml('4-Rejeitado');  	?></option>
		<option value="5"><? echo utf8ToHtml('5-Cartorária'); 	?></option>
		</select>
		
		<div id="divInserasa" style="display:none">
			<label for="inserasa"><? echo utf8ToHtml('Situação Serasa:');  ?></label>
			<select id="inserasa" name="inserasa">
			<option value=""><? echo utf8ToHtml('Todos');  	    ?></option>
			<option value="2"><? echo utf8ToHtml('Não Negativado'); ?></option>
			<option value="3"><? echo utf8ToHtml('Sol. Enviadas');  ?></option>
			<option value="4"><? echo utf8ToHtml('Sol. Cancel. Enviadas');  	?></option>
			<option value="5"><? echo utf8ToHtml('Negativados');  	?></option>
			<option value="6"><? echo utf8ToHtml('Sol. Com Erros'); ?></option>
			<option value="7"><? echo utf8ToHtml('Ação Judicial'); ?></option>
			</select>
		</div>
		
        <div id="divStatusSMS" style="display:none">
			<label for="inStatusSMS"><? echo utf8ToHtml('Situação SMS:');  ?></label>
			<select id="inStatusSMS" name="inStatusSMS">
			<option value="0"><? echo utf8ToHtml('Todos');  	    ?></option>			
			<option value="4"><? echo utf8ToHtml('Enviados com Sucesso');  ?></option>
			<option value="3"><? echo utf8ToHtml('Não Enviados');  	?></option>
			<option value="5"><? echo utf8ToHtml('Agendados'); ?></option>
			</select>
		</div>
		
		<br style="clear:both" />

		<label for="nrdconta"><? echo utf8ToHtml('Conta:');  ?></label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdcont2 ?>" />
		<a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
          <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" />
        </a>

		<label for="cdagenci"><? echo utf8ToHtml('PA:');  ?></label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>" />

		

		<label for="nmprimtl"><? echo utf8ToHtml('Titular:');  ?></label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
		
	</fieldset>		
	
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
	<a href="#" style="display:none" class="botao" id="btGeraCSV" onclick="Gera_CSV(); return false;" >Exportar para CSV</a>
</div>


