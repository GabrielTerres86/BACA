<?
/*!
 * FONTE        : tabela_emprestimo.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 08/02/2011
 * OBJETIVO     : Tabela que apresentar os Emprestimos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [08/08/2011] Adicionado botões 'Simular' e 'Efetivar' - Marcelo L. Pereira (GATI)
 * 001: [20/09/2011] Corrigindo acentuação - Marcelo L. Pereira (GATI)
 * 002: [29/03/2012] Incluir coluna de tipo de emprestimo (Gabriel)
 * 003: [05/09/2012] Mudar para layout padrao (Gabriel).
 * 004: [14/12/2012] Mudar a descricao de Tipo para Produto (Gabriel).
 * 005: [16/09/2013] Incluido novo botão "Registrar Gravames" (André Euzébio / Supero).
 * 006: [07/11/2014] Incluido um campo hidden "cdorigem". (Jaison)
 * 007: [07/07/2015] Incluido um campo hidden "err_efet". (Jaison/Diego - SD: 290027)
 * 008: [07/08/2015] Incluir o botao "Recalcular". (James)
 * 009: [15/10/2015] Alteracao do nome do botao "Recalcular" para "Atualizar Data". (Jaison/Oscar)
 * 010: [16/03/2016] Inclusao da operacao ENV_ESTEIRA. PRJ207 Esteira de Credito. (Odirlei-AMcom) 
 * 011: [22/03/2016] Inclusao da operacao ACIONAMENTOS. PRJ207 Esteira de Credito. (Daniel/Oscar)
 * 012: [30/03/2017] Exibir produto Pos-Fixado. (Jaison/James - PRJ298)
 * 012: [25/04/2017] Alterado ordem das colunas "Ac" e "Situação" Projeto 337 - Motor de crédito. (Reinert)
 * 013: [01/12/2017] Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364)
 */
?>

<div id="divEmpres" class="divRegistros">
    
	<table>
		<thead>
			<tr><th>Data</th>
				<th>Contrato</th>
				<th>Produto</th>
				<th><? echo utf8ToHtml('Empréstimo');?></th>
				<th>Financiado</th>
				<th><? echo utf8ToHtml('Prestação');?></th>
				<th>Pr</th>
				<th>Lcr</th>
				<th>Fin</th>
				<th>Ac</th>
				<th><? echo utf8ToHtml('Situação');?></th>
				<th><? echo utf8ToHtml('Decisão');?></th></tr>
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) {
                switch (getByTagName($registro->tags,'tpemprst')) {
                    case 0:
                        $tipo = "Price TR";
                        break;
                    case 1:
                        $tipo = "Price Pre-fixado";
                        break;
                    case 2:
                        $tipo = "Pos-fixado";
                        break;
                } ?>
				<tr><td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtmvtolt')) ?></span>
						<? echo getByTagName($registro->tags,'dtmvtolt') ?></td>
					<td><span><? echo getByTagName($registro->tags,'nrctremp') ?></span>
						<? echo formataNumericos("zzz.zz9",getByTagName($registro->tags,'nrctremp'),".") ?>

						<input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($registro->tags,'nrctremp') ?>" />
						<input type="hidden" id="nrdrecid" name="nrdrecid" value="<? echo getByTagName($registro->tags,'nrdrecid') ?>" />
						<input type="hidden" id="tplcremp" name="tplcremp" value="<? echo getByTagName($registro->tags,'tplcremp') ?>" />
						<input type="hidden" id="qtpromis" name="qtpromis" value="<? echo getByTagName($registro->tags,'qtpromis') ?>" />
						<input type="hidden" id="dsctrliq" name="dsctrliq" value="<? echo getByTagName($registro->tags,'dsctrliq') ?>" />
						<input type="hidden" id="flgimppr" name="flgimppr" value="<? echo getByTagName($registro->tags,'flgimppr') ?>" />
						<input type="hidden" id="flgimpnp" name="flgimpnp" value="<? echo getByTagName($registro->tags,'flgimpnp') ?>" />
                        <input type="hidden" id="cdorigem" name="cdorigem" value="<? echo getByTagName($registro->tags,'cdorigem') ?>" />
                        <input type="hidden" id="portabil" name="portabil" value="<? echo getByTagName($registro->tags,'portabil') ?>" />
                        <input type="hidden" id="err_efet" name="err_efet" value="<? echo getByTagName($registro->tags,'err_efet') ?>" />
						<input type="hidden" id="insitapr" name="insitapr" value="<? echo getByTagName($registro->tags,'insitapr') ?>" />
						<input type="hidden" id="cdlcremp" name="cdlcremp" value="<? echo getByTagName($registro->tags,'cdlcremp') ?>" />
					    <input type="hidden" id="vlfinanc" name="vlfinanc" value="<? echo getByTagName($registro->tags,'vlfinanc') ?>" />
						<input type="hidden" id="dssitest" name="dssitest" value="<? echo getByTagName($registro->tags,'dssitest') ?>" />
            <input type="hidden" id="inobriga" name="inobriga" value="<? echo getByTagName($registro->tags,'inobriga') ?>" />
                    </td>

					<td> <? echo stringTabela($tipo,40,'maiuscula'); ?>  </td>
					<td><span><? echo str_replace(",",".",getByTagName($registro->tags,'vlemprst')) ?></span>
						<? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlemprst')),2,",",".") ?></td>
						<td><span><? echo str_replace(",",".",getByTagName($registro->tags,'vlfinanc')) ?></span>
						<? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlfinanc')),2,",",".") ?></td>
					<td><span><? echo str_replace(",",".",getByTagName($registro->tags,'vlpreemp')) ?></span>
						<? echo number_format(str_replace(",",".",getByTagName($registro->tags,'vlpreemp')),2,",",".") ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'qtpreemp'),10,'maiuscula') ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'cdlcremp'),10,'maiuscula') ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'cdfinemp'),10,'maiuscula') ?></td>
					<td><? echo stringTabela(getByTagName($registro->tags,'cdoperad'),10,'maiuscula') ?></td>					
					<td><? echo getByTagName($registro->tags,'dssitest') ?></td>
					<td><? echo getByTagName($registro->tags,'dssitapr') ?></td></tr>
			<? } ?>
		</tbody>
	</table>
</div>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar"    onclick="encerraRotina(true); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterar"   onclick="controlaOperacao('TA');">Alterar</a>
	<a href="#" class="botao" id="btConsultar" onClick="direcionaConsulta();">Consultar</a>
	
	<?php if(!(/* $sitaucaoDaContaCrm == '4' || */ 
			   $sitaucaoDaContaCrm == '7' || 
			   $sitaucaoDaContaCrm == '8'  )){?>

	<a href="#" class="botao" id="btIncluir"   onClick="controlaOperacao('I');">Incluir</a>
	
	<?}?>
	
	<a href="#" class="botao" id="btImprimir"  onClick="controlaOperacao('IMP');">Imprimir</a>
	<a href="#" class="botao" id="btSimular"   onClick="validaSimulacao();">Simular</a>
  <a href="#" class="botao" id="btRecalcular" onClick="controlaOperacao('VAL_RECALCULAR_EMPRESTIMO');">Atualizar Data</a>
	<div style="margin-top:5px;" />
	<a href="#" class="botao" id="btAprovar"   onClick="controlaOperacao('T_EFETIVA');">Efetivar</a>
	<a href="#" class="botao" id="btGravames"  onClick="controlaOperacao('VAL_GRAVAMES');">Registrar GRV</a>    
	<a href="#" class="botao" id="btPortabilidade"  onClick="controlaOperacao('PORTAB_CRED_I');">Portabilidade</a>
	<a href="#" class="botao" id="btEnvEsteira"  onClick="controlaOperacao('ENV_ESTEIRA')">Analisar</a>
	<a href="#" class="botao" id="btAcionamentos"  onClick="controlaOperacao('ACIONAMENTOS')">Detalhes Proposta</a>
	
</div>