<? 
 /*!
 * FONTE        : form_orgaos.php
 * CRIAÇÃO      : Jonata-RKAM
 * DATA CRIAÇÃO : 12/09/2014
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * 
 * ALTERACOES   : 07/01/2015 - Projeto Microcredito (Jonata-RKAM).
 *
 *                26/06/2015 - Validar Inf. Cadastrais quando possui consulta ao Conjuge (Gabriel-RKAM). 
 *
 *                01/03/2016 - PRJ Esteira de Credito. (Jaison/Oscar)
 *                 
 *                24/08/2018 - P442 - Novos campos de Escore (Marcos-Envolti)
 */	
  
 include ('protecao_credito.php'); 

 ?>


<form name="frmOrgaos" id="frmOrgaos" class="formulario condensado">	

	<fieldset style="height:500px;">
		<legend> <?php echo utf8ToHtml ('Órgãos de Proteção ao Crédito'); ?> </legend>
	
		<br />
	
		<?php if ($iddoaval_busca > 0) { // Se for avalista ou conjuge ?>
			<?php if ($iddoaval_busca == 99) { ?>
				<label for="nmtitcon"> <? echo utf8ToHtml ('Consulta Cônjuge:'); ?> </label> 
			<? } else { ?>
				<label for="nmtitcon">Dados do Avalista Fiador ( <? echo $iddoaval_busca ?> ) : </label>	
			<? } ?>
			
			<input name="nmtitcon" id="nmtitcon" type="text" value="<? echo $xml_geral->Dados->crapcbd->crapcbd_inf->nmtitcon; ?>" /> 
			
			<br /> <br />	
		
			<label for="dtconbir">Data da Consulta: </label>
			<input name="dtconbir" id="dtconbir" type="text" value="<? echo $xml_geral->Dados->crapcbd->crapcbd_inf->dtconbir; ?>" /> 
			
			<label for="inreapro">Reaproveitamento: </label>
			<input name="inreapro" id="inreapro" type="text" value="<? echo $xml_geral->Dados->crapcbd->crapcbd_inf->inreapro; ?>" /> 
					
		<? } else if ($operacao == 'C_PROTECAO_SOC' || $operacao == 'A_PROTECAO_SOC') { // Socios da empresa ?>
		
			<label for="nrcpfcgc">Socio da empresa: CPF: </label>
			<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo $xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf[$idSocio - 1]->nrcpfcgc; ?>" /> 
		
			<label for="nmtitsoc">Nome: </label>
			<input name="nmtitsoc" id="nmtitsoc" type="text" value="<? echo $xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf[$idSocio - 1]->nmtitcon; ?>" /> 
		
		<? } else { // Titular ?>

			<label for="nrinfcad">Inf. cadastrais: </label>
			<input name="nrinfcad" id="nrinfcad" type="text" value="<? echo $nrinfcad; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsinfcad" id="dsinfcad" type="text" value="<? echo $dsinfcad; ?>" />
							
			<br /> <br />	
					
			<label for="dtcnsspc">Data da Consulta: </label>
			<input name="dtcnsspc" id="dtcnsspc" type="text" class="data" value="<? echo $dtcnsspc; ?>" />
			
			<label for="inreapro">Reaproveitamento: </label>
			<input name="inreapro" id="inreapro" type="text" value="<? echo $xml_geral->Dados->crapcbd->crapcbd_inf->inreapro; ?>" />
		
		<? } ?>
		
		<br/><br/><br/>
			
		<label for="dtdrisco">Consulta SCR: </label>
		<input name="dtdrisco" id="dtdrisco" type="text" value="<? echo $dtdrisco; ?>" /> 
		
		<label for="qtopescr">Qtd Operacoes: </label>
		<input name="qtopescr" id="qtopescr" type="text" value="<? echo formataNumericos('z.zz9',$qtopescr); ?>" /> 
			
		<label for="qtifoper">Qtd. IF com ope.: </label>
		<input name="qtifoper" id="qtifoper" type="text" value="<? echo formataNumericos('z.zz9',$qtifoper); ?>" /> 
		
		<br />
			
		<label for="vltotsfn">Endividamento: </label>
		<input name="vltotsfn" id="vltotsfn" type="text" value="<? echo formataMoeda($vltotsfn); ?>" /> 
		
		<label for="vlopescr">Vencidas: </label>
		<input name="vlopescr" id="vlopescr" type="text" value="<? echo formataMoeda($vlopescr); ?>" /> 
			
		<label for="vlrpreju">Prej.: </label>
		<input name="vlrpreju" id="vlrpreju" type="text" value="<? echo formataMoeda($vlrpreju); ?>" /> 
			
		<br/><br/><br/>
		
		<? if (count($xml_geral->Dados->crapcbd) > 0 ) { ?>
			<label for="dsconsul">Consulta <? echo $dsconsul . '-' . $dsmodbir; ?> </label>
		<? } ?>
		<? 
			if(count($xml_geral->Dados->crapesc) > 0)
			{ 
		?>
				<br/><br/>
				<label for="dsnegati"> </label>
				<label for="qtnegati_coluna"> <? echo utf8ToHtml ('Descrição'); ?>  </label>
				<label for="vlnegati_coluna"> <? echo utf8ToHtml ('Pontuação'); ?> </label>
			<?	
				$crapescinfo =$xml_geral->Dados->crapesc->crapesc_inf;
				$dsescore = $crapescinfo->dsescore;
				$vlpontua = $crapescinfo->vlpontua;
			?>
				<label for="dsnegati"> </label>
				<input name="qtnegati_coluna" id="qtnegati_coluna" type="text" value="<? echo $dsescore; ?>" /> 			
				<input name="vlnegati_coluna" id="vlnegati_coluna" type="text" value="<? echo $vlpontua; ?>" /> 
				<br/><br/>
		<?
			}
			
		?>
		<br/> <br/> 
			 	
		<? if ($cdbircon == 1 ) { // SPC 
		
			if (count($xml_geral->Dados->craprsc) > 0 ) { ?>
							
				<? $qtnegati = ($xml_geral->Dados->craprsc->contador == 0)        ? 'Nada consta' : $xml_geral->Dados->craprsc->contador; 
				   $vlnegati = ($qtnegati == 'Nada consta') ? '' : formataMoeda(str_replace ('.',',',str_replace(',','',trim($xml_geral->Dados->craprsc->vlregist_tot))));  ?>
				
				<label for="dsnegati"> </label>
				<label for="qtnegati_coluna"> Quantidade  </label>
				<label for="vlnegati_coluna"> Valor       </label>

				<br/><br/> 				
								
				<label for="dsnegati"> SPC </label>				
				<input name="qtnegati_coluna" id="qtnegati_coluna" type="text" value="<? echo $qtnegati; ?>" /> 
				<input name="vlnegati_coluna" id="vlnegati_coluna" type="text" value="<? echo $vlnegati; ?>" /> 
			
				<br/>
			
			<? }

			if (count($xml_geral->Dados->craprpf->craprpf_inf) > 0) {
			
				// Somar PEFIN e REFIN 
				$qtnegati = 0;
				$vlnegati = 0;
			
				for ($i= 0; $i < count($xml_geral->Dados->craprpf->craprpf_inf); $i++) { 
					$craprpf = $xml_geral->Dados->craprpf->craprpf_inf[$i]; 
				
					if ($craprpf->innegati == '1' || $craprpf->innegati == '2') { 		
						if (is_numeric(trim($craprpf->qtnegati))) {
							$qtnegati = $qtnegati + intval($craprpf->qtnegati);
						}	
						if (trim($craprpf->vlnegati) != '') {
							$vlnegati = $vlnegati + floatval(str_replace(',','',trim($craprpf->vlnegati)));
						}
					}
				}	
				
				$qtnegati = ($qtnegati == 0) ? 'Nada consta' : $qtnegati;
				
				if ($xml_geral->Dados->craprpf->craprpf_inf[0]->vlnegati == '' &&  
				    $xml_geral->Dados->craprpf->craprpf_inf[1]->vlnegati == '') {
					$vlnegati = '';
				}	
				else {
					$vlnegati = formataMoeda(str_replace ('.',',',str_replace(',','',trim($vlnegati))));
				}
				
				?>
						
				<label for="dsnegati"> Pefin/Refin </label>
				
				<input name="qtnegati_coluna" id="qtnegati_coluna" type="text" value="<? echo $qtnegati; ?>" /> 		
				<input name="vlnegati_coluna" id="vlnegati_coluna" type="text" value="<? echo $vlnegati ?>" /> 
				
				<br/>
			
			<? } ?>
		
		<? }
		
		if ($cdbircon == 2) { // Serasa PF e PJ		
		?>
			<label for="dsnegati"> </label>
			<label for="qtnegati_coluna"> Quantidade  </label>
			<label for="vlnegati_coluna"> Valor total </label>
			<label for="dtultneg_coluna"> <? echo utf8ToHtml ('Data última'); ?> </label>

			<br /> <br />
			
		<? } 
		
		if ($operacao == 'C_PROTECAO_SOC' || $operacao == 'A_PROTECAO_SOC') { // Socios da empresa 
			$dados_anotacoes = $xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf[$idSocio - 1]->craprpf_soc->craprpf_soc_inf;
		}
		else { // Titular, Conjuge ou Avalista
			$dados_anotacoes = $xml_geral->Dados->craprpf->craprpf_inf;
		}
		
		?>
		
		<!-- Anotacoes -->
		<? for ($i= 0; $i < count($dados_anotacoes); $i++) { 
			
			$craprpf = $dados_anotacoes[$i]; 

			if ($cdbircon == 1) { // SPC
				if ($craprpf->innegati != 03 && $craprpf->innegati != 06) {
					continue;
				}	
					
				if ($craprpf->vlnegati != '') {
					$vlnegati =  formataMoeda(str_replace ('.',',',str_replace(',','',trim($craprpf->vlnegati))));
				} else {
					$vlnegati = '';
				}
			?>
				<label for="dsnegati"> <? echo $craprpf->dsnegati ?> </label>
				<input name="qtnegati_coluna" id="qtnegati_coluna" type="text" value="<? echo $craprpf->qtnegati; ?>" /> 			
				<input name="vlnegati_coluna" id="vlnegati_coluna" type="text" value="<? echo $vlnegati; ?>" /> 	
				
				<br/>
		
			<? } 
			
			if ($cdbircon == 2) { // Serasa PF e PJ
				if (in_array($craprpf->innegati ,array('2','3','6','1','4','5','7','10','11')) == false) {					
					continue;
				}

				if ($craprpf->vlnegati != '') {
					$vlnegati = formataMoeda(str_replace ('.',',',str_replace(',','',trim($craprpf->vlnegati))));
				} else {
					$vlnegati = '';
				}
				
				?>
			
				<label for="dsnegati"> <? echo utf8ToHtml($craprpf->dsnegati) ?> </label>
				<input name="qtnegati_coluna" id="qtnegati_coluna" type="text" value="<? echo $craprpf->qtnegati; ?>" />
				<input name="vlnegati_coluna" id="vlnegati_coluna" type="text" value="<? echo $vlnegati; ?>" /> 
				<input name="dtultneg_coluna" id="dtultneg_coluna" type="text" value="<? echo $craprpf->dtultneg; ?>" /> 

		<?	} ?>		
			
		
	<? } 
	
	if  ($cdbircon == 1 ) { ?>
		<div style="height:105px"></div>
	<? } ?>
				
	</fieldset>
 
	<div id="divBotoes">  

		<? if ($nomeAcaoCall == 'A_AVALISTA') {
            ?><input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="fechaAvalista(); return false;" /><?
        } else {
            ?><input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('<? echo $cddopcao ?>_INICIO'); return false;" /><?
        } ?>

		<? if ( $operacao == 'A_PROTECAO_AVAL' ){ // Consulta dos orgaos para o avalista
            ?><input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('<?php echo ($nomeAcaoCall == 'A_AVALISTA' && $iddoaval_busca == 2 ? 'F_AVALISTA' : 'A_DADOS_AVAL'); ?>'); return false;" /><?
		} 
		else if ($operacao == 'A_PROTECAO_TIT' || $operacao == 'A_PROTECAO_SOC') { // Alteracao dos orgaos para o titular 
			
			if ($cdbircon == 2 && $inpessoa_busca == 2 ) { ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaSocios('<? echo $operacao; ?>' , <? echo $glbvars["cdcooper"]; ?>  , <? echo ($idSocio + 1) ?> , <? echo count($xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf); ?>);  return false;" /> 		
			<? } else if ($inconcje == 1) { ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaItensRating('A_PROTECAO_TIT_CONJ', true);  return false;" /> 
			<? } else { ?>
				<? if ($inprodut == 1 ) { // Emprestimo  ?>
					<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="atualizaArray('A_BUSCA_OBS' , ' <?php echo $glbvars["cdcooper"]; ?> '); return false;" /> 
				<? } else { // Limite ?>
					<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('A_COMITE_APROV'); return false;" /> 
				<? } ?>
			<? } ?>		
		<? }
		else if ($operacao == "I_PROTECAO_TIT") { ?>
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaItensRating('I_PROTECAO_TIT' , true); return false;" />
		<? }
		else if ($operacao == 'A_PROTECAO_CONJ') { // Consulta para o conjuge ?>
		
			<? if ($inprodut == 1 ) { // Emprestimo  ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="atualizaArray('A_BUSCA_OBS' , ' <?php echo $glbvars["cdcooper"]; ?> '); return false;" /> 
			<? } else { // Limite ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('A_AVAIS'); return false;" /> 
			<? } ?>
				
		<? } 
		else
		if ($operacao == 'C_PROTECAO_AVAL' ) { // Consulta dos orgaos para o avalista  ?>
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_DADOS_AVAL');  return false;" />
		<? } 
		else if ($operacao == 'C_PROTECAO_TIT' || $operacao == 'C_PROTECAO_SOC') { // Consulta para o titular 
		
			if ($cdbircon == 2 && $inpessoa_busca == 2 ) { ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaSocios('<? echo $operacao; ?>' , <? echo $glbvars["cdcooper"]; ?> , <? echo ($idSocio + 1) ?> , <? echo count($xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf); ?>); return false;" /> 
			<? } else if ($inconcje == 1) { ?>
				<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_PROTECAO_CONJ');  return false;" /> 
			<? } else { ?>
					<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_COMITE_APROV'); return false;" /> 
			<? } ?>
		
		<? } 
		else
		if ($operacao == 'C_PROTECAO_CONJ') { // Consulta para o conjuge ?>
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_COMITE_APROV'); return false;" /> 
		<? } 
		else if ($operacao == 'C_PROTECAO_AVAL_2') { // Consulta Aval 2 no Limite de credito   ?>
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="acessaOpcaoAba(8, 0, '@'); return false;" /> 
		<? } 
		else if ($operacao == 'A_PROTECAO_AVAL_2') { // Alteracao Aval 2 no limite de credito ?>
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="buscaGrupoEconomico(); return false;" /> 
		<? } ?>
	</div>

</form>

<script>
	
	$(document).ready(function() {
		 highlightObjFocus($('#frmOrgaos'));		 
	});
</script>	