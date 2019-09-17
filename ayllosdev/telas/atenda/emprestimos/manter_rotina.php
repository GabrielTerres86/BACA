<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/05/2011
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados emprestimos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [08/08/2011] Inserido na rotina o campo 'tpemprst' referente ao tipo de empréstimo -  Marcelo L. Pereira (GATI)
 * 001: [10/10/2011] Exibir mensagem de alerta -  Marcelo L. Pereira (GATI)
 * 002: [31/10/2011] Incluido a chamada da procedure alerta_fraude (Adriano).
 * 003: [29/11/2011] Ajuste para a inclusao do campo Justificativa (Adriano).
 * 004: [09/04/2012] Incluir campo dtlibera (Gabriel)
 * 005: [28/03/2013] Retirado a chamada da procedure alerta_fraude (Adriano).
 * 006: [08/01/2014] Adicionado tratamento para retirar quebra de linha da justificativa e observacao. (Jorge)
 * 007: [01/04/2014] Adicionado conversao de caracteres especiais em seus equivalentes em campos string. (Jorge)
 * 008: [15/07/2014] Incluso novos parametros inpessoa e dtnascto na chamata xml (Daniel).
 * 009: [08/09/2014] Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 * 010: [08/01/2015] Projeto microcredito (Jonata-RKAM).
 * 011: [23/01/2015] Incluso o parametro vleprori, para passar a informacao na alteracao do contrato (Vanessa SD 245702).
 * 012: [13/02/2015] Analise credito. (Jonata-RKAM).
 * 013: [27/02/2015] Substituicao de caracter especial seta por "-". (Jaison/Gielow - SD: 255628)
 * 014: [28/05/2015] Padronizacao das consultas automatizadas (Jonata-RKAM).
 * 015: [11/09/2015] Desenvolvimento do Projeto 215 - Estorno. (James)
 * 016: [01/03/2016] PRJ Esteira de Credito. (Jaison/Oscar)
 * 017: [01/03/2016] Adicionado cdpactra na chamada da rotina grava-proposta-completa PRJ Esteira de Credito. (Odirlei-AMcom/Oscar) 
 * 018: [16/03/2016] Inclusao da operacao ENV_ESTEIRA. PRJ207 Esteira de Credito. (Odirlei-AMcom) 
 * 019: [15/07/2016] Adicionado pergunta para bloquear a oferta de credito pre-aprovado. PRJ299/3 Pre aprovado. (Lombardi) 
 * 020: [30/11/2016] P341-Automatização BACENJUD - Remover o envio da descrição do departamento, pois não utiliza na BO (Renato Darosci - Supero)
 * 021: [05/04/2017] Cadastro dos campos Carencia. (Jaison/James - PRJ298)
 * 021: [17/07/2017] Retornar as mensagens dentro de uma DIV com IMG. (Jaison/Marcos - PRJ337)
 * 022: [12/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 023: [12/05/2017] Inserção do campo idcobope. PRJ404 (Lombardi)
 * 024: [21/09/2017] Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
 * 025: [16/01/2018] Incluído novo campo em Empréstimos (Qualif Oper. Controle) (Diego Simas - AMcom)
 * 026: [24/01/2018] Processamento do campo DSNIVORI (risco original da proposta) (Reginaldo - AMcom)
 * 027: [18/10/2018] Adicionado novos campos nas telas Avalista e Interveniente - PRJ 438. (Mateus Z / Mouts)
 * 028: [07/11/2018] Retirado Revisão Cadastral quando for a proc grava-proposta-completa - PRJ 438 - Sprint 4. (Mateus Z / Mouts)
 * 027: [21/12/2018] P298.2.2 - Apresentar pagamento na carencia (Adriano Nagasava - Supero)
 * 028: [19/04/2019] Ajuste na tela garantia de operação, para salvar seus dados apenas no 
 *                   final da inclusão, alteração de empréstimo - PRJ 438. (Mateus Z / Mouts)
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '' ;
	$vllimapv = (isset($_POST['vllimapv'])) ? $_POST['vllimapv'] : '' ;
	$qtpreemp = (isset($_POST['qtpreemp'])) ? $_POST['qtpreemp'] : '' ;
	$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '' ;
	$flgimpnp = (isset($_POST['flgimpnp'])) ? $_POST['flgimpnp'] : '' ;
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '' ;
	$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : '' ;
	$nrgarope = (isset($_POST['nrgarope'])) ? $_POST['nrgarope'] : '' ;
	$nrinfcad = (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : '' ;
	$qtopescr = (isset($_POST['qtopescr'])) ? $_POST['qtopescr'] : '' ;
	$vlopescr = (isset($_POST['vlopescr'])) ? $_POST['vlopescr'] : '' ;
	$dtoutspc = (isset($_POST['dtoutspc'])) ? $_POST['dtoutspc'] : '' ;
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '' ;
	$vlsalcon = (isset($_POST['vlsalcon'])) ? $_POST['vlsalcon'] : '' ;
	$nrctacje = (isset($_POST['nrctacje'])) ? $_POST['nrctacje'] : '' ;
	$vlmedfat = (isset($_POST['vlmedfat'])) ? $_POST['vlmedfat'] : '' ;
	$dsdrendi = (isset($_POST['vlmedfat'])) ? $_POST['dsdrendi'] : '' ;
	$dsinterv = (isset($_POST['dsinterv'])) ? $_POST['dsinterv'] : '' ;
	$tpdocav1 = (isset($_POST['tpdocav1'])) ? $_POST['tpdocav1'] : '' ;
	$cpfcjav1 = (isset($_POST['cpfcjav1'])) ? $_POST['cpfcjav1'] : '' ;
	$ende1av1 = (isset($_POST['ende1av1'])) ? $_POST['ende1av1'] : '' ;
	$emailav1 = (isset($_POST['emailav1'])) ? $_POST['emailav1'] : '' ;
	$nrcepav1 = (isset($_POST['nrcepav1'])) ? $_POST['nrcepav1'] : '' ;
	$nmdaval2 = (isset($_POST['nmdaval2'])) ? $_POST['nmdaval2'] : '' ;
	$dsdocav2 = (isset($_POST['dsdocav2'])) ? $_POST['dsdocav2'] : '' ;
	$tdccjav2 = (isset($_POST['tdccjav2'])) ? $_POST['tdccjav2'] : '' ;
	$ende2av2 = (isset($_POST['tdccjav2'])) ? $_POST['ende2av2'] : '' ;
	$nmcidav2 = (isset($_POST['nmcidav2'])) ? $_POST['nmcidav2'] : '' ;
	$cdnacio2 = (isset($_POST['cdnacio2'])) ? $_POST['cdnacio2'] : '' ;
	$vlrenme2 = (isset($_POST['vlrenme2'])) ? $_POST['vlrenme2'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;
	$flgcmtlc = (isset($_POST['flgcmtlc'])) ? $_POST['flgcmtlc'] : '' ;
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '' ;
	$dsnivris = (isset($_POST['dsnivris'])) ? $_POST['dsnivris'] : '' ;
	$qtdialib = (isset($_POST['qtdialib'])) ? $_POST['qtdialib'] : '' ;
	$percetop = (isset($_POST['percetop'])) ? $_POST['percetop'] : '' ;
	$qtpromis = (isset($_POST['qtpromis'])) ? $_POST['qtpromis'] : '' ;
	$nrctaava = (isset($_POST['nrctaava'])) ? $_POST['nrctaava'] : '' ;
	$nrperger = (isset($_POST['nrperger'])) ? $_POST['nrperger'] : '' ;
	$dtdrisco = (isset($_POST['dtdrisco'])) ? $_POST['dtdrisco'] : '' ;
	$qtifoper = (isset($_POST['qtifoper'])) ? $_POST['qtifoper'] : '' ;
	$vlrpreju = (isset($_POST['vlrpreju'])) ? $_POST['vlrpreju'] : '' ;
	$dtoutris = (isset($_POST['dtoutris'])) ? $_POST['dtoutris'] : '' ;
	$vloutras = (isset($_POST['vloutras'])) ? $_POST['vloutras'] : '' ;
	$nmempcje = (isset($_POST['nmempcje'])) ? $_POST['nmempcje'] : '' ;
	$nrcpfcjg = (isset($_POST['nrcpfcjg'])) ? $_POST['nrcpfcjg'] : '' ;
	$dsobserv = (isset($_POST['dsobserv'])) ? $_POST['dsobserv'] : '' ;
	$dsdebens = (isset($_POST['dsdebens'])) ? $_POST['dsdebens'] : '' ;
	$nmdaval1 = (isset($_POST['nmdaval1'])) ? $_POST['nmdaval1'] : '' ;
	$dsdocav1 = (isset($_POST['dsdocav1'])) ? $_POST['dsdocav1'] : '' ;
	$tdccjav1 = (isset($_POST['tdccjav1'])) ? $_POST['tdccjav1'] : '' ;
	$ende2av1 = (isset($_POST['ende2av1'])) ? $_POST['ende2av1'] : '' ;
	$nmcidav1 = (isset($_POST['nmcidav1'])) ? $_POST['nmcidav1'] : '' ;
	$cdnacio1 = (isset($_POST['cdnacio1'])) ? $_POST['cdnacio1'] : '' ;
	$nrcpfav2 = (isset($_POST['nrcpfav2'])) ? $_POST['nrcpfav2'] : '' ;
	$nmdcjav2 = (isset($_POST['nmdcjav2'])) ? $_POST['nmdcjav2'] : '' ;
	$doccjav2 = (isset($_POST['doccjav2'])) ? $_POST['doccjav2'] : '' ;
	$nrfonav2 = (isset($_POST['nrfonav2'])) ? $_POST['nrfonav2'] : '' ;
	$cdufava2 = (isset($_POST['cdufava2'])) ? $_POST['cdufava2'] : '' ;
	$vlrenme1 = (isset($_POST['vlrenme1'])) ? $_POST['vlrenme1'] : '' ;
	$dsdbeavt = (isset($_POST['dsdbeavt'])) ? $_POST['dsdbeavt'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;
	$vlutiliz = (isset($_POST['vlutiliz'])) ? $_POST['vlutiliz'] : '' ;
	$vlpreemp = (isset($_POST['vlpreemp'])) ? $_POST['vlpreemp'] : '' ;
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '' ;
	$flgimppr = (isset($_POST['flgimppr'])) ? $_POST['flgimppr'] : '' ;
	$idquapro = (isset($_POST['idquapro'])) ? $_POST['idquapro'] : '' ;
	$flgpagto = (isset($_POST['flgpagto'])) ? $_POST['flgpagto'] : '' ;
	$nrctaav2 = (isset($_POST['nrctaav2'])) ? $_POST['nrctaav2'] : '' ;
	$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '' ;
	$vltotsfn = (isset($_POST['vltotsfn'])) ? $_POST['vltotsfn'] : '' ;
	$nrliquid = (isset($_POST['nrliquid'])) ? $_POST['nrliquid'] : '' ;
	$nrpatlvr = (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : '' ;
	$vlsfnout = (isset($_POST['vlsfnout'])) ? $_POST['vlsfnout'] : '' ;
	$vlalugue = (isset($_POST['vlalugue'])) ? $_POST['vlalugue'] : '' ;
	$inconcje = (isset($_POST['inconcje'])) ? $_POST['inconcje'] : '' ;
	$flgdocje = (isset($_POST['flgdocje'])) ? $_POST['flgdocje'] : '' ;
	$perfatcl = (isset($_POST['perfatcl'])) ? $_POST['perfatcl'] : '' ;
	$dsdfinan = (isset($_POST['dsdfinan'])) ? $_POST['dsdfinan'] : '' ;
	$dsdalien = (isset($_POST['dsdalien'])) ? $_POST['dsdalien'] : '' ;
	$nrcpfav1 = (isset($_POST['nrcpfav1'])) ? $_POST['nrcpfav1'] : '' ;
	$nmdcjav1 = (isset($_POST['nmdcjav1'])) ? $_POST['nmdcjav1'] : '' ;
	$doccjav1 = (isset($_POST['doccjav1'])) ? $_POST['doccjav1'] : '' ;
	$nrfonav1 = (isset($_POST['nrfonav1'])) ? $_POST['nrfonav1'] : '' ;
	$cdufava1 = (isset($_POST['cdufava1'])) ? $_POST['cdufava1'] : '' ;
	$vledvmt1 = (isset($_POST['vledvmt1'])) ? $_POST['vledvmt1'] : '' ;
	$tpdocav2 = (isset($_POST['tpdocav2'])) ? $_POST['tpdocav2'] : '' ;
	$cpfcjav2 = (isset($_POST['cpfcjav2'])) ? $_POST['cpfcjav2'] : '' ;
	$ende1av2 = (isset($_POST['ende1av2'])) ? $_POST['ende1av2'] : '' ;
	$emailav2 = (isset($_POST['emailav2'])) ? $_POST['emailav2'] : '' ;
	$nrcepav2 = (isset($_POST['nrcepav2'])) ? $_POST['nrcepav2'] : '' ;
	$vledvmt2 = (isset($_POST['vledvmt2'])) ? $_POST['vledvmt2'] : '' ;
	$dsdopcao = (isset($_POST['dsdopcao'])) ? $_POST['dsdopcao'] : '' ;
	$nrctrant = (isset($_POST['nrctrant'])) ? $_POST['nrctrant'] : '' ;
	$nrender1 = (isset($_POST['nrender1'])) ? $_POST['nrender1'] : '' ;
	$complen1 = (isset($_POST['complen1'])) ? $_POST['complen1'] : '' ;
	$nrcxaps1 = (isset($_POST['nrcxaps1'])) ? $_POST['nrcxaps1'] : '' ;
	$nrender2 = (isset($_POST['nrender2'])) ? $_POST['nrender2'] : '' ;
	$complen2 = (isset($_POST['complen2'])) ? $_POST['complen2'] : '' ;
	$nrcxaps2 = (isset($_POST['nrcxaps2'])) ? $_POST['nrcxaps2'] : '' ;
	$vlpreant = (isset($_POST['vlpreant'])) ? $_POST['vlpreant'] : '' ;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : '' ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$dsjusren = (isset($_POST['dsjusren'])) ? $_POST['dsjusren'] : '' ;
	$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '' ;
	$flgconsu = (isset($_POST['flgconsu'])) ? $_POST['flgconsu'] : '' ;
	$resposta = (isset($_POST['resposta'])) ? $_POST['resposta'] : '' ;
	$blqpreap = (isset($_POST['blqpreap'])) ? $_POST['blqpreap'] : '' ;
    $idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '' ;
    $idcarenc = (isset($_POST['idcarenc'])) ? $_POST['idcarenc'] : '' ;
    $dtcarenc = (isset($_POST['dtcarenc'])) ? $_POST['dtcarenc'] : '' ;
	$vlfinanc = (isset($_POST['vlfinanc'])) ? $_POST['vlfinanc'] : '' ;
	$vlprecar = (isset($_POST['vlprecar'])) ? $_POST['vlprecar'] : '' ;
	
	// Daniel
	$inpesso1 = (isset($_POST['inpesso1'])) ? $_POST['inpesso1'] : '' ;
	$dtnasct1 = (isset($_POST['dtnasct1'])) ? $_POST['dtnasct1'] : '' ;
	$inpesso2 = (isset($_POST['inpesso2'])) ? $_POST['inpesso2'] : '' ;
	$dtnasct2 = (isset($_POST['dtnasct2'])) ? $_POST['dtnasct2'] : '' ;
	$dscatbem = (isset($_POST['dscatbem'])) ? $_POST['dscatbem'] : '' ;
	
	$idfiniof = (isset($_POST['idfiniof'])) ? $_POST['idfiniof'] : '1' ;
	
	// PRJ438 - GAROPC
	$idcobert = (isset($_POST['idcobert'])) ? $_POST['idcobert'] : '' ;
	$tipaber  = (isset($_POST['tipaber']))  ? $_POST['tipaber']  : '' ;
	$nrctater = (isset($_POST['nrctater'])) ? $_POST['nrctater'] : '' ;
	$lintpctr = (isset($_POST['lintpctr'])) ? $_POST['lintpctr'] : '' ;
	$vlropera = (isset($_POST['vlropera'])) ? $_POST['vlropera'] : '' ;
	$permingr = (isset($_POST['permingr'])) ? $_POST['permingr'] : '' ;
	$inresper = (isset($_POST['inresper'])) ? $_POST['inresper'] : '' ;
	$diatrper = (isset($_POST['diatrper'])) ? $_POST['diatrper'] : '' ;
	$tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : '' ;
	$inaplpro = (isset($_POST['inaplpro'])) ? $_POST['inaplpro'] : '' ;
	$vlaplpro = (isset($_POST['vlaplpro'])) ? $_POST['vlaplpro'] : '' ;
	$inpoupro = (isset($_POST['inpoupro'])) ? $_POST['inpoupro'] : '' ;
	$vlpoupro = (isset($_POST['vlpoupro'])) ? $_POST['vlpoupro'] : '' ;
	$inresaut = (isset($_POST['inresaut'])) ? $_POST['inresaut'] : '' ;
	$inaplter = (isset($_POST['inaplter'])) ? $_POST['inaplter'] : '' ;
	$vlaplter = (isset($_POST['vlaplter'])) ? $_POST['vlaplter'] : '' ;
	$inpouter = (isset($_POST['inpouter'])) ? $_POST['inpouter'] : '' ;
	$vlpouter = (isset($_POST['vlpouter'])) ? $_POST['vlpouter'] : '' ;
	// PRJ 438
	$vlrecjg1 = (isset($_POST['vlrecjg1'])) ? $_POST['vlrecjg1'] : '' ;
	$vlrecjg2 = (isset($_POST['vlrecjg2'])) ? $_POST['vlrecjg2'] : '' ;
	
	$array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç","ñ"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç","Ñ"
				   ,"&","¨","~","^","*","#","%","$","!","?",";",">","<","|","+","=","£","¢","¬","§","`","´","¹","²"
				   ,"³","ª","º","°","\"","'","\\","","→");
	$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c","n"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C","N"
				   ,"e"," "," "," "," "," "," "," "," "," ",";"," "," ","|"," "," "," "," "," "," "," "," "," "," "
				   ," "," "," "," "," "," "," ","-","-");
    
	// limpeza dos campos caracteres
	$dsctrliq = trim(str_replace( $array1, $array2, $dsctrliq));
	$dsdrendi = trim(str_replace( $array1, $array2, $dsdrendi));
	$dsinterv = trim(str_replace( $array1, $array2, $dsinterv));
	$ende1av1 = trim(str_replace( $array1, $array2, $ende1av1));
	$emailav1 = trim(str_replace( $array1, $array2, $emailav1));
	$nmdaval2 = trim(str_replace( $array1, $array2, $nmdaval2));
	$dsdocav2 = trim(str_replace( $array1, $array2, $dsdocav2));
	$ende2av2 = trim(str_replace( $array1, $array2, $ende2av2));
	$nmcidav2 = trim(str_replace( $array1, $array2, $nmcidav2));
	$cdnacio2 = trim(str_replace( $array1, $array2, $cdnacio2));
	$dsnivris = trim(str_replace( $array1, $array2, $dsnivris));
	$nmempcje = trim(str_replace( $array1, $array2, $nmempcje));
	$dsobserv = trim(str_replace( $array1, $array2, $dsobserv));
	$dsdebens = trim(str_replace( $array1, $array2, $dsdebens));
	$nmdaval1 = trim(str_replace( $array1, $array2, $nmdaval1));
	$dsdocav1 = trim(str_replace( $array1, $array2, $dsdocav1));
	$ende2av1 = trim(str_replace( $array1, $array2, $ende2av1));
	$nmcidav1 = trim(str_replace( $array1, $array2, $nmcidav1));
	$cdnacio1 = trim(str_replace( $array1, $array2, $cdnacio1));
	$nmdcjav2 = trim(str_replace( $array1, $array2, $nmdcjav2));
	$dsdbeavt = trim(str_replace( $array1, $array2, $dsdbeavt));
	$dsdfinan = trim(str_replace( $array1, $array2, $dsdfinan));
	$dsdalien = trim(str_replace( $array1, $array2, $dsdalien));
	$nmdcjav1 = trim(str_replace( $array1, $array2, $nmdcjav1));
	$ende1av2 = trim(str_replace( $array1, $array2, $ende1av2));
	$emailav2 = trim(str_replace( $array1, $array2, $emailav2));
	$dsdopcao = trim(str_replace( $array1, $array2, $dsdopcao));
	$complen1 = trim(str_replace( $array1, $array2, $complen1));
	$complen2 = trim(str_replace( $array1, $array2, $complen2));
	$dsjusren = trim(str_replace( $array1, $array2, $dsjusren));	
	
	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure   = 'grava-proposta-completa';
	$cddopcao    = $_POST['cddopcao'];
	$i_mensagens = 0;

	$metodoErro = 'bloqueiaFundo(divRotina);';

	if ($operacao == 'F_VALOR' ) {
        $procedure   = 'altera-valor-proposta' ;
        $cddopcao    = 'A';
        $operamail   = 'Alterar Valor do Emprestimo';
        $i_mensagens = 1;
	} else if($operacao == 'F_NUMERO' ) {
              $procedure = 'altera-numero-proposta';
              $cddopcao  = 'A';
              $operamail = 'Alterar Numero da Proposta do Emprestimo';
              $metodoErro = 'bloqueiaFundo($(\'#divUsoGenerico\'));';
	} else if($operacao == 'F_AVALISTA' ) {
              $procedure   = 'atualiza_dados_avalista_proposta';
              $cddopcao    = 'A';
              $operamail   = 'Alterar Avalista do Emprestimo';
              $i_mensagens = 1;
	}
  
  else if ($cddopcao == 'I') {
    $metodoErro = 'controlaOperacao(\'I_INICIO\');';
  }
  
  else if ($cddopcao == 'A') {
    $metodoErro = 'controlaOperacao(\'A_INICIO\');';
  }

	//Tratado separa para não ter que "zerar" todas as outras variaveis
	else if ( $operacao == 'E'        ) {
		$procedure = 'excluir-proposta';
		$cddopcao = 'E';
		$metodoErro = 'controlaOperacao(\'\');';

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0002.p</Bo>';
		$xml .= '		<Proc>'.$procedure.'</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
		$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);
		}

		echo 'controlaOperacao(\'\');';

		die();

	} else if($operacao == 'ENV_ESTEIRA') {
        $dsiduser = session_id();

        $xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "    <Bo>b1wgen0195.p</Bo>";
		$xml .= "    <Proc>Enviar_proposta_esteira</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= "     <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "	  <cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
		$xml .= "	  <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "	  <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
        $xml .= "	  <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";		
		$xml .= "	  <idorigem>".$glbvars["idorigem"]."</idorigem>";
        $xml .= "	  <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	  <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "	  <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";		
		$xml .= "     <nrctremp>".$nrctremp."</nrctremp>";
        $xml .= "     <nrctremp_novo>0</nrctremp_novo>";
        $xml .= "     <dsiduser>".$dsiduser."</dsiduser>";
        $xml .= "     <flreiflx>1</flreiflx>"; // reiniciar fluxo de aprovacao
        $xml .= "     <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao
		$xml .= "  </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml,false);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
        
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){		   
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);controlaOperacao();");';           
           exit;
		}
		
		$oMensagem = getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags,'dsmensag');
        $arMessage = explode("###", $oMensagem);
        $dsmensag1 = '<div style=\"text-align:left;\">'.$arMessage[0].'</div>';
        $dsmensag2 = '';
        if (count($arMessage) > 1) {
            $dsmensag2 = $arMessage[1];
            $dsmensag2 = str_replace('[APROVAR]',  '<img src=\"../../../imagens/geral/motor_APROVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[DERIVAR]',  '<img src=\"../../../imagens/geral/motor_DERIVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[INFORMAR]', '<img src=\"../../../imagens/geral/motor_INFORMAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = str_replace('[REPROVAR]', '<img src=\"../../../imagens/geral/motor_REPROVAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
            $dsmensag2 = '<div style=\"text-align:left; height:100px; overflow-x:hidden; padding-right:25px; font-size:11px; font-weight:normal;\">'.$dsmensag2.'</div>';
        }

        echo 'showError("inform","'.$dsmensag1.$dsmensag2.'","Alerta - Aimaro","bloqueiaFundo(divRotina);controlaOperacao();");';
        exit;
    }

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// //PRJ 438 - GAROPC
	$xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
    $xml .= "    <idcobert>".$idcobert."</idcobert>";
    $xml .= "    <tipaber>".$tipaber."</tipaber>";
    $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "    <nrctater>".$nrctater."</nrctater>";
    $xml .= "    <lintpctr>".$lintpctr."</lintpctr>";
    $xml .= "    <vlropera>".converteFloat($vlropera)."</vlropera>";
    $xml .= "    <permingr>".converteFloat($permingr)."</permingr>";
    $xml .= "    <inresper>".$inresper."</inresper>";
    $xml .= "    <diatrper>".$diatrper."</diatrper>";
    $xml .= "    <tpctrato>".$tpctrato."</tpctrato>";
    $xml .= "    <inaplpro>".$inaplpro."</inaplpro>";
    $xml .= "    <vlaplpro>".converteFloat($vlaplpro)."</vlaplpro>";
    $xml .= "    <inpoupro>".$inpoupro."</inpoupro>";
    $xml .= "    <vlpoupro>".converteFloat($vlpoupro)."</vlpoupro>";
    $xml .= "    <inresaut>".$inresaut."</inresaut>";
    $xml .= "    <inaplter>".$inaplter."</inaplter>";
    $xml .= "    <vlaplter>".converteFloat($vlaplter)."</vlaplter>";
    $xml .= "    <inpouter>".$inpouter."</inpouter>";
    $xml .= "    <vlpouter>".converteFloat($vlpouter)."</vlpouter>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_GAROPC", "GAROPC_GRAVA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        exibirErro('error',$msgErro,'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
    }

    $registros = $xmlObject->roottag->tags[0];
    $idcobope = getByTagName($registros->tags,'idcobert');
    $aux_ingarapr = getByTagName($registros->tags,'ingarapr');
	
	//altera caracteres de qubra de linha por espaco em branco
	$dsjusren = str_replace("\r", '', $dsjusren);
	$dsjusren = str_replace("\n", ' ', $dsjusren);
	$dsobserv = str_replace("\r", '', $dsobserv);
	$dsobserv = str_replace("\n", ' ', $dsobserv);	

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0002.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<cdpactra>'.$glbvars['cdpactra'].'</cdpactra>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<tpemprst>'.$tpemprst.'</tpemprst>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<vllimapv>'.$vllimapv.'</vllimapv>';
	$xml .= '		<qtpreemp>'.$qtpreemp.'</qtpreemp>';
	$xml .= '		<cdfinemp>'.$cdfinemp.'</cdfinemp>';
	$xml .= '		<flgimpnp>'.$flgimpnp.'</flgimpnp>';
	$xml .= '		<dtdpagto>'.$dtdpagto.'</dtdpagto>';
	$xml .= '		<dsctrliq>'.$dsctrliq.'</dsctrliq>';
	$xml .= '		<nrgarope>'.$nrgarope.'</nrgarope>';
	$xml .= '		<dsdopcao>'.$dsdopcao.'</dsdopcao>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
	$xml .= '		<qtopescr>'.$qtopescr.'</qtopescr>';
	$xml .= '		<vlopescr>'.$vlopescr.'</vlopescr>';
	$xml .= '		<dtoutspc>'.$dtoutspc.'</dtoutspc>';
	$xml .= '		<vlsalari>'.$vlsalari.'</vlsalari>';
	$xml .= '		<vlsalcon>'.$vlsalcon.'</vlsalcon>';
	$xml .= '		<nrctacje>'.$nrctacje.'</nrctacje>';
	$xml .= '		<vlmedfat>'.$vlmedfat.'</vlmedfat>';
	$xml .= '		<dsdrendi>'.$dsdrendi.'</dsdrendi>';
	$xml .= '		<dsinterv>'.$dsinterv.'</dsinterv>';
	$xml .= '		<tpdocav1>'.$tpdocav1.'</tpdocav1>';
	$xml .= '		<cpfcjav1>'.$cpfcjav1.'</cpfcjav1>';
	$xml .= '		<ende1av1>'.$ende1av1.'</ende1av1>';
	$xml .= '		<emailav1>'.$emailav1.'</emailav1>';
	$xml .= '		<nrcepav1>'.$nrcepav1.'</nrcepav1>';
	$xml .= '		<nmdaval2>'.$nmdaval2.'</nmdaval2>';
	$xml .= '		<dsdocav2>'.$dsdocav2.'</dsdocav2>';
	$xml .= '		<tdccjav2>'.$tdccjav2.'</tdccjav2>';
	$xml .= '		<ende2av2>'.$ende2av2.'</ende2av2>';
	$xml .= '		<nmcidav2>'.$nmcidav2.'</nmcidav2>';
	$xml .= '		<cdnacio2>'.$cdnacio2.'</cdnacio2>';
	$xml .= '		<vlrenme2>'.$vlrenme2.'</vlrenme2>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<flgcmtlc>'.$flgcmtlc.'</flgcmtlc>';
	$xml .= '		<vlemprst>'.$vlemprst.'</vlemprst>';
	$xml .= '		<dsnivris>'.$dsnivris.'</dsnivris>';
	$xml .= '		<qtdialib>'.$qtdialib.'</qtdialib>';
	$xml .= '		<percetop>'.$percetop.'</percetop>';
	$xml .= '		<qtpromis>'.$qtpromis.'</qtpromis>';
	$xml .= '		<nrctaava>'.$nrctaava.'</nrctaava>';
	$xml .= '		<nrperger>'.$nrperger.'</nrperger>';
	$xml .= '		<dtdrisco>'.$dtdrisco.'</dtdrisco>';
	$xml .= '		<qtifoper>'.$qtifoper.'</qtifoper>';
	$xml .= '		<vlrpreju>'.$vlrpreju.'</vlrpreju>';
	$xml .= '		<dtoutris>'.$dtoutris.'</dtoutris>';
	$xml .= '		<vloutras>'.$vloutras.'</vloutras>';
	$xml .= '		<nmempcje>'.$nmempcje.'</nmempcje>';
	$xml .= '		<nrcpfcje>'.$nrcpfcjg.'</nrcpfcje>';
	$xml .= '		<dsobserv>'.$dsobserv.'</dsobserv>';
	$xml .= '		<dsdebens>'.$dsdebens.'</dsdebens>';
	$xml .= '		<nmdaval1>'.$nmdaval1.'</nmdaval1>';
	$xml .= '		<dsdocav1>'.$dsdocav1.'</dsdocav1>';
	$xml .= '		<tdccjav1>'.$tdccjav1.'</tdccjav1>';
	$xml .= '		<ende2av1>'.$ende2av1.'</ende2av1>';
	$xml .= '		<nmcidav1>'.$nmcidav1.'</nmcidav1>';
	$xml .= '		<cdnacio1>'.$cdnacio1.'</cdnacio1>';
	$xml .= '		<nrcpfav2>'.$nrcpfav2.'</nrcpfav2>';
	$xml .= '		<nmdcjav2>'.$nmdcjav2.'</nmdcjav2>';
	$xml .= '		<doccjav2>'.$doccjav2.'</doccjav2>';
	$xml .= '		<nrfonav2>'.$nrfonav2.'</nrfonav2>';
	$xml .= '		<cdufava2>'.$cdufava2.'</cdufava2>';
	$xml .= '		<vlrenme1>'.$vlrenme1.'</vlrenme1>';
	$xml .= '		<dsdbeavt>'.$dsdbeavt.'</dsdbeavt>';
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<vlutiliz>'.$vlutiliz.'</vlutiliz>';
	$xml .= '		<vlpreemp>'.$vlpreemp.'</vlpreemp>';
	$xml .= '		<cdlcremp>'.$cdlcremp.'</cdlcremp>';
	$xml .= '		<flgimppr>'.$flgimppr.'</flgimppr>';
	$xml .= '		<idquapro>'.$idquapro.'</idquapro>';
	//Adição de novo campo (Qualif. Oper. Controle) Diego Simas (AMcom) 
	//$xml .= '		<idquaprc>'.$idquaprc.'</idquaprc>';
	$xml .= '		<flgpagto>'.$flgpagto.'</flgpagto>';
	$xml .= '		<nrctaav2>'.$nrctaav2.'</nrctaav2>';
	$xml .= '		<dtcnsspc>'.$dtcnsspc.'</dtcnsspc>';
	$xml .= '		<vltotsfn>'.$vltotsfn.'</vltotsfn>';
	$xml .= '		<nrliquid>'.$nrliquid.'</nrliquid>';
	$xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
	$xml .= '		<vlsfnout>'.$vlsfnout.'</vlsfnout>';
	$xml .= '		<vlalugue>'.$vlalugue.'</vlalugue>';
	$xml .= '		<inconcje>'.$inconcje.'</inconcje>';
	$xml .= '		<flgdocje>'.$flgdocje.'</flgdocje>';
	$xml .= '		<perfatcl>'.$perfatcl.'</perfatcl>';
	$xml .= '		<dsdfinan>'.$dsdfinan.'</dsdfinan>';
	$xml .= '		<dsdalien>'.$dsdalien.'</dsdalien>';
	$xml .= '		<nrcpfav1>'.$nrcpfav1.'</nrcpfav1>';
	$xml .= '		<nmdcjav1>'.$nmdcjav1.'</nmdcjav1>';
	$xml .= '		<doccjav1>'.$doccjav1.'</doccjav1>';
	$xml .= '		<nrfonav1>'.$nrfonav1.'</nrfonav1>';
	$xml .= '		<cdufava1>'.$cdufava1.'</cdufava1>';
	$xml .= '		<vledvmt1>'.$vledvmt1.'</vledvmt1>';
	$xml .= '		<tpdocav2>'.$tpdocav2.'</tpdocav2>';
	$xml .= '		<cpfcjav2>'.$cpfcjav2.'</cpfcjav2>';
	$xml .= '		<ende1av2>'.$ende1av2.'</ende1av2>';
	$xml .= '		<emailav2>'.$emailav2.'</emailav2>';
	$xml .= '		<nrcepav2>'.$nrcepav2.'</nrcepav2>';
	$xml .= '		<vledvmt2>'.$vledvmt2.'</vledvmt2>';
	$xml .= '		<nrctrant>'.$nrctrant.'</nrctrant>';
	$xml .= '		<nrender1>'.$nrender1.'</nrender1>';
	$xml .= '		<complen1>'.$complen1.'</complen1>';
	$xml .= '		<nrcxaps1>'.$nrcxaps1.'</nrcxaps1>';
	$xml .= '		<nrender2>'.$nrender2.'</nrender2>';
	$xml .= '		<complen2>'.$complen2.'</complen2>';
	$xml .= '		<nrcxaps2>'.$nrcxaps2.'</nrcxaps2>';
	$xml .= '		<vlpreant>'.$vlpreant.'</vlpreant>';	
	$xml .= '		<operacao>'.$operacao.'</operacao>';
	$xml .= '		<flgconsu>'.$flgconsu.'</flgconsu>';
	$xml .= '		<vleprori>'.$vlpreant.'</vleprori>';
    $xml .= '		<idcarenc>'.$idcarenc.'</idcarenc>';
    $xml .= '		<dtcarenc>'.$dtcarenc.'</dtcarenc>';
	$xml .= '		<vlfinanc>'.$vlfinanc.'</vlfinanc>';
	
	// Daniel 
	$xml .= '		<inpesso1>'.$inpesso1.'</inpesso1>';
	$xml .= '		<dtnasct1>'.$dtnasct1.'</dtnasct1>';
	$xml .= '		<inpesso2>'.$inpesso2.'</inpesso2>';
	$xml .= '		<dtnasct2>'.$dtnasct2.'</dtnasct2>';
	
	if ($procedure == 'grava-proposta-completa'){
		$xml .= '		<dsjusren>'.$dsjusren.'</dsjusren>';
	}
	$xml .= '		<dtlibera>'.$dtlibera.'</dtlibera>';
    $xml .= '		<idcobope>'.$idcobope.'</idcobope>';
	$xml .= '		<idfiniof>'.$idfiniof.'</idfiniof>';
    $xml .= '		<dscatbem>'.$dscatbem.'</dscatbem>';	
	$xml .= '		<cdcoploj>0</cdcoploj>';
	$xml .= '		<nrcntloj>0</nrcntloj>';
	// PRJ 438
	$xml .= '		<vlrecjg1>'.$vlrecjg1.'</vlrecjg1>';
	$xml .= '		<vlrecjg2>'.$vlrecjg2.'</vlrecjg2>';
	// PRJ 438 - Parametro com valor retornado da tela GAROPC(garantia), para verificar se deve perder aprovacao
	$xml .= '	    <ingarapr>'.$aux_ingarapr.'</ingarapr>';

	$xml .= '	</Dados>';
	$xml .= '</Root>';
    

	$xmlResult = getDataXML($xml);

	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);
	}

	if ( $xmlObjeto->roottag->tags[0]->attributes['RECIDEPR'] != '') {
		$recidepr  = $xmlObjeto->roottag->tags[0]->attributes['RECIDEPR'];
		$nrctremp  = $xmlObjeto->roottag->tags[0]->attributes['NRCTREMP'];
		$flmudfai  = $xmlObjeto->roottag->tags[0]->attributes['FLMUDFAI'];
	}
	else 
	if ($operacao == 'F_VALOR') {
		$flmudfai  = $xmlObjeto->roottag->tags[0]->attributes['FLMUDFAI'];
	}

	if($operacao == 'VI' ) {
		$operamail = 'Novo Emprestimo';
	}else { if($operacao == 'VA' ) {
			   $operamail = 'Alterar Emprestimo';
			}
	}

	$msg = Array();
	$mensagens = $xmlObjeto->roottag->tags[$i_mensagens]->tags;
				
	foreach( $mensagens as $mensagem ) {
		$msg[] = str_replace('|@|','<br>',getByTagName($mensagem->tags,'dsmensag'));		
	}
	
	$stringArrayMsg  = implode( "|", $msg);
	
	if( $operacao == 'F_VALOR' ){
		
	    echo 'mostraValores("' . $stringArrayMsg  . '" , "' . $flmudfai . '" );';

	} else {
		echo "nrdrecid = '".$recidepr."';";
		echo "nrctremp = '".$nrctremp."';";
		echo "qtpromis = '".$qtpromis."';";
	}

	if( $operacao == 'F_NUMERO' ){
		echo 'fechaNumero(\'\');';
		die();
	} else if ( $operacao == 'F_AVALISTA' ) {
        echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao()\');';
		die();
    }
	
	// Se inclusao e alteracao completa e microcredito, salvar o questionario
	if ($procedure == 'grava-proposta-completa' || $operacao == 'F_VALOR'){
		
		if ($procedure == 'grava-proposta-completa') {
			$metodoConsultas = 'confirmaConsultas(\"' . $flmudfai . '\", \"AT\")';
		}
		
		if ($resposta != '') {
		
			$strnomacao = 'GRAVA_RESPOSTAS_MCR';
		
			$resposta = '<![CDATA[<dados>' . $resposta . '</dados>]]>';	
			
			// Montar o xml para requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
			$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";		
			$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";	
			$xml .= "    <resposta>".$resposta."</resposta>";	
			$xml .= " </Dados>";
			$xml .= "</Root>";
				
			$xmlResult = mensageria($xml, "PARMCR" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
			$xmlObj    = getObjectXML($xmlResult);
		}
			
		if ($operacao == 'F_VALOR') {
			die();
		}
		
	}
		
	if ($procedure == 'grava-proposta-completa' && $blqpreap == true){
		
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
			
		$xmlResult = mensageria($xml, "CADPRE" , 'BLOQ_PRE_APRV_REF', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
		$xmlObj    = getObjectXML($xmlResult);
	}
	
	if ($procedure == 'grava-proposta-completa') {
		echo 'exibirMensagens("'.$stringArrayMsg.'","bloqueiaFundo($(\"#divConfirm\")); verificaCriticasRating(\"\"); ' . $metodoConsultas.'");bloqueiaFundo($("#divError"));';
	} else {
	    echo 'exibirMensagens("'.$stringArrayMsg.'","bloqueiaFundo($(\"#divConfirm\"))");bloqueiaFundo($("#divError"));';
	}
	
	$msgAtCad = '764 - Registrar revisao cadastral? (S/N)';
	$chaveAlt = $glbvars['cdcooper'].','.$nrdconta.','.$glbvars['dtmvtolt'];
	$tpAtlCad = 2;
	
	if ($procedure != 'grava-proposta-completa') {
		exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0056.p\',\'\',\'verificaCriticasRating();\')','verificaCriticasRating(\'\')',false);
	}

?>