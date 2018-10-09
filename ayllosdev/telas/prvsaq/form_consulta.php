<? 
/*!
 * FONTE        : tab_regional.php				Última alteração: 27/11/2015
 * CRIAÇÃO      : Jéssica - DB1	
 * DATA CRIAÇÃO : 18/09/2015
 * OBJETIVO     : Tabela de Regionais
 * --------------
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
 *                              (Adriano). 
 *
 *                 29/05/2018 - Incluido novos campos PRJ 420 - Mateus Z (Mouts).
 *
 *                 05/10/2018 - Incluido coluna Hora Saque na opção Consulta - Mateus Z (Mouts).
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');		
	isPostMethod();	
 
?>
<form id="frmConsulta" name="frmConsulta" class="formulario">		
	<div id="divConsulta" >		
		<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
			<div id="tabConsulta" style="display:block">
				<div class="divRegistros" id="divRegistros">
					<table id="tabConsulta" class="tituloRegistros">
						<thead>
							<tr>
								<? if($cddopcao == 'C'){ ?>
									<th><? echo utf8ToHtml('Cooperativa');?></th>
									<th><? echo utf8ToHtml('Data Saque');?></th>
									<th><? echo utf8ToHtml('Hora Saque');?></th>
									<th><? echo utf8ToHtml('PA Saque');?></th>				
									<th><? echo utf8ToHtml('CPF/CNPJ Titular');?></th>
									<th><? echo utf8ToHtml('Nome Titular');?></th>
									<th><? echo utf8ToHtml('Conta/dv');?></th>
									<th><? echo utf8ToHtml('Valor');?></th>
									<th><? echo utf8ToHtml('Situação');?></th>
									<th><? echo utf8ToHtml('Obs.');?></th>
								<? }else if($cddopcao == 'A'){ ?>
									<th><? echo utf8ToHtml('Cooperativa');?></th>
									<th><? echo utf8ToHtml('Data Saque');?></th>
									<th><? echo utf8ToHtml('PA Saque');?></th>
									<th><? echo utf8ToHtml('CPF/CNPJ Titular');?></th>
									<th><? echo utf8ToHtml('Nome Titular');?></th>
									<th><? echo utf8ToHtml('Conta/dv');?></th>
									<th><? echo utf8ToHtml('Valor');?></th>
									<th><? echo utf8ToHtml('Situação');?></th>
									<th><? echo utf8ToHtml('Protocolo');?></th>							
								<? }else {?>
									<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
									<th><? echo utf8ToHtml('Cooperativa');?></th>
									<th><? echo utf8ToHtml('Data Saque');?></th>
									<th><? echo utf8ToHtml('PA Saque');?></th>
									<th><? echo utf8ToHtml('CPF/CNPJ Titular');?></th>
									<th><? echo utf8ToHtml('Nome Titular');?></th>
									<th><? echo utf8ToHtml('Conta/dv');?></th>
									<th><? echo utf8ToHtml('Valor');?></th>
									<th><? echo utf8ToHtml('Situação');?></th>
								<?}?>					
							</tr>
						</thead>
						<tbody>
							<?						
							if ( count($registros) == 0 ) {
								$i = 0;
								// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
								?> <tr>
										<td colspan="<? if($cddopcao == 'E'){echo '9';} else{echo '8';}?>" style="width: 80px; text-align: center;">
											<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
											<b>N&atilde;o h&aacute; registros de Regionais cadastrados.</b>
										</td>
									</tr>							
							<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
							} else {
								for ($i = 0; $i < count($registros->inf); $i++) {
								?>
									<tr >

										<? if($cddopcao == 'E'){echo '<td> <input type="checkbox" id="chExcluir" onclick="selecionaTabela(this)"/> </td>';}?>									
										<td >
											<input type="hidden" id="conteudo"   name="conteudo"   value="<? echo 1; ?>" />
											<input type="hidden" id="cdcooper"   name="cdcooper"   value="<? echo $registros->inf[$i]->cdcooper; ?>"/>
											<input type="hidden" id="dhsaque"    name="dhsaque"    value="<? echo $registros->inf[$i]->dhsaque; ?>"/>
											<input type="hidden" id="nrcpfcgc"   name="nrcpfcgc"   value="<? echo $registros->inf[$i]->nrcpfcgc; ?>"/>
											<input type="hidden" id="nrdconta"   name="nrdconta"   value="<? echo $registros->inf[$i]->nrdconta; ?>"/>
											<input type="hidden" id="vlsaque"    name="vlsaque"    value="<? echo $registros->inf[$i]->vlsaque; ?>"/>
											<input type="hidden" id="insit"      name="insit"      value="<? echo $registros->inf[$i]->insit_provisao; ?>"/>
											<input type="hidden" id="tpprovisao" name="tpprovisao" value="<? echo $registros->inf[$i]->tpprovisao; ?>"/>

											<input type="hidden" id="hnrcpfsacpag" name="hnrcpfsacpag" value="<? echo $registros->inf[$i]->nrcpf_sacador; ?>"/>
											<input type="hidden" id="hcdoperacad"  name="hcdoperacad"  value="<? echo $registros->inf[$i]->cdoperad; ?>"/>
											<input type="hidden" id="hdthoracad"   name="hdthoracad"   value="<? echo $registros->inf[$i]->dhcadastro; ?>"/>
											<input type="hidden" id="hcdoperalt"   name="hcdoperalt"   value="<? echo $registros->inf[$i]->cdoperad_alteracao; ?>"/>
											<input type="hidden" id="hdthoralt"    name="hdthoralt"    value="<? echo $registros->inf[$i]->dhalteracao; ?>"/>
											<input type="hidden" id="hcdopercanc"  name="hcdopercanc"  value="<? echo $registros->inf[$i]->cdoperad_cancelamento; ?>"/>
											<input type="hidden" id="hdthoracanc" name="hdthoracanc"   value="<? echo $registros->inf[$i]->dhcancelamento; ?>"/>
											<input type="hidden" id="htxtfinpagto" name="htxtfinpagto" value="<? echo $registros->inf[$i]->dsfinalidade; ?>"/>
											<input type="hidden" id="htxtobservacao" name="htxtobservacao" value="<? echo $registros->inf[$i]->dsobervacao; ?>"/>
											<input type="hidden" id="nmsacador"  name="nmsacador"  value="<? echo $registros->inf[$i]->nmsacador; ?>"/>
											<input type="hidden" id="cdagenci_saque"  name="cdagenci_saque"  value="<? echo $registros->inf[$i]->cdagenci_saque; ?>"/>
											<input type="hidden" id="inoferta"  name="inoferta"  value="<? echo $registros->inf[$i]->inoferta; ?>"/>
											<input type="hidden" id="dsprotocolo"  name="dsprotocolo"  value="<? echo $registros->inf[$i]->dsprotocolo; ?>"/>
											
											<?
												if($cddopcao != 'A'){
													echo $registros->inf[$i]->nmcoop; 
												}else{
													echo stringTabela($registros->inf[$i]->nmcoop,12,'maiuscula');
												}												
											?>
										</td>
										<td>
											<?
												if($cddopcao != 'A'){
													echo substr($registros->inf[$i]->dhsaque,0,10);
												}else{
													echo substr($registros->inf[$i]->dhsaque,0,10);
												}
											?>										
										</td>
										<? if($cddopcao == 'C'){ ?>
												<td>
													<? echo substr($registros->inf[$i]->dhsaque,11,20); ?>
												</td>
										<? } ?>													
										<td>
											<?
												if($cddopcao != 'A'){
													echo $registros->inf[$i]->cdagenci_saque;
												}else{
												 	echo $registros->inf[$i]->cdagenci_saque;
												}
											?>										
										</td>																						
										<td>
											<? 	if($cddopcao != 'A'){
													echo $registros->inf[$i]->nrcpfcgc;
												}else{
													echo $registros->inf[$i]->nrcpfcgc;
												}
											?>
										</td>
										<td>
											<? 	if($cddopcao == 'C'){
													echo stringTabela($registros->inf[$i]->nmtitular_saque,20,'maiuscula');
												}else if($cddopcao == 'A'){
													echo stringTabela($registros->inf[$i]->nmtitular_saque,12,'maiuscula');
												}else{
													echo stringTabela($registros->inf[$i]->nmtitular_saque,28,'maiuscula');
												}
											?>
										</td>
										<td>
											<? 	echo $registros->inf[$i]->nrdconta; ?>
										</td>
										<td>
											<?
												if($cddopcao != 'A'){
													echo $registros->inf[$i]->vlsaque;
												}else{
													echo $registros->inf[$i]->vlsaque;
												}
											?>
										</td>
										<td>
											<?
												if($cddopcao == 'C'){
													echo $registros->inf[$i]->nmsit_provisao;
												}else{
													echo $registros->inf[$i]->nmsit_provisao;
												}
											?>										
										</td>
										<?	if($cddopcao != 'E'){ ?>
											<td>
												<?	if($cddopcao == 'C'){
														echo $registros->inf[$i]->dsobservacao;
													}else if($cddopcao == 'A'){
														
														echo $registros->inf[$i]->dsprotocolo;
													}
												?>
											</td>	
										<? } ?>									
									</tr>
								<? } ?>
							<? } ?>					
						</tbody>
					</table>
				</div>
				<div id="divRegistrosRodape" class="divRegistrosRodape">
					<table>
						<tr>
							<td>
								<?	
									if ($qtregist == 0) $nriniseq = 0;
								
									if ($nriniseq > 1) {
										?> <a class='paginacaoAnt'><<< Anterior</a> <?
									} else {
										?> &nbsp; <?
									}
								?>
							</td>
							<td id="tdPaginacao">
								<?
									if ($nriniseq) {
										?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<?  } ?>
							</td>
							<td>
								<!-- Mostrar o total dos valores da pagina -->
								<span style="font-weight: bold;"><? echo utf8ToHtml('Valor total página:') ?> <? echo $vlsaque_tot; ?></span>
							</td>
							<td>
								<?
									if ($qtregist > ($nriniseq + $nrregist - 1)) {
										?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
									} else {
										?> &nbsp; <?
									}
								?>
							</td>
						</tr>
					</table>					
				</div>
			</div>

			<div id="divDadosExc" style="display:none">
				<fieldset>
					<label for="nrCpfSacPag"><? echo utf8ToHtml('CPF do sacador:') ?></label>
					<input id="nrCpfSacPag" name="nrCpfSacPag" type="text" disabled maxlength="14" class="campo cpf" value="<? echo utf8ToHtml($nrCpfSacPag); ?>"/>
					<label for="nmSacador"><? echo utf8ToHtml('Nome do Sacador:') ?></label>
					<input id="nmSacador" name="nmSacador" type="text" disabled maxlength="14" class="campo cpf" value="<? echo utf8ToHtml($nmSacador); ?>"/>

					<label for="nrPA"><? echo utf8ToHtml('PA do saque:') ?></label>
					<input id="nrPA" name="nrPA" type="text" disabled class="campo codigo" maxlength="5" value="<? echo utf8ToHtml($nrPA); ?>"/>

					<label for="dhsaque"><? echo utf8ToHtml('Data/hora do saque:') ?></label>
					<input id="dhsaque" name="dhsaque" type="text" disabled maxlength="20" class="campo data" value="<? echo utf8ToHtml($dhsaque); ?>"/>

					<label for="cdoperacad"><? echo utf8ToHtml('Operador Cadastro:') ?></label>
					<input id="cdoperacad" name="cdoperacad" type="text"  disabled class="campo" value="<? echo utf8ToHtml($cdoperacad); ?>"/>

					<label for="dthoracad"><? echo utf8ToHtml('Data/hora:') ?></label>
					<input id="dthoracad" name="dthoracad" type="text" disabled maxlength="20" class="campo data" value="<? echo utf8ToHtml($dthoracad); ?>"/>

					<label for="cdoperalt"><? echo utf8ToHtml('Operador alteração:') ?></label>
					<input id="cdoperalt" name="cdoperalt" type="text" disabled maxlength="14" class="campo" value="<? echo utf8ToHtml($cdoperalt); ?>"/>

					<label for="dthoraalt"><? echo utf8ToHtml('Data/hora:') ?></label>
					<input id="dthoraalt" name="dthoraalt" type="text" disabled maxlength="14" class="campo data" value="<? echo utf8ToHtml($dthoraalt); ?>"/>

					<label for="cdopercanc"><? echo utf8ToHtml('Operador cancelamento:') ?></label>
					<input id="cdopercanc" name="cdopercanc" type="text" disabled maxlength="14" class="campo" value="<? echo utf8ToHtml($cdopercanc); ?>"/>

					<label for="dthoracanc"><? echo utf8ToHtml('Data/hora:') ?></label>
					<input id="dthoracanc" name="dthoracanc" type="text" disabled maxlength="14" class="campo data" value="<? echo utf8ToHtml($dthoracanc); ?>"/>

					<label for="inoferta" id="inoferta"><? echo utf8ToHtml('Foi ofertado outros meios de transações:') ?></label>
					<select id="inoferta" name="inoferta" disabled class="campo" style="width: 90px;">						
						<option value="SIM" selected><? echo utf8ToHtml('Sim') ?></option>
						<option value="NAO"><? echo utf8ToHtml('Não') ?></option>		
					</select>

					<br style="clear:both" />

					<label for="lbtxtFinPagto" id="lbTxtFinPgtoCons"><? echo utf8ToHtml('Finalidade do saque:') ?></label>
					<textarea name="txtFinPagto" id="txtFinPagto" disabled class="campo alphanum" style="overflow-y: scroll; overflow-x: hidden; width: 665px; height: 100px; margin-left:10px;margin-right:10px;" ><?php echo trim($txtFinPagto) ?></textarea>

					<label for="lbtxtObservacao" id="lbtxtObservacaoCons"><? echo utf8ToHtml('Observação:') ?></label>
					<textarea name="txtObservacao" id="txtObservacao" disabled class="campo alphanum" style="overflow-y: scroll; overflow-x: hidden; width: 665px; height: 100px; margin-left:10px;margin-right:10px;" ><?php echo trim($txtObservacao) ?></textarea>
				</fieldset>
			</div>
			<div id="divDadosAlt" style="display:none">				
				<label for="dtSaqPagtoAlt" id="lbDtSaqPagtoAlt"><? echo utf8ToHtml('Data do saque:') ?></label>
				<input id="dtSaqPagtoAlt" name="dtSaqPagtoAlt" class='campo data' type="text" onblur="validarData('alteracao');" value="<? echo utf8ToHtml($dtSaqPagto); ?>"/>

				<label for="hrSaqPagtoAlt" id="lbHrSaqPagtoAlt"><? echo utf8ToHtml('Horário saque:') ?></label>
				<input id="hrSaqPagtoAlt" name="hrSaqPagtoAlt" class="campo" type="time" maxlength="5" value="<? echo utf8ToHtml($hrSaqPagto); ?>"/>

				<label for="vlSaqPagtoAlt" id="lbVlSaqPagtoAlt"><? echo utf8ToHtml('Valor saque:') ?></label>
				<input id="vlSaqPagtoAlt" name="vlSaqPagtoAlt" class='campo' type="text" value="<? echo utf8ToHtml($vlSaqPagto); ?>"/>

				<label for="tpSituacaoAlt" id="lbTpsituacaoAlt"><? echo utf8ToHtml('Situação:') ?></label>
				<select id="tpSituacaoAlt" name="tpSituacaoAlt" class="campo" style="width: 90px;">						
					<option value="1" selected><? echo utf8ToHtml('Pendente') ?></option>
					<option value="2"><? echo utf8ToHtml('Realizada') ?></option>		
				</select>

				<!-- PRJ 420 -->	
				<input type="hidden" id="dsprotocolo" name="dsprotocolo">

				<!-- guardar os valores ogirinais -->
				<input type="hidden" id="cdcooperOri" name="cdcooper"/>
				<input type="hidden" id="dhsaqueOri"  name="dhsaque"/>
				<input type="hidden" id="nrcpfcgcOri" name="nrcpfcgc"/>
				<input type="hidden" id="nrdcontaOri" name="nrdconta"/>

				<input type="hidden" id="vlsaqpagtoOri" name="cdcooper"/>
				<input type="hidden" id="tpsituacaoOri"  name="dhsaque"/>					
				<input type="hidden" id="tpprovisao"  name="dhsaque"/>		
			</div>
		</div>	
	</fieldset>
</form>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		manter_rotina('<?=$cddopcao?>', <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		manter_rotina('<?=$cddopcao?>', <? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divRegistrosRodape','#divTela').formataRodapePesquisa();
</script>
