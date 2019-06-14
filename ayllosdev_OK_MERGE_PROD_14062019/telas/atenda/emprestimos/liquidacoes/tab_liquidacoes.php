<? 
/*!
 * FONTE        : tab_liquidacoes.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 28/02/2011 
 * OBJETIVO     : Tabela que apresenta as prestações a serem liquidadas
 
   ALTERACOES   : 10/07/2012 - Validar sempre os contratos a serem liquidados (Gabriel).
				  05/09/2012 - Mudar para layout padrao (Gabriel) 
				  29/06/2015 - Ajustes referente Projeto 215 - DV 3 (Daniel). 
 */	
?>

<div id="divTabLiquidacoes">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th></th>
					<th><? echo utf8ToHtml('Lin');?></th>
					<th>Fin</th>
					<th>Contrato</th>
					<th>Data</th>
					<th>Emprestado</th>
					<th>Parc.</th>
					<th>Valor</th>
					<th>Saldo</th>
					<th>Tipo</th>
				</tr>
			</thead>
			<tbody>
				<!--Monta tabela dinamicamente-->
			</tbody>
		</table>
	</div>	
	<div id="divBotoes">
		<?php //bruno - prj 438 - bug 14400 ?>
		<a href="#" class="botao" id="btSalvar" onClick="fechaLiquidacoes('<?php echo $prox_tela; ?>','LIQUIDACOES'); return false;" >Continuar</a>
	</div>
</div>