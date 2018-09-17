<?
/*!
 * FONTE        : tab_cheque.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)						Última alteração: 24/06/2016
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Tabela que apresenda os dados da remessa da tela PESQSR
 *
 * ALTERACOES   : 19/08/2015 - Retirar campo secao (Gabriel-RKAM)

			      24/062016 - Ajustes referente a homologação da tela para liberação 
                              (Adriano - SD 412556).
 *
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

 ?>

 <form id="frmCheques" name="frmCheques" class="formulario">
	<fieldset>
		<legend>Cheques</legend>

		 <div class="divRegistros">
			<table>
				<thead>
					<tr><th>Sequência</th>
						<th>Data Devolução</th>
						<th>Alínea</th>
					</tr>
				</thead>
				<tbody>
					<?         
					$cont = 0;
			
					foreach($anteriores as $browse) {
						// Recebo todos valores em variáveis
						$nrseqchq	= getByTagName($browse->tags,'nrseqchq');
						$dtmvtolt	= getByTagName($browse->tags,'dtmvtolt');
						$cdalinea	= getByTagName($browse->tags,'cdalinea');
						?>
						<tr>
							<td>
								<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($registros[$cont]->tags,'dtmvtolt') ?>" />
								<input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($registros[$cont]->tags,'cdagenci') ?>" />
								<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($registros[$cont]->tags,'cdbccxlt') ?>" />
								<input type="hidden" id="nrdolote" name="nrdolote" value="<? echo mascara(getByTagName($registros[$cont]->tags,'nrdolote'),'###.###') ?>" />
								<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo mascara(getByTagName($registros[$cont]->tags,'nrdconta'),'####.###.#') ?>" />
								<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo mascara(getByTagName($registros[$cont]->tags,'nrdocmto'),'#.###.###.#')?>" />
								<input type="hidden" id="nrdctabb" name="nrdctabb" value="<? echo mascara(getByTagName($registros[$cont]->tags,'nrdctabb'),'#.###.###.#')?>" />
								<input type="hidden" id="cdbaninf" name="cdbaninf" value="<? echo getByTagName($registros[$cont]->tags,'cdbaninf') ?>" />
								<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo formataMoeda(getByTagName($registros[$cont]->tags,'vllanmto')) ?>" />
						
								<input type="hidden" id="nrseqimp" name="nrseqimp" value="<? echo getByTagName($registros[$cont]->tags,'nrseqimp') ?>" />						
								<input type="hidden" id="cdpesqbb" name="cdpesqbb" value="<? echo getByTagName($registros[$cont]->tags,'cdpesqbb') ?>" />
								<input type="hidden" id="vldoipmf" name="vldoipmf" value="<? echo formataMoeda(getByTagName($registros[$cont]->tags,'vldoipmf')) ?>" />
						
								<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($registros[$cont]->tags,'nmprimtl') ?>" />
								<input type="hidden" id="dsagenci" name="dsagenci" value="<? echo getByTagName($registros[$cont]->tags,'dsagenci') ?>" />
								<input type="hidden" id="cdturnos" name="cdturnos" value="<? echo getByTagName($registros[$cont]->tags,'cdturnos') ?>" />
								<input type="hidden" id="nrfonemp" name="nrfonemp" value="<? echo getByTagName($registros[$cont]->tags,'nrfonemp') ?>" />
								<input type="hidden" id="nrramemp" name="nrramemp" value="<? echo getByTagName($registros[$cont]->tags,'nrramemp') ?>" />
								<input type="hidden" id="cdbanchq" name="cdbanchq" value="<? echo getByTagName($registros[$cont]->tags,'cdbanchq') ?>" />
								<input type="hidden" id="cdagechq" name="cdagechq" value="<? echo getByTagName($registros[$cont]->tags,'cdagechq') ?>" />
								<input type="hidden" id="cdcmpchq" name="cdcmpchq" value="<? echo getByTagName($registros[$cont]->tags,'cdcmpchq') ?>" />
								<input type="hidden" id="nrlotchq" name="nrlotchq" value="<? echo getByTagName($registros[$cont]->tags,'nrlotchq') ?>" />
								<input type="hidden" id="sqlotchq" name="sqlotchq" value="<? echo getByTagName($registros[$cont]->tags,'sqlotchq') ?>" />
								<input type="hidden" id="nrctachq" name="nrctachq" value="<? echo getByTagName($registros[$cont]->tags,'nrctachq') ?>" />

								<? echo $nrseqchq ?>                                         
							</td>                                                            

							<td> <? echo $dtmvtolt ?> </td>                                  
							<td> <? echo $cdalinea ?> </td>                                  

						</tr>
					<? $cont++; // Progressivo
					}  ?>

				</tbody>
			</table>
		</div>
	</fieldset>
</form>

