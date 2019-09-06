<? 
/*!
* FONTE        : tabela_simulacoes.php
* CRIAÇÃO      : Marcelo L. Pereira (GATI)
* DATA CRIAÇÃO : 16/06/2011 
* OBJETIVO     : Tabela que apresenta as simulações de empréstimo
* ALTERAÇÕES   : 
* --------------
* 000: [20/09/2011] Adicionada coluna de data de pagamento - Marcelo L. Pereira (GATI)
* 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
* 002: [19/09/2013] Comentado a opcao de gerar proposta. (Irlan).
* 003: [30/06/2015] Ajustes referentes Projeto 215 - DV 3 (Daniel).
* 004: [01/07/2019] P438 - Inclusão do campo oculto CDORIGEM (Douglas Pagel / AMcom)
*/
?>

<div id="divProcSimulacoesTabela">
    <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo $glbvars['dtmvtolt'] ?>" />	
    <div class="divRegistros">	
        <table>
            <thead>
                <tr><th><? echo utf8ToHtml('N°');?></th>
                    <th><? echo utf8ToHtml('Dt. Liberação');?></th>
                    <th>Dt. Pagamento</th>
                    <th><? echo utf8ToHtml('Fin');?></th>
                    <th><? echo utf8ToHtml('Lcr');?></th>
                    <th>Valor</th>
                    <th><? echo utf8ToHtml('N° Parcelas');?></th>
                    <th>Vl. Parcela</th>                    
                    <th>Produto</th>
                </tr>
            </thead>		
            <tbody>
                <? foreach( $simulacoes as $simulacao ) {?>
                <tr>
                    <td id="nrsimula"><span><? echo getByTagName($simulacao->tags,'nrsimula') ?></span><? echo ((int) getByTagName($simulacao->tags,'nrsimula')) ?>
                        <input type="hidden" id="nrsimula" name="nrsimula" value="<? echo getByTagName($simulacao->tags,'nrsimula') ?>"/>
                        <input type="hidden" id="tpfinali" name="tpfinali" value="<? echo getByTagName($simulacao->tags,'tpfinali') ?>"/>
                        <input type="hidden" id="cdmodali" name="cdmodali" value="<? echo getByTagName($simulacao->tags,'cdmodali') ?>"/>
                        <input type="hidden" id="tpemprst" name="tpemprst" value="<? echo getByTagName($simulacao->tags,'tpemprst') ?>"/>
						<input type="hidden" id="cdorigem" name="cdorigem" value="<? echo getByTagName($simulacao->tags,'cdorigem') ?>"/>
                    </td>					
                    <td id="dtlibera"><span><? echo getByTagName($simulacao->tags,'dtlibera') ?></span><? echo getByTagName($simulacao->tags,'dtlibera') ?></td>
                    <td id="dtdpagto"><span><? echo getByTagName($simulacao->tags,'dtdpagto') ?></span><? echo getByTagName($simulacao->tags,'dtdpagto') ?></td>
                    <td><? echo getByTagName($simulacao->tags,'cdfinemp') ?></td>
                    <td><? echo getByTagName($simulacao->tags,'cdlcremp') ?></td>
                    <td><? echo number_format(str_replace(",",".",getByTagName($simulacao->tags,'vlemprst')),2,",",".") ?></td>
                    <td><? echo getByTagName($simulacao->tags,'qtparepr') ?></td>
                    <td><? echo number_format(str_replace(",",".",getByTagName($simulacao->tags,'vlparepr')),2,",",".") ?></td>
                    <td><? if (getByTagName($simulacao->tags,'tpemprst') == 0) {echo 'TR';} else
                           if (getByTagName($simulacao->tags,'tpemprst') == 1) {echo 'PP';} else
                           if (getByTagName($simulacao->tags,'tpemprst') == 2) {echo 'POS';} ?></td>
                </tr>
                <? } ?>
            </tbody>
        </table>
    </div>
    <div id="divBotoesSimulacao" style="margin-top:5px; margin-bottom:5px">
        <a href="#" class="botao" id="btVoltar"    onClick="fechaSimulacoes('');
                return false;">Voltar</a>
        <a href="#" class="botao" id="btIncluir"   onClick="controlaOperacaoSimulacoes('I_SIMULACAO');
                return false;">Incluir</a>
        <a href="#" class="botao" id="btAlterar"   onClick="controlaOperacaoSimulacoes('A_SIMULACAO');
                return false;">Alterar</a>
        <a href="#" class="botao" id="btExcluir"   onClick="controlaOperacaoSimulacoes('E_SIMULACAO');
                return false;">Excluir</a>
        <a href="#" class="botao" id="btConsultar" onClick="controlaOperacaoSimulacoes('C_SIMULACAO');
                return false;">Consultar</a>
        <a href="#" class="botao" id="btImprimir"  onClick="controlaOperacaoSimulacoes('IMP_SIMULACAO');
                return false;">Imprimir</a>
        <a href="#" class="botao" id="btGerarProp" onClick="gerarProposta();
                return false;">Gerar Proposta</a>
    </div>
</div>