<? 
/*!
 * FONTE        : verifica_propostas.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 13/05/2011 
 * OBJETIVO     : Verificas proposta antes de persistir dados.
 
   ALTERAÇÕES   : 27/11/2012 - Ajustes referente ao projeto GE (Adriano).
				  23/01/2014 - Adicionados parametros para validação de   
							   CPF/CNPJ do proprietário dos bens como
							   interveniente (Lucas). 
				  21/05/2015 - Projeto Cessao de Credito. (James)  

                  15/10/2018 - P442 - Não mais passar dados de interveniente e bens na validação
                               de outras propostas (Marcos-Envolti)
							   
							   
   
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';	
	$vleprori = (isset($_POST['vleprori'])) ? $_POST['vleprori'] : '';
	$vlminimo = (isset($_POST['vlminimo'])) ? $_POST['vlminimo'] : '';
	$qtpromis = (isset($_POST['qtpromis'])) ? $_POST['qtpromis'] : '';
	$qtpreemp = (isset($_POST['qtpreemp'])) ? $_POST['qtpreemp'] : '';
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = 'A';                     

	if( $operacao == 'I_FINALIZA'  ){ $cddopcao = 'I'; }
	
	// Monta o xml de requisição
	$xml1 = "<Root>";
	$xml1 .= "	<Cabecalho>";
	$xml1 .= "		<Bo>b1wgen0002.p</Bo>";
	$xml1 .= "		<Proc>verifica-outras-propostas</Proc>";
	$xml1 .= "	</Cabecalho>";
	$xml1 .= "	<Dados>";
	$xml1 .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml1 .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml1 .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml1 .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml1 .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml1 .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml1 .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml1 .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xml1 .= "		<inproces>".$glbvars["inproces"]."</inproces>";	
	$xml1 .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml1 .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml1 .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml1 .= "		<vlemprst>".$vlemprst."</vlemprst>";	
	$xml1 .= "		<vleprori>".$vleprori."</vleprori>";
	$xml1 .= "		<vlminimo>".$vlminimo."</vlminimo>";
	$xml1 .= "		<qtpromis>".$qtpromis."</qtpromis>";
	$xml1 .= "		<qtpreemp>".$qtpreemp."</qtpreemp>";
	$xml1 .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
	$xml1 .= "	</Dados>";
	$xml1 .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml1);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$msgAlertas = $xmlObj->roottag->tags[0]->tags;	
	$grupo 		= $xmlObj->roottag->tags[1]->tags;		
		
	$msgAlertArray = Array();
	
	foreach( $msgAlertas as $alerta){
		$msgAlertArray[getByTagName($alerta->tags,'inconfir')] = getByTagName($alerta->tags,'dsmensag');
	}
	
	$msgAlerta = implode( "|", $msgAlertArray);	
	
	/*Se a conta em questão pertence a um grupo econômico então, serão alimentadas as variáveis responsáveis por montar
	  as mensagens e mostrar as contas referente a este grupo economico.*/
	if(count($grupo) > 0){?>
	
		strHTML = '';
		strHTML2 = '';
					
		strHTML2 += '<form name="frmGrupoEconomico" id="frmGrupoEconomico" class="formulario">';
		strHTML2 +=		'<br />';
		strHTML2 +=		'Conta pertence a grupo econ&ocirc;mico.';
		strHTML2 +=		'<br />';
		strHTML2 +=		'Valor ultrapassa limite legal permitido.';
		strHTML2 +=		'<br />';
		strHTML2 +=		'Verifique endividamento total das contas.';
		strHTML2 += '</form>';
		strHTML  += '<br style="clear:both" />';
		strHTML  += '<br style="clear:both" />';
		strHTML  += '<div class="divRegistros">';
		strHTML  +=	'<table>';
		strHTML  +=		'<thead>';
		strHTML  +=			'<tr>';
		strHTML  +=				'<th>Contas Relacionadas</th>';
		strHTML  +=			'</tr>';
		strHTML  +=		'</thead>';
		strHTML  +=		'<tbody>';

		
		<?php 
		for ($i = 0; $i < count($grupo); $i++) { ?>
				
			strHTML +=				'<tr>';
			strHTML +=					'<td><span><?php echo $grupo[$i]->tags[2]->cdata;?></span>';
			strHTML +=							'<?php echo formataContaDV($grupo[$i]->tags[2]->cdata);?>';
			strHTML +=					'</td>';
			strHTML +=				'</tr>';
					
		<?php
		}
		?>
		
		strHTML +=		'</tbody>';
		strHTML +=	'</table>';
			
		
	<?
	}
	
	if ($msgAlerta!=''){
	
		/*Se existe alguém formando o grupo econômico e se a conta em questão pertence a um grupo, será mostrado uma mensagem
          informando que o grupo economico está sendo gerado e, apresentado uma tela informando as contas participantes do
		  grupo juntamente com as mensagens alimentas na var strHTML2.*/
		if(count($grupo) > 0){
		
			$metodoSaida = 'exibirMensagens(\''.$msgAlerta.'\',\'mostraMsgsGrupoEconomico();formataGrupoEconomico();\');';
			?>dsmetodo = 'controlaOperacao(\'VA\')';<?
			
			if( $operacao == 'I_FINALIZA'  ){ 
			
			    ?>dsmetodo = 'controlaOperacao(\'VI\')';<?
			
			}
			
			echo $metodoSaida;
			
		}else{
		
			$metodoSaida = 'exibirMensagens(\''.$msgAlerta.'\',\'controlaOperacao(\"VA\")\');';
			
			if( $operacao == 'I_FINALIZA'  ){ 
				$metodoSaida = 'exibirMensagens(\''.$msgAlerta.'\',\'controlaOperacao(\"VI\")\');';
			}
			
			echo $metodoSaida;
		
		}
		
	}else{
		
		/*Se não há alguém formando o grupo econômico e se a conta em questão pertence a um grupo, será apenas apresentado uma 
		  tela informando as contas participantes do grupo juntamente com as mensagens alimentas na var strHTML2.*/
		if(count($grupo) > 0){
		
			$metodoSaida = 'mostraMsgsGrupoEconomico();formataGrupoEconomico();';
			?>dsmetodo = 'controlaOperacao(\'VA\')';<?
			
			if( $operacao == 'I_FINALIZA'  ){ 
				
				?>dsmetodo = 'controlaOperacao(\'VI\')';<?
			} 
			
			echo $metodoSaida;
		
		
		}else{
		
			$metodoSaida = 'controlaOperacao(\'VA\');';
			
			if( $operacao == 'I_FINALIZA'  ){ 
				$metodoSaida = 'controlaOperacao(\'VI\');'; 
			} 
			
			echo $metodoSaida;
		}
		
	}
				
?>