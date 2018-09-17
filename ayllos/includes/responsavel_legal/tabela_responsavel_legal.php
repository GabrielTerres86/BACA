<? 
/*!
 * FONTE        : tabela_responsavel_legal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Tabela que apresenda os responsáveis legais selecionado
 * ALTERAÇÕES   : 24/04/2012 - Ajustes para atender ao Projeto GP - Sócios Menores (Adriano)
 *
 *                18/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *	
 *                12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							  (Adriano - P339).

 */	
?>

<form id="frmRegistros">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Conta/dv</th>
					<th>Nome</th>
					<th>C.P.F.</th>
					<th>Documento</th>
				</tr>			
			</thead>
			<tbody>
				<?foreach($registros as $responsavel) {?>
					<tr>
						<td>
							<span><? echo getByTagName($responsavel->tags,'nrdconta') ?></span>
							<? if(getByTagName($responsavel->tags,'nrdconta') != 0){ echo formataContaDV(getByTagName($responsavel->tags,'nrdconta'));}else{echo "0";} ?>
							<input type="hidden" id="nrdrowid " name="nrdrowid " value="<? echo getByTagName($responsavel->tags,'nrdrowid'); ?>" />
						</td> 
						<td>
							<? echo stringTabela(getByTagName($responsavel->tags,'nmrespon'),33,'maiuscula') ?>
						</td>
						<td>
							<span><? echo str_replace('.','',getByTagName($responsavel->tags,'nrcpfcgc')) ?></span>
							<? echo formataNumericos('999.999.999-10',getByTagName($responsavel->tags,'nrcpfcgc'),'.-'); ?>
						</td>
						<td>
							<? echo stringTabela(getByTagName($responsavel->tags,'nridenti'),15,'maiuscula') ?>
						</td>
					</tr>			
				
				<?
				}?>			
			</tbody>
		</table>
	</div>
</form>
<div id="divBotoesResp">
	
	<? if ($nmrotina == 'Responsavel Legal' && $flgcadas == 'M') { ?>
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarRotina();"   />
	<? } else  { ?>
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="fechaRotina(divRotina);"   />
	<? } ?>
	
	<input type="image" id="btVoltarCns" src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick=""/>
	<input type="image" id="btAlterar"   src="<? echo $UrlImagens; ?>botoes/alterar.gif"   onClick="controlaOperacaoResp('TA');" />
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="" />
	<input type="image" id="btExcluir"   src="<? echo $UrlImagens; ?>botoes/excluir.gif"   onClick="controlaOperacaoResp('TE');" />	
	<input type="image" id="btIncluir"   src="<? echo $UrlImagens; ?>botoes/incluir.gif"   onClick="controlaOperacaoResp('TI');" />
	<input type="image" id="btConcluir"  src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick=""/>
	
	<? if ($nmrotina == 'Responsavel Legal' && $nmdatela == 'CONTAS') { ?>
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />
	<? } ?>
						
</div>