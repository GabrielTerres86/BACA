 <? 
/*!
 * FONTE        : tabela_emprestimos_avalistas.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/07/2011 
 * OBJETIVO     : Tabela que apresenta os emprestimos dos avalistas
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
 */	
?>

<div id="divEmprAvalTab">
	<div class="divRegistros">	
        <table>
            <thead>
                <tr><th>Conta</th>
					<th>Contrato</th>
					<th><? echo utf8ToHtml('Liberação');?></th>
                    <th>Valor</th>
                    <th>Parcelas</th>
                    <th>Vl. Parc.</th>
                    <th>Saldo</th>
            </thead>		
            <tbody>

            </tbody>
        </table>
    </div>
    <div id="divBotoes">
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('T_EFETIVA'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" >Continuar</a>		
    </div>
</div>