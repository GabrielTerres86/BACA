<? 
/*!
 * FONTE        : tabela_dependentes.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Tabela que apresenda os DEPENDENTES
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 */	
?>
<form name="frmDependentes" id="frmDependentes" class="formulario">
	<fieldset>
		<legend> Dependentes </legend>
		<div class="divRegistros">

			<table>
				<thead>
					<tr><th>Nome</th>
						<th>Data Nascimento</th>
						<th>Tipo Dependente</th></tr>
				</thead>		
				<tbody>
					<? foreach( $registros as $registro ) {?>
						<tr><td><span><? echo getByTagName($registro->tags,'nmdepend') ?></span>
								<? echo stringTabela(getByTagName($registro->tags,'nmdepend'),27,'maiuscula') ?>
								<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registro->tags,'nrdrowid') ?>" /></td>
							<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtnascto')) ?></span>
								<? echo getByTagName($registro->tags,'dtnascto') ?></td>
							<td><? echo getByTagName($registro->tags,'dstipdep') ?></td></tr>
					<? } ?>			
				</tbody>
			</table>
		</div>

		<div id="divBotoes">
			<?if ( $operacao != "SC" ){?>
			<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacaoDependentes('TA'); return false;" />
			<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacaoDependentes('TE'); return false;" />
			<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacaoDependentes('TI'); return false;" /> 
			<?}else{?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina); return false;" />
			<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="controlaOperacaoDependentes('CF'); return false;" />
			<?}?>
		</div>
	</fieldset>	
</form>
