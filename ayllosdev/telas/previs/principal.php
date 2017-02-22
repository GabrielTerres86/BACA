<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011												ÚLTIMA ALTERAÇÃO: 05/12/2016
 * OBJETIVO     : Capturar dados para tela PREVIS
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Incluido variavel de parametro 'cdmovmto' (Tiago).
 *				  22/08/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).
 *				  21/03/2016 - Ajuste layout, valores negativos (Adriano)
 *                03/10/2016 - Remocao das opcoes "F" e "L" para o PRJ313. (Jaison/Marcos SUPERO)
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 *
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
	$cdmovmto			= (isset($_POST['cdmovmto']))    ? $_POST['cdmovmto'] : '' ;
	$dtmvtolx 			= validaData($_POST['dtmvtolx']) ? $_POST['dtmvtolx'] : '' ;
	$cdagencx 			= (isset($_POST['cdagencx']))    ? $_POST['cdagencx'] : 0  ;
	$cdcoopex 			= (isset($_POST['cdcoopex']))    ? $_POST['cdcoopex'] : 0  ;	
	
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
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} 
		
	
	$msg = $xmlObjeto->roottag->tags[1]->tags;  
	
	
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

			}
			
?>

<script type="text/javascript">
		
	controlaLayout();
				
</script>





