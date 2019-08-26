<? 
/*!
 * FONTE        : form_consulta_ted.php
 * CRIA��O      : Helinton Steffens - (Supero)
 * DATA CRIA��O : 14/03/2018 
 * OBJETIVO     : Tabela que apresenta as TED recebidas
 */	
/*
  16/04/2019 - INC0011935 - Melhorias diversas nos layouts de teds e conciliação:
               - modal de conciliação arrastável e correção das colunas para não obstruir as caixas de seleção;
               - aumentadas as alturas das listas de teds e modal de conciliação, reajustes das colunas (Carlos)
			   
  08/07/2019 - Alterações referetentes a RITM13002 (Daniel Lombardi - Mout'S)
*/
?>
<form id="frmTabela" class="formulario" >
<input type="hidden" id="estadoAtual">
<input type="hidden" id="contaConferencia">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
                    <th><? echo utf8ToHtml('');  ?></th>
					<th><? echo utf8ToHtml('Nome remetente');  ?></th>
                    <th><? echo utf8ToHtml('UF');  ?></th>
					<th><? echo utf8ToHtml('CPF/CNPJ');  ?></th>
					<th><? echo utf8ToHtml('Ban/Ag');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Dt. receb.');  ?></th>
                    <th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? for ($x = 0; $x <= ($qtregist -1); $x++) { ?>
					<tr>
						<td><input type="checkbox" name="check" class="marcar" estado="<? echo getByTagName($registro[$x]->tags,'estado') ?>" onclick="verificaCheckboxTed(this, <? echo getByTagName($registro[$x]->tags,'valor'); ?>,'<? echo getByTagName($registro[$x]->tags,'estado') ?>');"/></td>
						<td><span><? echo getByTagName($registro[$x]->tags,'nmremetente') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'nmremetente') ?>
								  <input type="hidden" id="idlancto" name="idlancto" value="<? echo getByTagName($registro[$x]->tags,'idlancto') ?>" />
								  <input type="hidden" id="nmcartorio" name="nmcartorio" value="<? echo getByTagName($registro[$x]->tags,'nmcartorio') ?>" />
								  <input type="hidden" id="nmremetente" name="nmremetente" value="<? echo getByTagName($registro[$x]->tags,'nmremetente') ?>" />
								  <input type="hidden" id="cnpj_cpf" name="cnpj_cpf" value="<? echo getByTagName($registro[$x]->tags,'cnpj_cpf') ?>" />
								  <input type="hidden" id="banco" name="banco" value="<? echo getByTagName($registro[$x]->tags,'banco') ?>" />
								  <input type="hidden" id="agencia" name="agencia" value="<? echo getByTagName($registro[$x]->tags,'agencia') ?>" />
								  <input type="hidden" id="conta" name="conta" value="<? echo getByTagName($registro[$x]->tags,'conta') ?>" />
								  <input type="hidden" id="dtrecebimento" name="dtrecebimento" value="<? echo getByTagName($registro[$x]->tags,'dtrecebimento') ?>" />
								  <input type="hidden" id="valor" name="valor" value="<? echo getByTagName($registro[$x]->tags,'valor') ?>" />
								  <input type="hidden" id="estado" name="estado" value="<? echo getByTagName($registro[$x]->tags,'estado') ?>" />
								  <input type="hidden" id="cidade" name="cidade" value="<? echo getByTagName($registro[$x]->tags,'cidade') ?>" />
								  <input type="hidden" id="status" name="status" value="<? echo getByTagName($registro[$x]->tags,'status') ?>" />
						</td>
                        <td><span><? echo getByTagName($registro[$x]->tags,'estado') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'estado') ?>
						</td>
                        <td><span><? echo getByTagName($registro[$x]->tags,'cnpj_cpf') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'cnpj_cpf') ?>
						</td>
                        <td><span><? echo getByTagName($registro[$x]->tags,'banco') , '/' , getByTagName($registro[$x]->tags,'agencia') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'banco') , '/' , getByTagName($registro[$x]->tags,'agencia') ?>
						</td>
						<td><span><? echo getByTagName($registro[$x]->tags,'conta') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'conta') ?>
						</td>
						<td><span><? echo getByTagName($registro[$x]->tags,'dtrecebimento') ?></span>
							      <? echo getByTagName($registro[$x]->tags,'dtrecebimento') ?>
						</td>
						<td><span><? echo getByTagName($registro[$x]->tags,'valor') ?></span>
							      <? echo number_format(getByTagName($registro[$x]->tags,'valor'),2,',','.') ?>
						</td>
						
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	<br />
	<div class="complemento">
		<input type="hidden" id="idlancto" value=""/>
	</div>
	<div id="linha1">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cart&oacuterio:'); ?></li>
	<li id="dscartorio"></li>
	<li><? echo utf8ToHtml('Valor da Ted:'); ?></li>
	<li id="vlted"></li>
	</ul>
	</div>

	<div id="linha2">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Nome do remetente:'); ?></li>
	<li id="nmremetente"></li>
	<li><? echo utf8ToHtml('Cpf/Cnpj:'); ?></li>
	<li id="cpfcnpj"></li>
	</ul>
	</div>	
	
	<div id="linha3">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Banco/Ag&ecircncia:'); ?></li>
	<li id="cdbanpag"></li>
	<li><? echo utf8ToHtml('Conta:'); ?></li>
	<li id="nrconta"></li>
	</ul>
	</div>	

	<div id="linha4">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Data:'); ?></li>
	<li id="dtrecebimento"></li>
	<li><? echo utf8ToHtml('Status:'); ?></li>
	<li id="dsstatus"></li>
	</ul>
	</div>	

	<div id="linha5">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Cidade:'); ?></li>
	<li id="cdcidade"></li>
	<li><? echo utf8ToHtml('Estado:'); ?></li>
	<li id="cdestado"></li>
	</ul>
	</div>
    
    <div id="linha6">
	<ul class="complemento">
	<li><? echo utf8ToHtml('Total Selecionado:'); ?></li>
	<li id="vlTedTotal"></li>
	</ul>
	</div>
</form>

<div id="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btnDesmarcar" onclick="desmarcarCheckboxes()">Desmarcar</a>
	<?php
	if ( $qtregist > 0 ) {
	?>
		<a href="#" class="botao" onclick="exportarConsultaPDF(); return false;">Exportar PDF</a>
		<a href="#" class="botao" onclick="exportarConsultaCSV(); return false;">Exportar CSV</a>
		<button class="botao" onclick="abrirModalDevolverTED(); return false;" id="btnDevolver">Devolver</button>
		<a href="#" class="botao" onclick="validarCartorioTED(); return false;">Estorno de custas</a>
		<a href="#" class="botao" onclick="abrirModalConciliacao(); return false;">Conciliar</a>
	<?php
	}
	?>
</div>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_ted_csv.php" method="post" id="frmExportarCSV" name="frmExportarCSV">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_ted_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="inivlpro" id="inivlpro" value="<?php echo $inivlpro; ?>">
	<input type="hidden" name="fimvlpro" id="fimvlpro" value="<?php echo $fimvlpro; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>
