<? 
/*!
 * FONTE        : tabela_procuradores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Tabela que apresenda os representantes/procuradores
 * ALTERAÇÕES   : 06/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 * 				  04/07/2013 - Inclusão do botão poderes (Jean Michel)
 *                04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							  (Adriano - P339).
 */	
?>
<? $search  = array('.','-'); 
   $qtRegistros = 0;
?>
<form id="frmRegistrosProc">
<div class="divRegistros">
	<table class="table">
		<thead>
			<tr><th>Conta/dv</th>
				<th>Nome</th>
				<th>C.P.F.</th>
				<th>C.I.</th>
				<th>Vig&ecirc;ncia</th>
				<th>Cargo</th>
			</tr>			
		</thead>
		<tbody>
			<?foreach($registros as $procuracao) { $qtRegistros++; ?>
					
			<tr onclick="guarda('<? echo getByTagName($procuracao->tags,'dsproftl'); ?>');" onfocus="guarda('<? echo getByTagName($procuracao->tags,'dsproftl'); ?>');"  >
					<!-- Analisar essa linha, chave primaria de procuradores(cdcooper,tpctrato,nrdconta,nrctremp,nrcpfcgc) -->
					<td>
						<span><? echo str_replace($search,'',getByTagName($procuracao->tags,'cddconta')) ?></span>
						<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($procuracao->tags,'nrcpfcgc') ?>" /> 
						<input type="hidden" id="nrdctato" name="nrdctato" value="<? echo getByTagName($procuracao->tags,'nrdctato') ?>" />
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($procuracao->tags,'nrdrowid') ?>" />
						<input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($procuracao->tags,'nrctremp') ?>" />
						<? echo getByTagName($procuracao->tags,'cddconta'); ?>
					</td>
					<td>
						<? echo stringTabela(getByTagName($procuracao->tags,'nmdavali'),17,'maiuscula') ?>
					</td> 
					<td>
						<span><? echo str_replace($search,'',getByTagName($procuracao->tags,'cdcpfcgc')) ?></span>
						<? echo getByTagName($procuracao->tags,'cdcpfcgc') ?>
					</td>
					<td>
						<span><? echo str_replace($search,'',getByTagName($procuracao->tags,'nrdocava')) ?></span>
						<? echo stringTabela(getByTagName($procuracao->tags,'nrdocava'),15,'maiuscula') ?>
					</td>
					<td>
						<span><? echo dataParaTimestamp(getByTagName($procuracao->tags,'dsvalida')) ?></span>
						<? echo getByTagName($procuracao->tags,'dsvalida') ?>
					</td>
					<td>
						<? echo stringTabela(getByTagName($procuracao->tags,'dsproftl'),10,'maiuscula') ?>
					</td>
				</tr>	
				
			<? } ?>			
		</tbody>
		
	</table>
	
</div>
</form>
<div id="divBotoesTabProc">

	<? if($nmrotina == "Representante/Procurador"){?>

		<? if ($flgcadas == 'M' ) { ?>
			<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina(divRotina);" />	
		<? } ?>
		<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="aux_operacao = 'TA'; controlaOperacaoProc('TA');" />
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoProc('TC');" />
		<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacaoProc('TX');" />
		<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="aux_operacao = 'TI'; controlaOperacaoProc('TI');" />			
		<input type="image" id="btPoderes"   src="<? echo $UrlImagens; ?>botoes/poderes.gif"   onClick="controlaOperacaoProc('TP');" />	
		
		<? if ($nmdatela == 'CONTAS' ) { ?>
			<input type="image" id="btContinuar"   src="<? echo $UrlImagens; ?>botoes/continuar.gif"   onClick="proximaRotina();" />	
		<? } ?>
		
	<? } else if($aux_operacao == "FC"){?>
	
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="nmrotina = ''; fechaRotina(divRotina);"/>
		<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoProc('TC');" />
	
	<?}else{?>
	
			<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacaoProc('TA');" />
			<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoProc('TC');" />
			<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacaoProc('TX');" />
			<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacaoProc('TI');" />			
			
			<?if($aux_operacao == "CA"){?>
				<input type="image" id="btConcluir"  src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick="nmrotina = ''; verrespo = true; fechaRotina(divRotina); controlaOperacao('AV');" />
			<?}else if($aux_operacao == "CI"){?>
				<input type="image" id="btConcluir"  src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick="nmrotina = ''; verrespo = true; fechaRotina(divRotina); impressao_inclusao();" />
			<?}else if($aux_operacao == "CX"){?>
				<input type="image" id="btConcluir"  src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick="nmrotina = ''; verrespo = true; fechaRotina(divRotina); controlaOperacao('XV');" />
			<?}else if($aux_operacao == "CD"){?>
				<input type="image" id="btConcluir"  src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick="nmrotina = ''; verrespo = true; fechaRotina(divRotina); controlaOperacao('DV');" />
			<?}?>
			
	<?}?>
	
</div>
<script type="text/javascript">
	<? if ($nmrotina == "MATRIC" && $qtRegistros == 0) { ?>
		controlaOperacaoProc('TI');
	<? } ?>
</script>