<? 
/*!
 * FONTE        : tabela_procuradores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Tabela que apresenda os representantes/procuradores
 *
 * ALTERACOES   : 22/07/2013 - Inclusão do botão de poderes (Jean Michel).
 *
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
<? $search  = array('.','-'); ?>
<form id="frmProcuradores" class="formulario">
	<fieldset>
		<legend> Procuradores </legend>
		<div class="divRegistrosProcuradores" style="overflow-y: scroll;">
			<table style="width:100%;">
				<thead>
					<tr><th>Conta/dv</th>
						<th>Nome</th>
						<th>C.P.F.</th>
						<th>C.I.</th>
						<th>Vig&ecirc;ncia</th>
					</tr>			
				</thead>
				<tbody>
					<?foreach($registros as $procuracao) {?>
						<tr>
							<!-- Analisar essa linha, chave primaria de procuradores(cdcooper,tpctrato,nrdconta,nrctremp,nrcpfcgc) -->
							<td style="font-size:11px;"> <? echo getByTagName($procuracao->tags,'cddconta'); ?></td> <!-- Conta/dv -->
								<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($procuracao->tags,'nrcpfcgc') ?>" /> 
								<input type="hidden" id="nrdctato" name="nrdctato" value="<? echo getByTagName($procuracao->tags,'nrdctato') ?>" />
								<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($procuracao->tags,'nrdrowid') ?>" />
							<td style="font-size:11px;"><? echo stringTabela(getByTagName($procuracao->tags,'nmdavali'),23,'maiuscula') ?></td> <!-- Nome     -->
							<td style="font-size:11px;"><? echo getByTagName($procuracao->tags,'cdcpfcgc') ?></td> <!-- C.P.F.   -->
							<td style="font-size:11px;"><? echo getByTagName($procuracao->tags,'nrdocava') ?></td> <!-- C.I.     -->
							<td style="font-size:11px;"><? echo getByTagName($procuracao->tags,'dsvalida') ?></td> <!-- Vigência -->
						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>
		<div id="divBotoes">
			<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacaoProcuradores('TA'); return false;" />
			<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoProcuradores('TC'); return false;" />
			<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacaoProcuradores('TX'); return false;" />
			<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacaoProcuradores('TI'); return false;" />			
			<input type="image" id="btPoderes"   src="<? echo $UrlImagens; ?>botoes/poderes.gif"   onClick="controlaOperacaoProcuradores('TP'); return false;" />	
		</div>
	</fieldset>
</form>