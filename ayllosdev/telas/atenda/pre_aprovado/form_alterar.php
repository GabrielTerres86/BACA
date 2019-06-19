<?php
/*!
 * FONTE        : form_motivos.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : FormulÃ¡rio da rotina Alterar Motivos da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
 
$ultimoHistorico = $xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[4]->tags[0]; // para os ultimos valores para se alterar
?>
<form name="frmPreAprovadoAltera" id="frmPreAprovadoAltera" class="formulario" >
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td>
				<fieldset>
					<legend>Pré-aprovado Carga Manual:</legend>
					<table width="100%">
						<tr>
							<td>
								<label for="statusCarga">Situação da carga manual:</label>
								<input type="text" id="statusCarga" name="statusCarga" value="<? echo ucfirst($xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[11]->cdata); ?>" />
							</td>
						</tr>
						<tr>
							<td>
								<label for="idCarga">Identificação da carga:</label>
								<input type="text" id="idCarga" name="idCarga" />
							</td>
						</tr>
						<tr>
							<td>
								<label for="vigInicial">Vigência da Carga:</label>
								<input type="text" id="vigInicial" name="vigInicial" />
								<label for="vigFinal">Até</label>
								<input type="text" id="vigFinal" name="vigFinal" />
							</td>
						</tr>
					</table>
				</fieldset>
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Alterar:</legend>
					<table width="100%">
						<tr>
							<td>
								<label for="flglibera">Bloqueio Manual de Pré-aprovado:</label>
								<select id="flglibera" name="flglibera" >
									<option value="" >Selecione</option>
									<option value="0">Sim</option>
									<option value="1">Não</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>
								<label for="idmotivo">Motivo:</label>
								<select id="idmotivo" name="idmotivo">
									<option value="">Selecione</option>	
								</select>
							</td>
						</tr>
						<tr>
							<td>
								<label for="dtatualiza">Vigência do Bloqueio:</label>
								<input id="dtatualiza" name="dtatualiza"/>
								<input type="checkbox" id="chkIndeter" name="chkIndeter"/>
								<label for="chkIndeter">Indeterminado</label> 
							</td>
						</tr>
						<tr>
							<td>
								<div id="divBotoes">
									<a href="#" class="botao" id="btVoltar" onClick="voltaRotina($('#divRotina')); return false;"><? echo ($alterar != 1) ? "Voltar" : "Cancelar"; ?></a>
									<? if ($alterar != 1) { ?>
												<a href="#" class="botao" id="btAlterar" onClick="liberarAltera(); return false;">Alterar</a>
									<? } ?>
									<? if($alterar == 1){ ?>
										<a href="#" class="botao" id="btConcluir" onClick="confirmaAlteracao(); return false;">Concluir</a>
									<? } ?>
								</div>
							</td>
						</tr>
					</table>
				</fieldset>
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Hist&oacute;rico de bloqueios manuais:</legend>
					<div class="divRegistros">
						<table width="100%">
							<thead>
								<tr>
									<th>Operação</th>
									<th>Data Operação</th>
									<th>Vigência do Bloqueio</th>
									<th>Motivo</th>
									<th>Operador</th>
								</tr>
							</thead>
							<tbody>
								<? foreach($xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[4]->tags as $registro) { ?>
									<tr>
										<td><? echo $registro->tags[0]->cdata; ?></td>
										<td><? echo $registro->tags[1]->cdata; ?></td>
										<td><? echo ($registro->tags[2]->cdata == "") ? "Indeterm." : $registro->tags[2]->cdata; ?></td>
										<td><? echo $registro->tags[3]->cdata; ?></td>
										<td><? echo $registro->tags[4]->cdata; ?></td>
									</tr>
								<? } ?>
							</tbody>
						</table>
					</div>
				</fieldset>
			</td>
		</tr>
	</table>
</form>