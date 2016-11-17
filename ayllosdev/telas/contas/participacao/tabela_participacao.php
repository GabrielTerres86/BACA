<? 
/*!
 * FONTE        : tabela_participacao.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Tabela que apresenta as empresas participantes
 * 
 * ALTERACOES   : 04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 */	
?>
<? $search  = array('.','-','/'); ?>
<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Conta/dv</th>
				<th>Raz&atilde;o Social</th>
				<th>C.N.P.J.</th>
				<th>% Societ&aacute;rio</th>
			</tr>			
		</thead>
		<tbody>
			<?foreach($registros as $empresasPart) {?>
				<tr>
					<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'cddconta')) ?></span>
						<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo str_replace($search,'',getByTagName($empresasPart->tags,'cdcpfcgc')) ?>" /> 
						<input type="hidden" id="nrdctato" name="nrdctato" value="<? echo str_replace($search,'',getByTagName($empresasPart->tags,'cddconta')) ?>" />
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($empresasPart->tags,'nrdrowid') ?>" />
						<? echo getByTagName($empresasPart->tags,'cddconta'); ?></td>
					<td><? echo stringTabela(getByTagName($empresasPart->tags,'nmprimtl'),30,'maiuscula') ?></td>
					<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'cdcpfcgc')) ?></span>
					<? echo getByTagName($empresasPart->tags,'cdcpfcgc') ?></td>
					<td><span><? echo str_replace($search,'',getByTagName($empresasPart->tags,'persocio')) ?></span>
					<? echo number_format(str_replace(',','.',getByTagName($empresasPart->tags,'persocio')),2,',','.') ?></td>
				</tr>				
			<? } ?>			
		</tbody>
	</table>
</div>
<div id="divBotoes">
	<? if ($flgcadas == 'M') { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="voltarRotina();" />	
	<? } else { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina(divRotina);" />	
	<? } ?>
	<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacao('TA');" />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacao('TC');" />
	<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacao('TX');" />
	<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacao('TI');" />		
	<input type="image" id="btContinuar"   src="<? echo $UrlImagens; ?>botoes/continuar.gif"   onClick="proximaRotina();" />		
</div>