<? /************************************************************************
	 Fonte: agendamento_tabela.php
	 Autor: Douglas Quisinski
	 Data : Setembro/2014             Última Alteração:

	 Objetivo  : Monta tabela de agendamentos da tela de aplicações

	 Alterações: 
	 
	************************************************************************/
?>

var strHTML = "";
strHTML += '<div id="divAgendamento">';
strHTML += '	<div class="divRegistros">';
strHTML += '		<table>';
strHTML += '			<thead>';
strHTML += '				<tr>';
strHTML += '					<th><? echo utf8ToHtml('N&uacute;mero'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Tipo'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Parcela'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Valor'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Data Prox Lancamento'); ?></th>';
strHTML += '				</tr>';
strHTML += '			</thead>';
strHTML += '			<tbody>';
							lstAgendamentos = new Array(); // Inicializar lista de aplicações
							<? 
							for ($i = 0; $i < $qtAgendamentos; $i++) { 
								$cdageass = getByTagName($agendamentos[$i]->tags,"cdageass");
								$cdagenci = getByTagName($agendamentos[$i]->tags,"cdagenci");
								$cdcooper = getByTagName($agendamentos[$i]->tags,"cdcooper");
								$cdoperad = getByTagName($agendamentos[$i]->tags,"cdoperad");
								$cdsitaar = getByTagName($agendamentos[$i]->tags,"cdsitaar");
								$dtcancel = getByTagName($agendamentos[$i]->tags,"dtcancel");
								$dtcarenc = getByTagName($agendamentos[$i]->tags,"dtcarenc");
								$dtiniaar = getByTagName($agendamentos[$i]->tags,"dtiniaar");
								$dtmvtolt = getByTagName($agendamentos[$i]->tags,"dtmvtolt");
								$dtvencto = getByTagName($agendamentos[$i]->tags,"dtvencto");
								$flgctain = getByTagName($agendamentos[$i]->tags,"flgctain");
								$flgresin = getByTagName($agendamentos[$i]->tags,"flgresin");
								$flgtipar = getByTagName($agendamentos[$i]->tags,"flgtipar");
								$flgtipin = getByTagName($agendamentos[$i]->tags,"flgtipin");
								$hrtransa = getByTagName($agendamentos[$i]->tags,"hrtransa");
								$idseqttl = getByTagName($agendamentos[$i]->tags,"idseqttl");
								$nrctraar = getByTagName($agendamentos[$i]->tags,"nrctraar");
								$nrdconta = getByTagName($agendamentos[$i]->tags,"nrdconta");
								$nrdocmto = getByTagName($agendamentos[$i]->tags,"nrdocmto");
								$nrmesaar = getByTagName($agendamentos[$i]->tags,"nrmesaar");
								$qtdiacar = getByTagName($agendamentos[$i]->tags,"qtdiacar");
								$qtmesaar = getByTagName($agendamentos[$i]->tags,"qtmesaar");
								$vlparaar = getByTagName($agendamentos[$i]->tags,"vlparaar");
								$dtdiaaar = getByTagName($agendamentos[$i]->tags,"dtdiaaar");
									
								$tipoagen = ($flgtipar == "no") ? "Aplica&ccedil;&atilde;o" : "Resgate";
								$parcela  = $nrmesaar . "/" . $qtmesaar;
								?>
								objAgendamento = new Object();						
								objAgendamento.cdageass = "<?php echo $cdageass; ?>";
								objAgendamento.cdagenci = "<?php echo $cdagenci; ?>";
								objAgendamento.cdcooper = "<?php echo $cdcooper; ?>";
								objAgendamento.cdoperad = "<?php echo $cdoperad; ?>";
								objAgendamento.cdsitaar = "<?php echo $cdsitaar; ?>";
								objAgendamento.dtcancel = "<?php echo $dtcancel; ?>";
								objAgendamento.dtcarenc = "<?php echo $dtcarenc; ?>";
								objAgendamento.dtiniaar = "<?php echo $dtiniaar; ?>";
								objAgendamento.dtmvtolt = "<?php echo $dtmvtolt; ?>";
								objAgendamento.dtvencto = "<?php echo $dtvencto; ?>";
								objAgendamento.flgctain = "<?php echo $flgctain; ?>";
								objAgendamento.flgresin = "<?php echo $flgresin; ?>";
								objAgendamento.flgtipar = "<?php echo $flgtipar; ?>";
								objAgendamento.flgtipin = "<?php echo $flgtipin; ?>";
								objAgendamento.hrtransa = "<?php echo $hrtransa; ?>";
								objAgendamento.idseqttl = "<?php echo $idseqttl; ?>";
								objAgendamento.nrctraar = "<?php echo $nrctraar; ?>";
								objAgendamento.nrdconta = "<?php echo $nrdconta; ?>";
								objAgendamento.nrdocmto = "<?php echo $nrdocmto; ?>";
								objAgendamento.nrmesaar = "<?php echo $nrmesaar; ?>";
								objAgendamento.qtdiacar = "<?php echo $qtdiacar; ?>";
								objAgendamento.qtmesaar = "<?php echo $qtmesaar; ?>";
								objAgendamento.vlparaar = "<?php echo $vlparaar; ?>";
								objAgendamento.dtdiaaar = "<?php echo $dtdiaaar; ?>";
								objAgendamento.tipoagen = "<?php echo $tipoagen; ?>";
								objAgendamento.parcela  = "<?php echo $parcela ; ?>";
								lstAgendamentos[<?php echo $i; ?>] = objAgendamento;
								
								strHTML += '<tr id="trAgendamento<?php echo $i; ?>" style="cursor: pointer;" onClick="selecionaAgendamento(<?php echo $i; ?>);">';
								strHTML += '	<td><?php echo $nrctraar; ?></td>';
								strHTML += '	<td><?php echo $tipoagen; ?></td>';
								strHTML += '	<td><?php echo $parcela;  ?></td>';
								strHTML += '	<td><?php echo number_format(str_replace(",",".", $vlparaar),2,",","."); ?></td>';
								strHTML += '	<td><?php echo $dtiniaar; ?></td>';
								strHTML += '</tr>';
							<? } ?>

strHTML += '			</tbody>';
strHTML += '		</table>';
strHTML += '	</div>';

strHTML += '	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
strHTML += '		<a href="#" class="botao" id="btVoltar" onClick="voltarDivPrincipal();return false;">Voltar</a>';
strHTML += '		<a href="#" class="botao" id="btNovoAgendamento" onClick="novoAgendamento();return false;">Novo Agendamento</a>';
strHTML += '		<a href="#" class="botao" id="btExcluirAgendamento" onClick="excluirAgendamento();return false;">Excluir</a>';
strHTML += '		<a href="#" class="botao" id="btDetalhesAgendamento" onClick="detalhesAgendamento();return false;">Detalhes</a>';
strHTML += '	</div>';
strHTML += '</div>';

strHTML += '<div id="divTipoAgendamento" style="display: none;">';
strHTML += '	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
strHTML += '		<label class="rotulo txtNormalBold">Selecione tipo de agendamento:</label>';
strHTML += '		<br>';
strHTML += '		<a href="#" class="botao" id="btVoltar"               onClick="voltarAgendamento();return false;">Voltar</a>';
strHTML += '		<a href="#" class="botao" id="btAgendamentoAplicacao" onClick="acessaOpcaoAgendamentoAplicacao();return false;">Aplica&ccedil;&atilde;o</a>';
strHTML += '		<a href="#" class="botao" id="btAgendamentoResgate"   onClick="acessaOpcaoAgendamentoResgate();return false;">Resgate</a>';
strHTML += '	</div>';
strHTML += '</div>';

strHTML += '<div id="divDetalhesAgendamento"  style="display: none;"></div>';
strHTML += '<div id="divAgendamentoAplicacao" style="display: none;"></div>';
strHTML += '<div id="divAgendamentoResgate"   style="display: none;"></div>';


// Aumenta tamanho do div onde o conteudo de agendamento sera exibido
$("#divConteudoOpcao").css("height","250px");

// Mostra div para op&ccedil;&atilde;o de resgate
$("#divAplicacoesPrincipal").css("display","none");
$("#divAgendamentoPrincipal").css("display","block");
$("#divAgendamentoPrincipal").html(strHTML);

formataTabelaAgendamentos();

// Verifica se existem agendamento para a conta
if ( parseInt(<?php echo $qtAgendamentos; ?>) > 0 ) {
	// Selecionamos o primeiro registro
	selecionaAgendamento(0) ;
}

// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));