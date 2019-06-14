<? 
/*!
 * FONTE        : tabela_prestacoes.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 25/03/2011 
 * OBJETIVO     : Tabela com as pretações da conta selecionada
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [23/08/2011] Marcelo L. Pereira (GATI): botão 'Pagar'
 * 002: [31/08/2011] Adicionado botão 'Desfazer Efetivação'- Marcelo L. Pereira (GATI)  
 * 003: [03/02/2012] Atribuida a funcao encerraRotina ao botao voltar (Tiago).
 * 004: [29/03/2012] Incluido tipo de contrato (Gabriel)
 * 005: [14/12/2012] Alterar coluna Tipo por Produto (Gabriel).
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Lin</th>
				<th>Fin</th>
				<th>Contrato</th>
				<th>Produto</th>
				<th>Data</th>
				<th>Emprestado</th>
				<th>Parc</th>
				<th>Valor</th>
				<th>Saldo</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $banco ) { $tipo = (getByTagName($banco->tags,'tpemprst') == "0") ? "Price TR" : "Price Pre-fixado"  ?>
				<tr>
				    <td><? echo getByTagName($banco->tags,'cdlcremp') ?>
						<input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($banco->tags,'nrctremp') ?>" />
						<input type="hidden" id="inprejuz" name="inprejuz" value="<? echo getByTagName($banco->tags,'inprejuz') ?>" />
						<input type="hidden" id="tplcremp" name="tplcremp" value="<? echo getByTagName($banco->tags,'tplcremp') ?>" />
						<input type="hidden" id="nrdrecid" name="nrdrecid" value="<? echo getByTagName($banco->tags,'nrdrecid') ?>" />
						<input type="hidden" id="qtpromis" name="qtpromis" value="<? echo getByTagName($banco->tags,'qtpromis') ?>" />
						<input type="hidden" id="flgimppr" name="flgimppr" value="<? echo getByTagName($banco->tags,'flgimppr') ?>" />
						<input type="hidden" id="flgimpnp" name="flgimpnp" value="<? echo getByTagName($banco->tags,'flgimpnp') ?>" />
						<input type="hidden" id="tpemprst" name="tpemprst" value="<? echo getByTagName($banco->tags,'tpemprst') ?>" />
					</td>
					<td><? echo getByTagName($banco->tags,'cdfinemp') ?></td>
					<td><? echo formataNumericos("z.zzz.zzz",getByTagName($banco->tags,'nrctremp'),"."); ?></td>
					<td><? echo stringTabela($tipo,40,'maiuscula'); ?></td> 
					<td><? echo getByTagName($banco->tags,'dtmvtolt') ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlemprst')),2,",",".");?></td>
					<td><? echo getByTagName($banco->tags,'qtpreemp') ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlpreemp')),2,",",".");  ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlsdeved')),2,",",".");  ?></td>
				</tr>				
			<? } ?>			
		</tbody>		
	</table>
</div>

<div id="divBotoes">
	<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    			 onClick="encerraRotina('true');"  />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" 			 onClick="controlaOperacao('TC');"  />
	<input type="image" id="btPagar" 	 src="<? echo $UrlImagens; ?>botoes/pagar.gif" 	   			 onClick="controlaOperacao('C_PAG_PREST');"  />
<!--	<input type="image" id="bttranfPreju"src="<? echo $UrlImagens; ?>botoes/prejuizo.gif" 	   		 onClick="controlaOperacao('C_TRANSF_PREJU');"  /> -->
	<input type="image" id="btCancelar"  src="<? echo $UrlImagens; ?>botoes/desfazer_efetivacao.gif" onClick="controlaOperacao('D_EFETIVA');"  />
</div>