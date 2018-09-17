 <? 
/*!
 * FONTE        : tabela_parcelas.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 11/07/2011 
 * OBJETIVO     : Tabela que apresenta as parcelas da proposta de empréstimo
 
 * ALTERACOES   : 000: [05/09/2012] Mudar para layout padrao (Gabriel)
 
 */	
?>

<div id="divParcelasTab">
	<div class="divRegistros">	
        <table>
            <thead>
                <tr><th><? echo utf8ToHtml('Núm. Parcela');?></th>
                    <th>Dt. Vencimento</th>
                    <th>Valor Parcela</th>
            </thead>		
            <tbody id="tBodyParcelas">

            </tbody>
        </table>
    </div>
    <div id="divBotoes">
	<? if ( $operacao == 'A_PARCELAS') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="atualizaArray('A_DADOS_AVAL'); return false;">Continuar</a>
	<? }else if ( $operacao == 'V_PARCELAS' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_PARC_VALOR'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('F_VALOR'); return false;">Continuar</a>
	<? } else if ($operacao == 'C_PARCELAS') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_COMITE_APROV'); return false;">Continuar</a>
	<? } else if ($operacao == 'I_PARCELAS') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="atualizaArray('I_DADOS_AVAL'); return false;">Continuar</a>
	<? } ?>
    </div>
</div>