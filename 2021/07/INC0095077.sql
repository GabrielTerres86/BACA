

dtmvtolt	date	y	sysdate	data do movimento atual.
cdagenci	number(5)	y	0	numero do pa.
cdbccxlt	number(5)	y	0	codigo do banco/caixa.
nrdolote	number(10)	y	0	numero do lote.
nrdconta	number(10)	y	0	numero da conta/dv do associado.
nrctremp	number(10)	y	0	numero do contrato de emprestimo.
cdfinemp	number(5)	y	0	codigo da finalidade do emprestimo.
cdlcremp	number(5)	y	0	codigo da linha de credito do emprestimo.
dtultpag	date	y		data do ultimo pagamento.
nrctaav1	number(10)	y	0	numero da conta do primeiro avalista.
nrctaav2	number(10)	y	0	numero da conta do segundo avalista.
qtpreemp	number(5)	y	0	quantidade de prestacoes do emprestimo.
qtprepag	number(5)	y	0	quantidade de prestacoes pagas.
txjuremp	number(25,7)	y	0	taxa de juros do emprestimo.
vljuracu	number(25,2)	y	0	valor dos juros acumulados para o emprestimo.
vljurmes	number(25,2)	y	0	valor dos juros acumulados no mes anterior.
vlpagmes	number(25,2)	y	0	valor que foi pago no mes corrente.
vlpreemp	number(25,2)	y	0	valor da prestacao do emprestimo.
vlsdeved	number(35,10)	y	0	valor do saldo devedor do emprestimo.
vlemprst	number(25,2)	y	0	valor do emprestimo.
cdempres	number(10)	y	0	codigo da empresa onde o associado trabalha.
inliquid	number(5)	y	0	indicador de liquidacao do emprestimo.
nrcadast	number(10)	y	0	numero do cadastro/dv do associado.
qtprecal	number(25,4)	y	0	quantidade de prestacoes calculadas.
qtmesdec	number(10)	y	0	quantidade de meses decorridos.
dtinipag	date	y		data de inicio do pagamento do emprestimo.
flgpagto	number	y	1	"f" para debitar no dia da folha ou "c" para debitar em c/c.
dtdpagto	date	y		data do pagamento da primeira prestacao.
indpagto	number(5)	y	0	indica se foi efetuado pagamento no mes (0-nao pagou; 1-pago).
vliofepr	number(25,2)	y	0	valor do iof cobrado no contrato.
vlprejuz	number(25,2)	y	0	valor do prejuizo.
vlsdprej	number(25,2)	y	0	saldo em prejuizo.
inprejuz	number(5)	y	0	indicador do0 prejuizo (1 - em prejuizo).
vljraprj	number(25,2)	y	0	juros acumulados no prejuizo.
vljrmprj	number(25,2)	y	0	valor dos juros calculados no mes em prejuizo.
dtprejuz	date	y		data em que foi lancado em prejuizo.
tpdescto	number(5)	y	1	tipo de desconto do emprestimo
cdcooper	number(10)	y	0	codigo que identifica a cooperativa.
tpemprst	number(5)	y	0	contem o tipo do emprestimo.
txmensal	number(25,6)	y	0	taxa mensal.
vlservtx	number(25,2)	y	0	contem o valor de servicos e taxas extras.
vlpagstx	number(25,2)	y	0	contem o valor pago de servicos e taxas extras.
vljuratu	number(25,2)	y	0	contem o valor dos juros acumulados no mes atual.
vlajsdev	number(25,2)	y	0	valor de ajuste do saldo devedor do emprestimo.
dtrefjur	date	y		data de referencia da ultima vez que foi calculado juros para o saldo devedor do contrato.
diarefju	number(2)	y	0	dia de referencia da ultima vez que foi calculado juros para o saldo devedor do contrato.
flliqmen	number	y	0	indica se o emprestimo foi liquidado no mensal.
mesrefju	number(2)	y	0	mes de referencia da ultima vez que foi calculado juros para o saldo devedor do contrato.
anorefju	number(4)	y	0	ano  de referencia da ultima vez que foi calculado juros para o saldo devedor do contrato.
flgdigit	number	y	0	contem o indicador de digitalizacao do documento.
vlsdvctr	number(19,2)	y	0	valor do saldo devedor contratado.
qtlcalat	number(13,4)	y	0	quantidade de lancamentos atualizados.
qtpcalat	number(13,4)	y	0	quantidade de prestacoes calculadas atualizadas
vlsdevat	number(35,10)	y	0	valor do saldo devedor do emprestimo atualizado.
vlpapgat	number(19,2)	y	0	valor das prestacoes a pagar atualizadas.
vlppagat	number(19,2)	y	0	valor das prestacoes pagas atualizadas.
qtmdecat	number(8)	y	0	quantidade de meses decorridos atualizados.
progress_recid	number	y		
qttolatr	number(5)	y	0	prazo de tolerancia para cobranca de multa e mora parcelas em atraso.
cdorigem	number(3)	y	0	"/** -> origem = 1 - ayllos                               **/
/** -> origem = 2 - caixa                                **/
/** -> origem = 3 - internet                             **/
/** -> origem = 4 - cash                                 **/
/** -> origem = 5 - intranet (ayllos web)                **/
/** -> origem = 6 - ura                                  **/"
vltarifa	number(25,2)	y	0	valor total da tarifa de contratacao.
vltariof	number(25,2)	y	0	valor total da tarifa de  iof.
vltaxiof	number(25,8)		0	taxa de iof. 
nrconbir	number(10)	y	0	numero do cgc da empresa que o socio / acionista possui participacao
inconcje	number(1)	y	0	consulta conjuge no biro de consultas automaticas
vlttmupr	number(25,2)	y	0	valor total da multa em prejuizo.
vlttjmpr	number(25,2)	y	0	valor total da mora em prejuizo.
vlpgmupr	number(25,2)	y	0	valor total pago da multa em prejuizo.
vlpgjmpr	number(25,2)	y	0	valor total pago dos juros de mora em prejuizo.
qtimpctr	number(3)		0	quantidade de vezes que o contrato foi impresso
dtliquid	date	y		data da liquidacao do contrato
dtultest	date	y		data do ultimo estorno
dtapgoib	date	y		data do aceite de pagamento via internet bank
iddcarga	number(6)		0	id da carga do pre-aprovado que originou o emprestimo
cdopeori	varchar2(10)		' '	codigo do operador original do registro
cdageori	number(5)		0	codigo da agencia original do registro
dtinsori	date	y		data  de criação do registro
cdopeefe	varchar2(10)		' '	operador de efetivacao da proposta
dtliqprj	date	y		data de liquidacao do prejuizo
vlsprjat	number(25,2)		0	saldo em prejuizo do dia anterior.
dtrefatu	date	y		data de referencia da criacao ou ultima atualizacao do registro (alimentado via trigger)
idfiniof	number(1)		0	indicador de financiamento de iof junto ao emprestimo (0-nao financia/ 1-financia)
vliofcpl	number(25,2)		0	valor do iof complementar de atraso
vliofadc	number(25,2)		0	valor do iof adicional na contratacao
vlsprojt	number(25,2)		0	saldo devedor projetado
dtrefcor	date	y		data de referencia da ultima vez que foi calculado o juros de correcao.
idquaprc	number(5)		1	identificacao da qualificacao da operacao - controle (proposta)
vlpagiof	number(25,2)		0	valor total pago do iof
vlaqiofc	number(25,8)		0	valor da aliquota complementar para cobranca do iof
inrisco_refin	number(5)	y		nivel de risco do refinanciamento(aceleracao)
dtinicio_atraso_refin	date	y		data de inicio do pior atraso dos contratos refinanciados
qtdias_atraso_refin	number(5)		0	quantidade dias atraso utilizado para calculo risco refinanciamento
vliofpri	number(25,2)	y		valor do iof principal na contratacao
vltiofpr	number(25,2)	y		valor total do iof em prejuizo.
vlpiofpr	number(25,2)	y		valor total pago do iof em prejuizo
vlsaldo_refinanciado	number(25,2)	y		valor do saldo refinanciado para melhora
iddacao_bens	number(10)	y		identificacao do bem no cadastro de emprestimos(crapepr).
