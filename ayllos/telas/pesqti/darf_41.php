<? 
 /*!
 * FONTE        : darf_41.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : Junho/2014 
 * OBJETIVO     : Alimenta campos com detalhes das DARFs arrecadadas na Rot.41 SD. 75897
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	isPostMethod();		
		
	$dtapurac = $_POST['dtapurac'];
	$nrcpfcgc = $_POST['nrcpfcgc'];
	$cdtribut = $_POST['cdtribut'];
	$nrrefere = $_POST['nrrefere'];
	$dtlimite = $_POST['dtlimite'];
	$vllanmto = $_POST['vllanmto'];
	$vlrmulta = $_POST['vlrmulta'];
	$vlrjuros = $_POST['vlrjuros'];
	$vlrtotal = $_POST['vlrtotal'];		
	$vlrecbru = $_POST['vlrecbru'];		
	$vlpercen = $_POST['vlpercen'];
		
	include('detalhe_darf_41.php');

?>

<script>
$('#dtapurac','#'+frmDarf41).val('<? echo $dtapurac ?>');
$('#nrcpfcgc','#'+frmDarf41).val('<? echo $nrcpfcgc ?>');
$('#cdtribut','#'+frmDarf41).val('<? echo $cdtribut ?>');
$('#nrrefere','#'+frmDarf41).val('<? echo $nrrefere ?>');
$('#dtlimite','#'+frmDarf41).val('<? echo $dtlimite ?>');
$('#vllanmto','#'+frmDarf41).val('<? echo $vllanmto ?>');
$('#vlrmulta','#'+frmDarf41).val('<? echo $vlrmulta ?>');
$('#vlrjuros','#'+frmDarf41).val('<? echo $vlrjuros ?>');
$('#vlrtotal','#'+frmDarf41).val('<? echo $vlrtotal ?>');
$('#vlrecbru','#'+frmDarf41).val('<? echo $vlrecbru ?>');
$('#vlpercen','#'+frmDarf41).val('<? echo $vlpercen ?>');
msgretor = '<? echo $msgretor ?>';
</script>