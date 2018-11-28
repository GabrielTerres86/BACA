<?php
	/*!
	* FONTE        : form_manter.php
	* CRIAÇÃO      : Jéssica (DB1)
	* DATA CRIAÇÃO : 30/09/2013
	* OBJETIVO     : Formulario de alteração e inclusão dos históricos da Tela HISTOR
	* --------------
	* ALTERAÇÕES   : 24/02/2017 - Remocao dos caracteres "')?>" dos textos dos campos no form. (Jaison/James)
	*				 05/12/2017 - Adicionado campo Ind. Monitoramento - Melhoria 458 - Antonio R. Jr (mouts)
	*                26/03/2018 - PJ 416 - BacenJud - Incluir o campo de inclusão do histórico no bloqueio judicial - Márcio - Mouts
	*                11/04/2018 - Incluído novo campo "Estourar a conta corrente" (inestocc)
    *                             Diego Simas - AMcom  
	*                16/05/2017 - Ajustes prj420 - Resolucao - Heitor (Mouts)
	*
	*                11/06/2018 - Alterado o label "Estourar a conta corrente" para 
	*							  "Debita após o estouro de conta corrente (60 dias)".
	*							  Diego Simas (AMcom) - Prj 450
	*							  			
	*			     18/07/2018 - Alterado para esconder o campo referente ao débito após o estouro de conta  
    * 		   				   	  Criado novo campo "indebprj", indicador de débito após transferência da CC para Prejuízo
    * 							  PJ 450 - Diego Simas - AMcom	

	*				 08/08/2018 - Adicionado TBDSCT_LANCAMENTO_BORDERO na estrutura - Luis Fernando (GFT)
	*                
	*                23/11/2018 - Implantacao do Projeto 421, parte 2
    *                             Heitor (Mouts)
	*							  			
	* --------------
	*/ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$nmestrutLst = array(
		'CRAPCBB',
		'CRAPCHD',
		'CRAPLAC',
		'CRAPLAP',
		'CRAPLCI',
		'CRAPLCM',
		'CRAPLCS',
		'CRAPLCT',
		'CRAPLCX',
		'CRAPLEM',
		'CRAPLFT',
		'CRAPLGP',
		'CRAPLPI',
		'CRAPLPP',
		'CRAPLTR',
		'CRAPTIT',
		'CRAPTVL',
		'TBCC_PREJUIZO_LANCAMENTO',
		'TBDSCT_LANCAMENTO_BORDERO',
        'TBCC_PREJUIZO_DETALHE'
	);
	
	$dsestrutLst = array(
		'CRAPCBB - Movimentos Correspondente Bancario - Banco do Brasil',
		'CRAPCHD - Cheques acolhidos para depositos nas contas dos associados',
		'CRAPLAC - Lancamento de aplicacao da captacao',
		'CRAPLAP - Cadastro dos lancamentos de aplicacoes RDCA',
		'CRAPLCI - Lancamentos da conta investimento',
		'CRAPLCM - Lancamentos em depositos a vista',
		'CRAPLCS - Lancamentos dos funcionarios que optaram por transferir salario para outra instituicao',
		'CRAPLCT - Lancamentos de cotas/capital',
		'CRAPLCX - Contem os lancamentos extra-sistema que compoem o boletim de caixa',
		'CRAPLEM - Lancamentos em emprestimos',
		'CRAPLFT - Lancamentos de faturas',
		'CRAPLGP - Lancamentos das Guias da Previdencia Social',
		'CRAPLPI - Lancamentos dos pagamentos do INSS',
		'CRAPLPP - Cadastro de lancamentos de aplicacoes de poupanca programada',
		'CRAPLTR - Log das transacoes efetuadas nos caixas e cash dispensers',
		'CRAPTIT - Titulos acolhidos',
		'CRAPTVL - Tranferencia de valores (DOC C, DOC D E TEDS)',
		'TBCC_PREJUIZO_LANCAMENTO - Lancamentos bloqueados por conta em prejuizo',
		'TBDSCT_LANCAMENTO_BORDERO - Lancamentos contabeis em Limite Desconto Titulo',
        'TBCC_PREJUIZO_DETALHE - Lancamentos detalhados do extrato do prejuizo'
	);
	
	$tplotmovLst = array(
		'0',
		'1',
		'2',
		'3',
		'4',
		'5',
		'6',
		'7',
		'8',
		'9',
		'10',
		'11',
		'12',
		'13',
		'14',
		'15',
		'16',
		'17',
		'18',
        '19',
		'20',
		'21',
		'22',
		'23',
		'24',
		'25',
		'28',
		'29',
		'30',
		'31',
		'32',
		'122',
		'124',
		'125'
	);
	
	$dslotmovLst = array(
		'0 - Generico',
		'1 - Deposito a Vista',
		'2 - Capital',
		'3 - Pagto de Planos de Cotas',
		'4 - Contratos de Emprestimos',
		'5 - Lancamentos de Emprestimos',
		'6 - FORA DE USO',
		'7 - FORA DE USO',
		'8 - Contratos de Planos de Cotas',
		'9 - Aplicacoes RDC',
		'10 - Aplicacoes RDCA 30/60',
		'11 - Resgates de Aplicacoes',
		'12 - Lancamentos Automaticos',
		'13 - Faturas (SAMAE, TELESC, etc)',
		'14 - Poupanca Programada',
		'15 - Seguros',
		'16 - Proposta Cartao CREDICARD',
		'17 - Debitos de Cartao de Credito',
		'18 - Lancamentos de Cobrancas',
		'19 - Custodia de Cheques',
		'20 - Titulos',
		'21 - Impostos PREFEITURA DE BLUMENAU',
		'22 - Reservado para o SISTEMA - Caixa on-line (craplcx)',
		'23 - Captura de cheques',
		'24 - DOC',
		'25 - TED',
		'28 - COBAN',
		'29 - Lancamentos da conta investimento (craplci)',
		'30 - Pagamento de GPS',
		'31 - Pagamento de Beneficios do INSS via COBAN',
		'32 - Lancamentos da conta salario (craplcs)',
		'122 - Compensacao',
		'124 - DOC',
		'125 - TED'
	);
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0179.p</Bo>';
	$xml .= '		<Proc>Busca_Indfuncao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"liberaFormulario();",false);
	}

	$indfuncao = $xmlObjeto->roottag->tags[0]->tags;

	
	
?>

<form id="frmHistorico" name="frmHistorico" class="formulario condensado">
	<div id="divHistorico" >

		<!-- Fieldset para os campos de DADOS GERAIS do historico -->
		<fieldset id="fsetDadosHistorico" name="fsetDadosHistorico" style="padding-bottom:10px;">
			
			<legend>Dados Gerais</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="cdhistor">C&oacute;digo:</label>
						<input id="cdhistor" name="cdhistor" type="text"/>
						<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaHistorico();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
					</td>
					<td colspan="2">
						<label for="cdhinovo">Novo C&oacute;digo:</label>
						<input id="cdhinovo" name="cdhinovo" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dshistor">Hist&oacute;rico:</label>
						<input id="dshistor" name="dshistor" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="indebcre">D&eacute;bito/Cr&eacute;dito:</label>
						<select name="indebcre" id="indebcre" onchange="liberaMonitoramento(); return false;">
							<option value="D">D&eacute;bito</option> 
							<option value="C">Cr&eacute;dito</option> 
						</select>
					</td>
					<td>
						<label for="tplotmov">Tipo do Lote:</label>
						<select id="tplotmov" name="tplotmov">
						<?php
						foreach ($tplotmovLst as $i => $tplotmov) { 
						?>
							<option value="<?php echo $tplotmovLst[$i];?>"><?php echo $dslotmovLst[$i];?></option>
						<?php
						}
						?>
					</td>
					<td>
						<label for="inhistor">Ind. Fun&ccedil;&atilde;o:</label>
						<select id="inhistor" name="inhistor">
							<option value="0">0</option>

							<?php
								foreach ($indfuncao as $i) {
								?>
									<option value="<?= getByTagName($i->tags, 'inhistor'); ?>"> <?= getByTagName($i->tags, 'inhistor').'-'.getByTagName($i->tags, 'fnhistor'); ?></option> 
								<?php
								}
								?>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dsexthst">Descri&ccedil;&atilde;o Extensa:</label>
						<input id="dsexthst" name="dsexthst" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dsextrat">Descri&ccedil;&atilde;o Extrato:</label>
						<input id="dsextrat" name="dsextrat" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="nmestrut">Nome da Estrutura:</label>
						<select id="nmestrut" name="nmestrut">
							<option value="">&nbsp;</option>
						<?php
						foreach ($nmestrutLst as $i => $nmestrut) { 
						?>
							<option value="<?php echo $nmestrutLst[$i];?>"><?php echo $dsestrutLst[$i];?></option>
						<?php
						}
						?>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de indicadores do historico  -->
		<fieldset id="fsetIndicadores" name="fsetIndicadores" style="padding-bottom:10px;">
			
			<legend>Indicadores</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="indoipmf">Indicador de Incid&ecirc;ncia IPMF:</label>
						<input id="indoipmf" name="indoipmf" type="text"/>
					</td>
					<td>
						<label for="inclasse">Classe CPMF:</label>
						<input id="inclasse" name="inclasse" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="inautori">Apresentar tela AUTORI:</label>
						<select id="inautori" name="inautori">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
					<td>
						<label for="inavisar">Apresentar LAUTOM:</label>
						<select id="inavisar" name="inavisar">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="indebcta">Ind. D&eacute;bito em Conta:</label>
						<select id="indebcta" name="indebcta">
							<option value="1">D&eacute;bito em conta </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="incremes">Ind. p/Estat. Cr&eacute;dito do M&ecirc;s:</label>
						<select id="incremes" name="incremes">
							<option value="1">Soma na estat&iacute;stica </option>
							<option value="0">N&atilde;o soma </option>
						</select>
					</td>
					<td>
						<label for="inmonpld">Ind. Monitoramento:</label>
						<select id="inmonpld" name="inmonpld">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de dados contabeis do historico -->
		<fieldset id="fsetDadosContabeis" name="fsetDadosContabeis" style="padding-bottom:10px;">
			
			<legend>Dados Contabeis</legend>

			<table width="100%">
				<tr>
					<td colspan="2">
						<label for="cdhstctb">Hist&oacute;rico Contabilidade:</label>
						<input id="cdhstctb" name="cdhstctb" type="text" />
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="tpctbccu">Contabilizar gerencial:</label>
						<select id="tpctbccu" name="tpctbccu">
							<option value="1">1 - Sim </option>
							<option value="0">0 - N&atilde;o </option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="tpctbcxa" >Tipo Contab. Caixa:</label>
						<select name="tpctbcxa" id="tpctbcxa">
							<option value="0">0 - N&atilde;o tem tipo de contabiliza&ccedil;&atilde;o</option> 
							<option value="1">1 - Contabiliza&ccedil;&atilde;o geral</option> 
							<option value="2">2 - Contabiliza&ccedil;&atilde;o a d&eacute;bito por caixa</option> 
							<option value="3">3 - Contabiliza&ccedil;&atilde;o a cr&eacute;dito por caixa</option> 
							<option value="4" disabled>4 - Contabiliza&ccedil;&atilde;o a d&eacute;bito Banco do Brasil</option> 
							<option value="5" disabled>5 - Contabiliza&ccedil;&atilde;o a cr&eacute;dito Banco do Brasil</option> 
							<option value="6" disabled>6 - Contabiliza&ccedil;&atilde;o a d&eacute;bito Banco do Brasil</option> 
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="indcompl">Indicador de Complemento:</label>
						<select id="indcompl" name="indcompl">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrctadeb">Conta a Debitar:</label>
						<input id="nrctadeb" name="nrctadeb" type="text"/>
					</td>
					<td>
						<label for="nrctacrd">Conta a Creditar:</label>
						<input id="nrctacrd" name="nrctacrd" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="ingerdeb">Gerencial a D&eacute;bito:</label>
						<select name="ingerdeb" id="ingerdeb">
							<option value="1">1 - N&atilde;o</option> 
							<option value="2">2 - Geral</option> 
							<option value="3">3 - PA</option> 
						</select>
					</td>
					<td>
						<label for="ingercre">Gerencial a Cr&eacute;dito:</label>
						<select name="ingercre" id="ingercre">
							<option value="1">1 - N&atilde;o</option> 
							<option value="2">2 - Geral</option> 
							<option value="3">3 - PA</option> 
						</select>
					</td>
				</tr>
				<tr class='estouraConta'>
					<td colspan="2">
						<label for="inestocc">Debita ap&oacute;s o estouro de conta corrente (60 dias) :</label>
						<select id="inestocc" name="inestocc">
							<option value="0">0 - N&atilde;o</option>
							<option value="1">1 - Sim</option>
						</select>
					</td>
				</tr>
				<tr> 
					<td colspan="2">
						<label for="indebprj"><?php echo utf8_decode('Debita após transferência da conta para prejuízo:'); ?></label>
						<select id="indebprj" name="indebprj">
							<option value="0">0 - N&atilde;o</option>
							<option value="1">1 - Sim</option>
						</select>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de TARIFAS do historico -->
		<fieldset id="fsetTarifas" name="fsetTarifas" style="padding-bottom:10px;">
			
			<legend>Tarifas</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="nrctatrd">Conta Tarifa D&eacute;bito:</label>
						<input id="nrctatrd" name="nrctatrd" type="text"/>
					</td>
					<td>
						<label for="nrctatrc">Conta Tarifa Cr&eacute;dito:</label>
						<input id="nrctatrc" name="nrctatrc" type="text"/>
					</td>
				</tr>

				<tr>
					<td>
						<label for="vltarayl">AYLLOS:</label>
						<input id="vltarayl" name="vltarayl" type="text"/>
					</td>
					<td>
						<label for="vltarcxo">CAIXA:</label>
						<input id="vltarcxo" name="vltarcxo" type="text"/>
					</td>
				</tr>

				<tr>
					<td>
						<label for="vltarint">INTERNET:</label>
						<input id="vltarint" name="vltarint" type="text"/>
					</td>
					<td>
						<label for="vltarcsh">CASH:</label>
						<input id="vltarcsh" name="vltarcsh" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de TARIFAS do historico -->
		<fieldset id="fsetTarifas" name="fsetTarifas" style="padding-bottom:10px;">
			
			<legend>Situa&ccedil;&otilde;es de Conta</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="cdgrupo_historico">Grupo de Hist&oacute;rico:</label>
						<input name="cdgrupo_historico" id="cdgrupo_historico" type="text"/>
						<a style="margin-top:0px;" href="#" onClick="controlaPesquisaGrupoHistorico('frmHistorico'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="dsgrupo_historico" id="dsgrupo_historico" type="text"/>
					</td>
				<tr>
			</table>
		</fieldset>
		
		<!-- Fieldset para os campos de TARIFAS do historico -->
		<fieldset id="fsetOutros" name="fsetOutros" style="padding-bottom:10px;">
			
			<legend>Outros</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="flgsenha">Solicitar Senha:</label>
						<select id="flgsenha" name="flgsenha">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>
					<!-- Início PJ 416 - BacenJud -->									
					<td>
						<label for="indutblq">Considerar para Bloquei Judicial?</label>
						<select id="indutblq" name="indutblq">
							<option value="S">Sim </option>
							<option value="N">N&atilde;o </option>
						</select>
						<!-- Campo hidden para salvar o operador que autorizou mudar o campo "Considerar para Bloquei Judicial" para "nao" -->
						<input type="hidden" name="operauto" id="operauto" value="">
					</td>
                    <!-- Fim PJ 416 - BacenJud -->
				</tr>
				<tr>
					<td colspan="2">
						<label for="cdprodut">Produto:</label>
						<input name="cdprodut" id="cdprodut" type="text"/>
						<a style="margin-top:0px;" href="#" onClick="controlaPesquisaProduto('frmHistorico'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="dsprodut" id="dsprodut" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="cdagrupa">Agrupamento:</label>
						<input name="cdagrupa" id="cdagrupa" type="text"/>
						<a style="margin-top:0px;" href="#" onClick="controlaPesquisaAgrupamento('frmHistorico'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="dsagrupa" id="dsagrupa" type="text"/>
					</td>
				<tr>
				<tr>
					<td>
						<label for="idmonpld">Monitorar PLD:</label>
						<select id="idmonpld" name="idmonpld">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
					</td>

				    <!-- Inicio SM 5 - 364 - RMM -->
					<td>
						<label for="inperdes">Permitir Desligar Conta?</label>
						<select id="inperdes" name="inperdes">
							<option value="1">Sim </option>
							<option value="0">N&atilde;o </option>
						</select>
						<!-- Campo hidden para salvar o operador que autorizou mudar o campo "Considerar para Bloquei Judicial" para "nao" -->
						<!-- <input type="hidden" name="operauto" id="operauto" value=""> -->
					</td>
                    <!-- Inicio SM 5 - 364 - RMM -->					
				</tr>
			</table>
		</fieldset>
	</div>
</form>
