<?php
/*****************************************************************
  Fonte        : form_incluir.php						Última Alteração:  
  Criação      : Mateus Zimmermann - Mouts
  Data criação : Junho/2018
  Objetivo     : Mostrar o form para incluir uma nova job
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmIncluir" name="frmIncluir" class="formulario" style="display:none;">

	<fieldset id="fsetIncluir" name="fsetIncluir" style="padding:0px; margin:0px; padding-bottom:10px;">

		<legend><? echo "Dados"; ?></legend>

		<label for="nmjob"><? echo utf8ToHtml('Job:') ?></label>
		<input type="text" id="nmjob" name="nmjob" value="<? echo getByTagName($registros,'nmjob'); ?>" />

		<label for="idativo"><? echo utf8ToHtml('Ativo:') ?></label>
		<select name="idativo" id="idativo" class="campo">
			<option value="S" <? echo getByTagName($registros,'idativo') == 'S' ? 'selected' : ''; ?>>Sim</option>
			<option value="N" <? echo getByTagName($registros,'idativo') == 'N' ? 'selected' : ''; ?>><? echo utf8ToHtml('Não') ?></option>
		</select>
		<br />

		<label for="dsdetalhe"><? echo utf8ToHtml('Descrição detalhada:') ?></label>
		<textarea id="dsdetalhe" name="dsdetalhe"><? echo getByTagName($registros,'dsdetalhe'); ?></textarea>
		<br />

		<label for="dsprefixo_jobs"><? echo utf8ToHtml('Prefixo JOBs:') ?></label>
		<input type="text" id="dsprefixo_jobs" name="dsprefixo_jobs" value="<? echo getByTagName($registros,'dsprefixo_jobs'); ?>" />
		<br />

		<label for="idperiodici_execucao"><? echo utf8ToHtml('Periodicidade Execução:') ?></label>
		<select name="idperiodici_execucao" id="idperiodici_execucao" class="campo">
			<option value="R" <? echo getByTagName($registros,'idperiodici_execucao') == 'R' ? 'selected' : ''; ?>>Recorrente</option>
			<option value="D" <? echo getByTagName($registros,'idperiodici_execucao') == 'D' ? 'selected' : ''; ?>><? echo utf8ToHtml('Diária') ?></option>
			<option value="S" <? echo getByTagName($registros,'idperiodici_execucao') == 'S' ? 'selected' : ''; ?>>Semanal</option>
			<option value="Q" <? echo getByTagName($registros,'idperiodici_execucao') == 'Q' ? 'selected' : ''; ?>>Quinzenal</option>
			<option value="M" <? echo getByTagName($registros,'idperiodici_execucao') == 'M' ? 'selected' : ''; ?>>Mensal</option>
			<option value="T" <? echo getByTagName($registros,'idperiodici_execucao') == 'T' ? 'selected' : ''; ?>>Trimestral</option>
			<option value="E" <? echo getByTagName($registros,'idperiodici_execucao') == 'E' ? 'selected' : ''; ?>>Semestral</option>
			<option value="A" <? echo getByTagName($registros,'idperiodici_execucao') == 'A' ? 'selected' : ''; ?>>Anual</option>
		</select>

		<label for="qtintervalo"><? echo utf8ToHtml('Intervalo:') ?></label>
		<input type="text" id="qtintervalo" name="qtintervalo" value="<? echo getByTagName($registros,'qtintervalo'); ?>" />

		<select name="tpintervalo" id="tpintervalo" class="campo">
			<option value="" <? echo getByTagName($registros,'tpintervalo')  == ''  ? 'selected' : ''; ?>></option>
			<option value="H" <? echo getByTagName($registros,'tpintervalo') == 'H' ? 'selected' : ''; ?>>Horas</option>
			<option value="M" <? echo getByTagName($registros,'tpintervalo') == 'M' ? 'selected' : ''; ?>>Minutos</option>
		</select>
		<br />

		<label for="hrjanela_exec"><? echo utf8ToHtml('Janela de execução:') ?></label>
		<label for="hrjanela_exec_ini"><? echo utf8ToHtml('Início:') ?></label>
		<input type="text" id="hrjanela_exec_ini" name="hrjanela_exec_ini" onchange="validarHora(this)" value="<? echo getByTagName($registros,'hrjanela_exec_ini'); ?>" />
		<label for="hrjanela_exec_fim"><? echo utf8ToHtml('Fim:') ?></label>
		<input type="text" id="hrjanela_exec_fim" name="hrjanela_exec_fim" onchange="validarHora(this)" value="<? echo getByTagName($registros,'hrjanela_exec_fim'); ?>" />
		<br />

		<label for="dsdias_habilitados">Dias Habilitados:</label>
		<label for="dsdias_habilitadosD">D</label>
		<label for="dsdias_habilitadosS">S</label>
		<label for="dsdias_habilitadosT">T</label>
		<label for="dsdias_habilitadosQ">Q</label>
		<label for="dsdias_habilitadosQ">Q</label>
		<label for="dsdias_habilitadosS">S</label>
		<label for="dsdias_habilitadosS">S</label>
		<br />

		<label for="lblCbDiasHabilitados"></label>
		<input id="cb_domingo" type="checkbox"  <? echo $dsdias_habilitados_domingo == '1' ? 'checked' : ''; ?> />
		<input id="cb_segunda" type="checkbox"  <? echo $dsdias_habilitados_segunda == '1' ? 'checked' : ''; ?> />
		<input id="cb_terca" type="checkbox"    <? echo $dsdias_habilitados_terca   == '1' ? 'checked' : ''; ?> />
		<input id="cb_quarta" type="checkbox"   <? echo $dsdias_habilitados_quarta  == '1' ? 'checked' : ''; ?> />
		<input id="cb_quinta" type="checkbox"   <? echo $dsdias_habilitados_quinta  == '1' ? 'checked' : ''; ?> />
		<input id="cb_sexta" type="checkbox"    <? echo $dsdias_habilitados_sexta   == '1' ? 'checked' : ''; ?> />
		<input id="cb_sabado" type="checkbox"   <? echo $dsdias_habilitados_sabado  == '1' ? 'checked' : ''; ?> />
		<br />

		<label for="dtprox_execucao"><? echo utf8ToHtml('Data Próxima Execução:') ?></label>
		<input type="text" id="dtprox_execucao" name="dtprox_execucao" value="<? echo getByTagName($registros,'dtprox_execucao'); ?>" />
		<br />

		<label for="hrprox_execucao"><? echo utf8ToHtml('Hora Próxima Execução:') ?></label>
		<input type="text" id="hrprox_execucao" name="hrprox_execucao" onchange="validarHora(this)" value="<? echo getByTagName($registros,'hrprox_execucao'); ?>" />
		<br />

		<label for="flaguarda_processo">Aguardar Processo?</label>
		<input type="checkbox" id="flaguarda_processo" name="flaguarda_processo"  <? echo getByTagName($registros,'flaguarda_processo') == 'S' ? 'checked' : ''; ?> />
		<br />

		<label for="flexecuta_feriado">Executar em Feriados?</label>
		<input type="checkbox" id="flexecuta_feriado" name="flexecuta_feriado"  <? echo getByTagName($registros,'flexecuta_feriado') == 1 ? 'checked' : ''; ?> />
		<br />

		<label for="lbltpaviso"><? echo utf8ToHtml('Tipo de Aviso / Saída Habilitada:') ?></label>
		<input type="checkbox" id="flsaida_email" name="flsaida_email"  <? echo getByTagName($registros,'flsaida_email') == 'S' ? 'checked' : ''; ?> />
		<label for="flsaida_email"><? echo utf8ToHtml('Email') ?></label>

		<label for="dsdestino_email"><? echo utf8ToHtml('Email:') ?></label>
		<input type="text" id="dsdestino_email" name="dsdestino_email" value="<? echo getByTagName($registros,'dsdestino_email'); ?>" />
		<br />

		<label for="lblLog"></label>
		<input type="checkbox" id="flsaida_log" name="flsaida_log"  <? echo getByTagName($registros,'flsaida_log') == 'S' ? 'checked' : ''; ?> />
		<label for="flsaida_log"><? echo utf8ToHtml('LOG') ?></label>

		<label for="dsnome_arq_log"><? echo utf8ToHtml('Nome Arq:') ?></label>
		<input type="text" id="dsnome_arq_log" name="dsnome_arq_log" value="<? echo getByTagName($registros,'dsnome_arq_log'); ?>" />
		<label for="lbl_ponto_log">.log</label>

		<br style="clear:both;" />

		<label for="dscodigo_plsql"><? echo utf8ToHtml('Código PLSQL:') ?></label>
		<textarea id="dscodigo_plsql" name="dscodigo_plsql"><? echo getByTagName($registros,'dscodigo_plsql'); ?></textarea>

	</fieldset>

</form>

<div id="divBotoesIncluir" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="showConfirmacao('Tem certeza que deseja Voltar? As altera&ccedil;&otilde;es ser&atilde;o desfeitas!','Confirma&ccedil;&atilde;o - Ayllos','controlaVoltar(\'1\');','','sim.gif','nao.gif');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Concluir</a>	
				
</div>


