<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011												ÚLTIMA ALTERAÇÃO: 22/08/2012
 * OBJETIVO     : Capturar dados para tela PREVIS
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Incluido variavel de parametro 'cdmovmto' (Tiago).
 *				  22/08/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)		
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Recebe o POST
	$cddopcao 			= (isset($_POST['cddopcao']))    ? $_POST['cddopcao'] : '' ;
	$cdagencx 			= (isset($_POST['cdagencx']))    ? $_POST['cdagencx'] : 0  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);		
	}
		
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0131.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>PREVIS</cdprogra>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';
	$xml .= '		<cdcoopex>'.$cdcoopex.'</cdcoopex>';
	$xml .= '       <cdmovmto>'.$cdmovmto.'</cdmovmto>';	
	$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';
	$xml .= '		<tpdmovto>'.$cdmovmto.'</tpdmovto>';	
    $xml .= '		<cdagefim>9999</cdagefim>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
	
		
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	
		if($cddopcao == "F" && ($glbvars["dtmvtolt"] == $dtmvtolx)){?>
	
			<script type="text/javascript">
		
				liberaAcesso();
		
			</script>
		
		<?}
	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} 
		
	
	if($cddopcao == "F" && ($glbvars["dtmvtolt"] == $dtmvtolx)){?>
	
		<script type="text/javascript">
	
			liberaAcesso();
	
		</script>
	
	<?}
	
	
	$msg = $xmlObjeto->roottag->tags[6]->tags;  

		
	//Se tiver alguma menssagem de alerta vinda da opção Fluxo Financeiro, será montado o form para mostra-las.
	if(count($msg) > 0){
		
		?>
		<script type="text/javascript">
			
			strHTML = '<table width="445" border="0" cellpadding="1" cellspacing="2">';
			style = '';
			mensagem = '';
						
		</script>
		
		<?
		
		for($i=0;$i<count($msg);$i++){
		
			$campos = $msg[$i]->tags;
					
			for($j=0;$j<count($campos);$j++){
			
				$campos[$j]->cdata;
								
				if($j == 4){
					?>
					<script type="text/javascript">
					
						mensagem = '<?echo $campos[$j]->cdata; ?>';
						
						if (style == '') {
							style = ' style="background-color: #FFFFFF;"';
						}else{
							style = '';
						}	
											
						strHTML += '<tr'+style+'>';
						strHTML += '	<td class="txtNormal">'+mensagem+'</td>';
						strHTML += '</tr>';															
											
					</script>
					<?
				}
			}
			
		}?>
		
		<script type="text/javascript">
		
			strHTML += '</table>';
						
		</script>
		
		<?

	}
			
	include('form_cabecalho.php');

	if ( $cddopcao == 'A' or $cddopcao == 'C' or $cddopcao == 'I' ) {
	
		$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;  
	
		$vlmoedas = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->tags;
		$vldnotas = $xmlObjeto->roottag->tags[0]->tags[0]->tags[1]->tags; 
		$qtmoedas = $xmlObjeto->roottag->tags[0]->tags[0]->tags[2]->tags; 
		$qtdnotas = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->tags; 
		$qtmoepct = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->tags;
		$submoeds = $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->tags; 
		$subnotas = $xmlObjeto->roottag->tags[0]->tags[0]->tags[6]->tags; 

		include('form_previsoes.php');

	} else if ( $cddopcao == 'F' ) {
	
		if ($glbvars["cdcooper"] == 3){
		 					
			if($cdmovmto == "E" || $cdmovmto == "S"){
							
				/*tt-ffin-mvto-cent*/
				$cdbcoval = $xmlObjeto->roottag->tags[2]->tags[0]->tags[0]->tags;
				$tpdmovto = $xmlObjeto->roottag->tags[2]->tags[0]->tags[1]->tags;
				$vlcheque = $xmlObjeto->roottag->tags[2]->tags[0]->tags[2]->tags;
				$vltotdoc = $xmlObjeto->roottag->tags[2]->tags[0]->tags[3]->tags;
				$vltotted = $xmlObjeto->roottag->tags[2]->tags[0]->tags[4]->tags;
				$vltottit = $xmlObjeto->roottag->tags[2]->tags[0]->tags[5]->tags;
				$vldevolu = $xmlObjeto->roottag->tags[2]->tags[0]->tags[6]->tags;
				$vlmvtitg = $xmlObjeto->roottag->tags[2]->tags[0]->tags[7]->tags;
				$vlttinss = $xmlObjeto->roottag->tags[2]->tags[0]->tags[8]->tags;
				$vldivers = $xmlObjeto->roottag->tags[2]->tags[0]->tags[9]->tags;
				$vlttcrdb = $xmlObjeto->roottag->tags[2]->tags[0]->tags[10]->tags;				
				
			}else{
				if($cdmovmto == "R"){
				
					/*tt-ffin-cons-cent*/
					$cdcooper = $xmlObjeto->roottag->tags[4]->tags[0]->tags[0]->cdata;
					$dtmvtolt = $xmlObjeto->roottag->tags[4]->tags[0]->tags[1]->cdata;
					$vlentrad = $xmlObjeto->roottag->tags[4]->tags[0]->tags[2]->tags;
					$vlsaidas = $xmlObjeto->roottag->tags[4]->tags[0]->tags[3]->tags;
					$vlresult = $xmlObjeto->roottag->tags[4]->tags[0]->tags[4]->tags;
					
					
				}else{
								
					/*tt-ffin-cons-sing*/
					$consSingArr = $xmlObjeto->roottag->tags[5]->tags;
					
					$i = 0;
					
					?>
					<script type="text/javascript">
							
							qtcopapl = '<?echo count($consSingArr); ?>';							
							
					</script>
					<?
					
					foreach($consSingArr as $consSing){						
						
						$cdcooper[$i] = $consSing->tags[0]->cdata;						
						$cdagenci[$i] = $consSing->tags[1]->cdata;
						$cdoperad[$i] = $consSing->tags[2]->cdata;
						$dtmvtolt[$i] = $consSing->tags[3]->cdata;
						$vlentrad[$i] = $consSing->tags[4]->cdata;
						$vlresult[$i] = $consSing->tags[5]->cdata;
						$vlsaidas[$i] = $consSing->tags[6]->cdata;
						$vlsldfin[$i] = $consSing->tags[7]->cdata;
						$vlsldcta[$i] = $consSing->tags[8]->cdata;
						$vlresgat[$i] = $consSing->tags[9]->cdata;
						$vlaplica[$i] = $consSing->tags[10]->cdata;
						$nmrescop[$i] = $consSing->tags[11]->cdata;
						$nmoperad[$i] = $consSing->tags[12]->cdata;
											
						$i++;
					}
										
					
				}
			}
			
			
		} else {	
			
			if($cdmovmto == "E" || $cdmovmto == "S"){
			
				/*tt-ffin-mvto-sing*/
				$cdbcoval = $xmlObjeto->roottag->tags[3]->tags[0]->tags[0]->tags;
				$tpdmovto = $xmlObjeto->roottag->tags[3]->tags[0]->tags[1]->tags;
				$vlcheque = $xmlObjeto->roottag->tags[3]->tags[0]->tags[2]->tags;
				$vltotdoc = $xmlObjeto->roottag->tags[3]->tags[0]->tags[3]->tags;
				$vltotted = $xmlObjeto->roottag->tags[3]->tags[0]->tags[4]->tags;
				$vltottit = $xmlObjeto->roottag->tags[3]->tags[0]->tags[5]->tags;
				$vldevolu = $xmlObjeto->roottag->tags[3]->tags[0]->tags[6]->tags;
				$vlmvtitg = $xmlObjeto->roottag->tags[3]->tags[0]->tags[7]->tags; 
				$vlttinss = $xmlObjeto->roottag->tags[3]->tags[0]->tags[8]->tags;
				$vltrdeit = $xmlObjeto->roottag->tags[3]->tags[0]->tags[9]->tags;
				$vlsatait = $xmlObjeto->roottag->tags[3]->tags[0]->tags[10]->tags;
				$vlfatbra = $xmlObjeto->roottag->tags[3]->tags[0]->tags[11]->tags;
				$vlconven = $xmlObjeto->roottag->tags[3]->tags[0]->tags[12]->tags;
				$vlrepass = $xmlObjeto->roottag->tags[3]->tags[0]->tags[13]->tags;
				$vlnumera = $xmlObjeto->roottag->tags[3]->tags[0]->tags[14]->tags;
				$vlrfolha = $xmlObjeto->roottag->tags[3]->tags[0]->tags[15]->tags;
				$vldivers = $xmlObjeto->roottag->tags[3]->tags[0]->tags[16]->tags;
				$vlttcrdb = $xmlObjeto->roottag->tags[3]->tags[0]->tags[17]->tags;				
				
				$vloutros = $xmlObjeto->roottag->tags[3]->tags[0]->tags[18]->tags;
				
			}else{			
			
				/*tt-ffin-cons-sing*/
				$cdcooper = $xmlObjeto->roottag->tags[5]->tags[0]->tags[0]->cdata;
				$cdagenci = $xmlObjeto->roottag->tags[5]->tags[0]->tags[1]->cdata;
				$cdoperad = $xmlObjeto->roottag->tags[5]->tags[0]->tags[2]->cdata;
				$dtmvtolt = $xmlObjeto->roottag->tags[5]->tags[0]->tags[3]->cdata;
				$vlentrad = $xmlObjeto->roottag->tags[5]->tags[0]->tags[4]->cdata;
				$vlresult = $xmlObjeto->roottag->tags[5]->tags[0]->tags[6]->cdata;
				$vlsaidas = $xmlObjeto->roottag->tags[5]->tags[0]->tags[5]->cdata;
				$vlsldfin = $xmlObjeto->roottag->tags[5]->tags[0]->tags[7]->cdata;
				$vlsldcta = $xmlObjeto->roottag->tags[5]->tags[0]->tags[8]->cdata;
				$vlresgat = $xmlObjeto->roottag->tags[5]->tags[0]->tags[9]->cdata;
				$vlaplica = $xmlObjeto->roottag->tags[5]->tags[0]->tags[10]->cdata;
				$nmrescop = $xmlObjeto->roottag->tags[5]->tags[0]->tags[11]->cdata;
				$nmoperad = $xmlObjeto->roottag->tags[5]->tags[0]->tags[12]->cdata;
				$hrtransa = $xmlObjeto->roottag->tags[5]->tags[0]->tags[13]->cdata;
								
				?>
				<script type="text/javascript">
					
					vlresgan = '<? echo $vlresgat; ?>';
					vlaplian = '<? echo $vlaplica; ?>';
							
				</script>
				<?
			}
			
		}
							
		$registro = $xmlObjeto->roottag->tags[3]->tags[0]->tags;  
		include('form_fluxo.php');
		
	
	} else if ( $cddopcao == 'L' ) {
		$registro = $xmlObjeto->roottag->tags[1]->tags[0]->tags;  
		include('form_liquidacao.php');
	
	}
	
?>

<script type="text/javascript">
		
	controlaLayout();
				
</script>


<?	
	if($cddopcao == "F" && $glbvars["dtmvtolt"] == $dtmvtolx){
	
		if($glbvars["cdcooper"] != 3){ ?>
		
			<script type="text/javascript">
		
				validaHorario();
									
			</script>
				
	<?  }else{
		
			?>
			
				<script type="text/javascript">
		
					mostraMsgsAlerta();
									
				</script>
				
			<?
		
		}
	
	}
	
?>



