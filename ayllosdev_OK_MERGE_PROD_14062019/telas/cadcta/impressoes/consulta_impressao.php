<?php
/*!
 * FONTE        : consulta_impressao.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 22/07/2013 
 * OBJETIVO     : Mostrar as opcoes p/ impressao de procuradores e titulares
 * ALTERACOES   : 28/10/2013 - Jean Michel  (CECRED) : Ajuste botão "VOLTAR".
 * 			      19/10/2015 - Ajuste na impressão do relatório de procurador			
							   onde ocorria erro caso fosse impresso antes o 
							   retório de titular. SD 310056 (Kelvin).
 */
 
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");	
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','fechaRotina(divRotina)');
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)');

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta 	 = $_POST["nrdconta"] 	 == "" ?  0   : $_POST["nrdconta"];
	$idseqttl 	 = $_POST["idseqttl"] 	 == "" ?  0   : $_POST["idseqttl"];
	$inpessoa 	 = $_POST["inpessoa"] 	 == "" ?  0   : $_POST["inpessoa"];
	$tpimpressao = $_POST["tpimpressao"] == "" ?  0   : $_POST["tpimpressao"];
	
	$nrcpfcgc 	 = $_POST['nrcpfcgc'] 	 == '' ?  0   : $_POST['nrcpfcgc'];
	$nrdctato 	 = $_POST['nrdctato'] 	 == '' ?  0   : $_POST['nrdctato'];	
	$nrdrowid 	 = $_POST['nrdrowid'] 	 == '' ?  0   : $_POST['nrdrowid'];	
	$operacao 	 = $_POST['operacao'] 	 == '' ? 'C'  : $_POST['operacao'];
	
	$idseqttl 	 = $_POST["inpessoa"] 	!= 1   ?  0   : $_POST["idseqttl"];
	
	$tipoimpr = 0;
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	
	if ($tpimpressao == 'titular'){
		$tipoimpr = 1;
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0063.p</Bo>";
		$xml .= "		<Proc>busca_lista_titulares</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjImp = getObjectXML($xmlResult);
		
		$registros = $xmlObjImp->roottag->tags[0]->tags;		
				
		?>
			<div class="divRegistros">
				<table class="table">
					<thead>
						<tr>
							<th>Nome</th>
						</tr>			
					</thead>
					<tbody>
						<?php
							foreach($registros as $registro){
						?>
							<tr>
								<td>
									<input type="hidden" name="idseqttl" id="idseqttl" value="<?php echo getByTagName($registro->tags,'idseqttl'); ?>" />
									<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value="<?php echo getByTagName($registro->tags,'nrcpfcgc'); ?>" />
									<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo getByTagName($registro->tags,'nrdconta'); ?>" />
									<input type="hidden" name="nrdctato" id="nrdctato" value="<?php echo getByTagName($registro->tags,'nrdctato'); ?>" />
									<?php echo (getByTagName($registro->tags,'nmextttl')); ?>
								</td>
							</tr>				
						<?php
							}
						?>			
					</tbody>
				</table>
			</div>
		
		<?php		
	}elseif ($tpimpressao == 'procurador'){
		$tipoimpr = 2;
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0058.p</Bo>';
		$xml .= '		<Proc>busca_dados</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
		$xml .= '		<nrcpfcgc>'."0".'</nrcpfcgc>';	
		$xml .= '		<cddopcao>'.$operacao.'</cddopcao>';	
		$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
		$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
		$xml .= '	</Dados>';
		$xml .= '</Root>';	
		
		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);	
		$registros = $xmlObjeto->roottag->tags[0]->tags;	
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			if ( $operacao == 'IB' ) { 
				$metodo = 'bloqueiaFundo(divRotina);controlaOperacao(\'TI\');';
			} else {
				$metodo = 'bloqueiaFundo(divRotina);controlaOperacao();';
			}		
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
		}		
				
		?>
		
			<div class="divRegistros">
				<table class="table">
					<thead>
						<tr>
							<th>Nome</th>
						</tr>			
					</thead>
					<tbody>
				<?foreach($registros as $procuracao) {?>
					<tr>
						<!-- Analisar essa linha, chave primaria de procuradores(cdcooper,tpctrato,nrdconta,nrctremp,nrcpfcgc) -->
						<td>
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($procuracao->tags,'nrdconta') ?>" /> 
							<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($procuracao->tags,'nrcpfcgc') ?>" /> 
							<input type="hidden" id="nrdctato" name="nrdctato" value="<? echo getByTagName($procuracao->tags,'nrdctato') ?>" />
							<? echo stringTabela(getByTagName($procuracao->tags,'nmdavali'),23,'maiuscula') ?>
						</td> <!-- Nome -->
					</tr>				
						<? } ?>			
					</tbody>
				</table>
			</div>
		
		<?php		
	}
?>

	<div id="divBotoes">
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="telaCartaoAssinatura(<?php echo $inpessoa; ?>);" />	
		<input type="image" id="btPoderes" src="<? echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimirCartaoAssinatura(<?php echo $tipoimpr; ?>);" />	
	</div>
		
	<form name="frmImpressao" id="frmImpressao" ></form>	
	
	<script type="text/javascript">
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		
		var ordemInicial = new Array();
			ordemInicial = [[0,0]];
			
		var arrayLargura = new Array();
			arrayLargura[0] = '95%';
			
		var arrayAlinha = new Array();
			arrayAlinha[0] = 'left';
			
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );		
			
	</script>

	