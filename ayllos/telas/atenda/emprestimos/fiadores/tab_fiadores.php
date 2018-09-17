<? 
/*!
 * FONTE        : tab_fiadores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 28/02/2011 
 * OBJETIVO     : Tabela que apresenta as contas onde o titular é fiador
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
 */	

?>

<div id="divTabFiadores">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr><th><? echo utf8ToHtml('Conta\Dv');?></th>
				<th>Contrato</th>
				<th>Data</th>
				<th>Valor</th>
				<th>Qtd</th>
				<th>Valor Prest.</th>
				<th>Saldo</th></tr>
			</thead>
			<tbody>
				<!--Monta tabela dinamicamente-->
			</tbody>
		</table>
	</div>	
	<div id="divBotoes">		
		<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="fechaFiadores(); return false;">Continuar</a>
	</div>
</div> 	