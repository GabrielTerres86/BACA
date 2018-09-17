<?
/*!
 * FONTE        : calcula_digito.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 13/05/2014
 * OBJETIVO     : Verificar se digito esta correto
 *
 * --------------
 * ALTERAÇÕES   : 03/02/2015 - Incluir Validação para fatura04 e incluido campo nomcampo como parametro (Lucas R. #242146)
 * --------------
 *				  06/05/2016 - Correação do fluxo referente a convenios SICRED [Rafael Maciel (RKAM)] 
 * 
 *                12/09/2017 - Tratamento para não permitir o prosseguimento da rotina caso ocorra erro de digito 
 *                             para a referencia no caso de sicredi sim (Lucas Ranghetti #751239)
 *
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cdrefere = (isset($_POST['cdrefere'])) ? $_POST['cdrefere'] : '' ;
	$codbarra = (isset($_POST['codbarra'])) ? $_POST['codbarra'] : '' ;
	$fatura01 = (isset($_POST['fatura01'])) ? $_POST['fatura01'] : '' ;
	$fatura02 = (isset($_POST['fatura02'])) ? $_POST['fatura02'] : '' ;
	$fatura03 = (isset($_POST['fatura03'])) ? $_POST['fatura03'] : '' ;
	$fatura04 = (isset($_POST['fatura04'])) ? $_POST['fatura04'] : '' ;
	$flgmanua = (isset($_POST['flgmanua'])) ? $_POST['flgmanua'] : '' ;
	$nomcampo = (isset($_POST['nomcampo'])) ? $_POST['nomcampo'] : '' ;
	
	// Dependendo da operação, chamo uma procedure diferente
	
	if($operacao == 'referencia') {
		$procedure = 'retorna-calculo-referencia';
	} else {
		$procedure = 'retorna-calculo-barras'; 
	}

		// Monta o xml de requisição
		$xmlAutori  = "";
		$xmlAutori .= "<Root>";
		$xmlAutori .= "	<Cabecalho>";
		$xmlAutori .= "		<Bo>b1wgen0092.p</Bo>";
		$xmlAutori .= "		<Proc>".$procedure."</Proc>";
		$xmlAutori .= "	</Cabecalho>";
		$xmlAutori .= "	<Dados>";
		$xmlAutori .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlAutori .= "		<codbarra>".$codbarra."</codbarra>";
		$xmlAutori .= "		<cdrefere>".$cdrefere."</cdrefere>";
		$xmlAutori .= "		<fatura01>".$fatura01."</fatura01>";
		$xmlAutori .= "		<fatura02>".$fatura02."</fatura02>";
		$xmlAutori .= "		<fatura03>".$fatura03."</fatura03>";
		$xmlAutori .= "		<fatura04>".$fatura04."</fatura04>";
		$xmlAutori .= "		<flgmanua>".$flgmanua."</flgmanua>";
		$xmlAutori .= "		<nomcampo>".$nomcampo."</nomcampo>";
		$xmlAutori .= "	</Dados>";
		$xmlAutori .= "</Root>";
	
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xmlAutori);
		$xmlObjeto 	= getObjectXML($xmlResult);		

		$dsnomcnv	= $xmlObjeto->roottag->tags[0]->attributes['DSNOMCNV'];
		
		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			$operacao = '';
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
			if (!empty($nmdcampo)) { 
				if ($nmdcampo == 'fatura01') { 
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').focus(); $('#fatura02','#frmAutori').desabilitaCampo();"; 
				}
				if ($nmdcampo == 'fatura02') {
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').focus(); $('#fatura03','#frmAutori').desabilitaCampo();"; 
				}
				if ($nmdcampo == 'fatura03') {
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').focus(); $('#fatura04','#frmAutori').desabilitaCampo();"; 
				}
				if ($nmdcampo == 'fatura04') {
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').focus(); $('#cdrefere','#frmAutori').desabilitaCampo();"; 
				}
				if ($nmdcampo == 'cdrefere') {
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').focus();"; 
					echo "erroRef = 1;";
				}
				if ($nmdcampo == 'codbarra') {
					$mtdErro = $mtdErro . "$('#".$nmdcampo."').habilitaCampo().focus(); $('#dshistor','#frmAutori').desabilitaCampo(); $('#cdrefere','#frmAutori').desabilitaCampo();"; 
				}
			}  
			exibirErro('error',$msgErro,'Alerta - Autori',$mtdErro,false);
		} else{			
			echo "hideMsgAguardo();";			
			if($dsnomcnv)
				echo "$('#dshistor','#frmAutori').val('".$dsnomcnv."');";
			if($operacao == 'barra') {
				echo "$('#cdrefere','#frmAutori').habilitaCampo(); $('#cdrefere','#frmAutori').focus(); $('#codbarra','#frmAutori').desabilitaCampo();";
			}elseif($operacao == 'fatura') {
				
				if ($nomcampo == 'fatura01') {
					$campo = '#fatura02';
				}
				if ($nomcampo == 'fatura02') {
					$campo = '#fatura03';
				}
				if ($nomcampo == 'fatura03') {
					$campo = '#fatura04';
				}
				if ($nomcampo == 'fatura04') {
					$campo = '#cdrefere';
				}
				echo "habilitaFaturas('".$campo."');";
				echo "desabilitaFaturas('#".$nomcampo."');";
			}
			
			/*if ($operacao == 'referencia') { 
				echo "controlaOperacao('I5');";
			}*/
			echo "$('#btSalvarI5'       ,'#divBotoes').show();";
		}
?>

