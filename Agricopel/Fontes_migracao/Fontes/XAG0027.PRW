#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"

/*
Programa.: XAG0027
Autor....: Emerson - Sla
Data.....: 05/05/2018
Descricao: Calculo de Custo Agricopel
Uso......: Agricopel
*/
//Start Job para XAG0027S(Excução via Schedule)
User Function XAG0027()
	
	Local aEmpDePara := {}

	AADD(aEmpDePara,{'01','03'})
	AADD(aEmpDePara,{'11','01'})
	AADD(aEmpDePara,{'12','01'})
	AADD(aEmpDePara,{'15','01'})
   //AADD(aEmpDePara,{'16','01'})
	
	startjob("U_XAG0027S",getenvserver(),.T.,@aEmpDePara)
	

Return

//Geração de rotina Via Schedule
User Function XAG0027S(aEmpDePara) 


	For nCountPara := 1 To Len(aEmpDePara)

			cEmpPara     := aEmpDePara[nCountPara][1]
			cFilialPara  := aEmpDePara[nCountPara][2]
                
			PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","ZDE","SB2","SD2","SD3","SF2"
			RPCSetType(3)
			RPCSetEnv(cEmpPara, cFilialPara)
			
			U_XAG027C()
            
			RPCClearEnv()
			dbcloseall()
			RESET ENVIRONMENT 

	Next nCountPara
	
Return      
                         

User Function XAG027C()

Local lCpoSD2A 	:= SD2->(FieldPos("D2_XSALDNF")) > 0        	// Verifica a existencia do saldo nf
Local MVXTIPCST:= SuperGetMV('MV_XTIPCST',.F., 'CO')
Local aTipos := StrToKarr(MVXTIPCST,',')
Local nx:=0
Local _cTIPO:=""
Private cAliasTop:="KARDEXSQL"
Private aSalAtu   := { 0,0,0,0,0,0,0 }
Local_cTIPO:=""
IF lCpoSD2A == .F.
	Return
Endif
For nx:=1 To len(aTipos)
	_cTIPO+="'"+aTipos[nx]+"'"
Next NX
Dbselectarea("ZDE")
Dbsetorder(1)
cQuery:=''
cQuery := " SELECT B2_FILIAL,B2_COD,B2_LOCAL FROM "+RetSqlName("SB2")+"(NOLOCK) B2, "+RetSqlName("SB1")+"(NOLOCK) B1 "
cQuery += " WHERE B2.D_E_L_E_T_ = ' '  AND B1.D_E_L_E_T_ = ' '"
//cQuery += " AND B1.B1_UM = 'L ' "   //comentado por solicitacao do Alexandre 16/05/208
cQuery += " AND B2.B2_COD = B1.B1_COD"
// cQuery += " AND B1.B1_COD = '00044' " // thiago quando quer testar determinado produto
cQuery += " AND B2.B2_FILIAL = '"+SM0->M0_CODFIL+"'"
cQuery += " GROUP BY B2_FILIAL,B2_COD,B2_LOCAL"
cQuery += " ORDER BY B2_FILIAL,B2_COD,B2_LOCAL"
//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSB2",.T.,.T.)
DbSelectArea("TRBSB2")
While !EOF()
	Processa( {|| ProcTRB() }, "Aguarde...", "Analisando SD2 ",.F.)
	DbSelectArea("TRBSB2")
	Dbskip()
Enddo
DbSelectArea("TRBSB2")
Dbclosearea()
Return NIL

Static Function ProcTRB()

Static lIxbConTes   := NIL
Local mv_par08 := TRBSB2->B2_LOCAL
Local _cProd   := TRBSB2->B2_COD
Local MV_PAR17 := 1
Local aDadosTran:={},lContinua := .F.
Local nTipo     := 0
Local nTam      :=18
Local cProdAnt  := ""
Local cLocalAnt := ""
Local nCusMed   := 0
Local lFirst1   := .T.
Local aSalAlmox := {}
Local nEntrada  := 0, nSaida  :=0
Local nCEntrada := 0, nCSaida :=0
Local nGEntrada := 0, nGSaida :=0
Local nRec1,nRec2,nRec3,nSavRec,dCntData
Local cPicB2Qt  := PesqPictQt("B2_QATU" ,18)
Local cPicB2Qt2 := PesqPictQt("B2_QTSEGUM" ,18)
Local cPicD1Qt  := PesqPict("SD1","D1_QUANT" ,18)
Local cPicD2Qt  := PesqPict("SD2","D2_QUANT" ,18)
Local cPicD3Qt  := PesqPict("SD3","D3_QUANT" ,18)
Local cPicB2Tot := PesqPictQt("B2_VATU1",18)
Local cPicB2Cust:= PesqPict("SB2","B2_CM1",18)
Local cPicD1Cust:= PesqPict("SD1","D1_CUSTO")
Local cPicD2Cust:= PesqPict("SD2","D2_CUSTO1")
Local cPicD3Cust:= PesqPict("SD3","D3_CUSTO1")
Local lDev  // Flag que indica se nota ‚ devolu‡ao (.T.) ou nao (.F.)
Local cCusto, lImpLivro, lImpTermos, cCond1, cCond2
Local nAcho,i,aGrupos:={},cAlias
Local cTRBSD1	:= CriaTrab(,.f.)
Local cTRBSD2	:= Subs(cTrbSD1,1,7)+"A"
Local cTRBSD3	:= Subs(cTrbSD1,1,7)+"B"
Local nInd,cIndice	:="",cCampo1,cCampo2,cCampo3,cCampo4
Local cNumSeqTr := "" , nRegTr := 0
Local cSeqIni 	:= Replicate("z",6)
Local nTotRegs  := 0

// Indica se deve imprimir movimento invertido (almox. de processo)
Local lInverteMov :=.F.
Local lPriApropri :=.T.

Local nTamSX1 := Len(SX1->X1_GRUPO)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lTesNEst := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Codigo do produto importado - NAO DEVE SER LISTADO           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cProdImp := GETMV("MV_PRODIMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArq1 := ""
Local nInd1 := 0

Local nRecTrf1 := 0
Local nRecTrf2 := 0
Local aRecTRF  := {}


Local cQueryB1A:= ""
Local cQueryB1C:= ""
Local cQueryB1D:= ""

Local   MV_PAR05:= SuperGetMV("MV_ULMES",.F.,'01/01/02') //ctod('01/04/18')
Local   MV_PAR06:= DDATABASE+1

Private _cFilial := TRBSB2->B2_FILIAL

cQueryB1C:=  " SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = '"+_cProd+"'"
cQueryB1C+=  " and SB1.D_E_L_E_T_=' '"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por empresa              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCusUnif:=.F.

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SD1")           // Itens de Entrada
nTotRegs += LastRec()

dbSelectArea("SD2")           // Itens de Saida
nTotRegs += LastRec()

dbSelectArea("SD3")           // movimentacoes internas (producao/requisicao/devolucao)
nTotRegs += LastRec()

dbSelectArea("SB2")			  // Saldos em estoque
dbSetOrder(1)
nTotRegs += LastRec()

//                            1,                 2,               3,        4,           5,          6,            7,                 8,              9,        10,      11,                 12,              13,            14,                 15,                 16,              17,   18,   19                    20,          21,       22,            23,      24
// cQueryD1:= "SELECT 'SD1' ARQ,SB1.B1_COD PRODUTO,SB1.B1_TIPO TIPO,SB1.B1_UM,SB1.B1_GRUPO,SB1.B1_DESC,SB1.B1_POSIPI,D1_SEQCALC SEQCALC,D1_DTDIGIT DATA,D1_TES TES,D1_CF CF,D1_NUMSEQ SEQUENCIA,D1_DOC DOCUMENTO,D1_SERIE SERIE,D1_QUANT QUANTIDADE,D1_QTSEGUM QUANT2UM,D1_Local ARMAZEM,'' PROJETO,'' OP,'' CC,D1_FORNECE FORNECEDOR,D1_LOJA LOJA,'' PEDIDO,D1_TIPO TIPONF,D1_CUSTO"

cQueryD1P := "SELECT 'SD1' ARQ"				// 01
cQueryD1P += ", SB1.B1_COD PRODUTO"			// 02
cQueryD1P += ", SB1.B1_TIPO TIPO"			// 03
cQueryD1P += ", SB1.B1_UM"					// 04
cQueryD1P += ", SB1.B1_GRUPO"				// 05
cQueryD1P += ", SB1.B1_DESC"				// 06
cQueryD1P += ", SB1.B1_POSIPI"				// 07
cQueryD1P += ", D1_SEQCALC SEQCALC"			// 08
cQueryD1P += ", D1_DTDIGIT DATA"			// 09
cQueryD1P += ", D1_TES TES"					// 10
cQueryD1P += ", D1_CF CF"					// 11
cQueryD1P += ", D1_NUMSEQ SEQUENCIA"		// 12
cQueryD1P += ", D1_DOC DOCUMENTO"			// 13
cQueryD1P += ", D1_SERIE SERIE"				// 14
cQueryD1P += ", D1_QUANT QUANTIDADE"		// 15
cQueryD1P += ", D1_QTSEGUM QUANT2UM"		// 16
cQueryD1P += ", D1_LOCAL ARMAZEM"			// 17
cQueryD1P += ", '' PROJETO"					// 18
cQueryD1P += ", '' OP"						// 19
cQueryD1P += ", '' CC"						// 20
cQueryD1P += ", D1_FORNECE FORNECEDOR"		// 21
cQueryD1P += ", D1_LOJA LOJA"				// 22
cQueryD1P += ", '' PEDIDO"					// 23
cQueryD1P += ", D1_TIPO TIPONF"				// 24
cQueryD1P += ", D1_CUSTO"					// 25
cQueryD1P += " CUSTO"
cQueryD1P += ", '' TRT" 					// 26
cQueryD1P += ", D1_LOTECTL LOTE"	    	// 28
cQueryD1P += ", SD1.R_E_C_N_O_ NRECNO"	// 29

cQueryD1 := " FROM "
// cQueryD1 += RetSqlName("SB1") + " SB1 , "+ RetSqlName("SD1")+ " SD1 , "+ RetSqlName("SF4")+" SF4 "
cQueryD1 += RetSqlName("SB1") + "(NOLOCK) SB1"
cQueryD1 += (", " + RetSqlName("SD1")+ "(NOLOCK) SD1 ")
cQueryD1 += (", " + RetSqlName("SF4")+ "(NOLOCK) SF4 ")
cQueryD1 += " WHERE SB1.B1_COD = D1_COD"
cQueryD1 += (" AND D1_FILIAL = '"+_cFILIAL+"'")
// cQueryD1 += " AND F4_FILIAL = '"+xFilial("SF4")+"' AND SD1.D1_TES = F4_CODIGO AND F4_ESTOQUE = 'S'"
cQueryD1 += (" AND F4_FILIAL = '" + xFilial("SF4") + "'")
cQueryD1 += (" AND SD1.D1_TES = F4_CODIGO AND F4_ESTOQUE = 'S'")
// cQueryD1 += " AND D1_DTDIGIT >= '"+DTOS(mv_par05)+"' AND D1_DTDIGIT <= '"+DTOS(mv_par06)+"'"
cQueryD1 += (" AND D1_DTDIGIT >= '" + DTOS(mv_par05) + "'")
cQueryD1 += (" AND D1_DTDIGIT <= '" + DTOS(mv_par06) + "'")
cQueryD1 +=  " AND D1_ORIGLAN <> 'LF'"
cQueryD1 += " AND D1_LOCAL = '" + mv_par08 + "'"
cQueryD1 += " AND SD1.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' '"

cQueryD2P := " SELECT 'SD2'"
cQueryD2P += ", SB1.B1_COD"
cQueryD2P += ", SB1.B1_TIPO"
cQueryD2P += ", SB1.B1_UM"
cQueryD2P += ", SB1.B1_GRUPO"
cQueryD2P += ", SB1.B1_DESC"
cQueryD2P += ", SB1.B1_POSIPI"
cQueryD2P += ", D2_SEQCALC"
cQueryD2P += ", D2_EMISSAO"
cQueryD2P += ", D2_TES"
cQueryD2P += ", D2_CF"
cQueryD2P += ", D2_NUMSEQ"
cQueryD2P += ", D2_DOC"
cQueryD2P += ", D2_SERIE"
cQueryD2P += ", D2_QUANT"
cQueryD2P += ", D2_QTSEGUM"
cQueryD2P += ", D2_LOCAL"
cQueryD2P += ", ''"
cQueryD2P += ", ''"
cQueryD2P += ", ''"
cQueryD2P += ", D2_CLIENTE"
cQueryD2P += ", D2_LOJA"
cQueryD2P += ", D2_PEDIDO"
cQueryD2P += ", D2_TIPO"
cQueryD2P += ", D2_CUSTO1"
cQueryD2P += ", ''"
cQueryD2P += ", D2_LOTECTL"
cQueryD2P += ", SD2.R_E_C_N_O_ "	// 29
cQueryD2 := " FROM "
cQueryD2 += RetSqlName("SB1") + "(NOLOCK) SB1 , "+ RetSqlName("SD2")+ "(NOLOCK) SD2 , "+ RetSqlName("SF4")+"(NOLOCK) SF4 "
cQueryD2 += " WHERE SB1.B1_COD = D2_COD AND D2_FILIAL = '"+_cFilial+"'"
cQueryD2 += " AND F4_FILIAL = '"+xFilial("SF4")+"' AND SD2.D2_TES = F4_CODIGO AND F4_ESTOQUE = 'S'"
cQueryD2 += " AND D2_EMISSAO >= '"+DTOS(mv_par05)+"' AND D2_EMISSAO <= '"+DTOS(mv_par06)+"'"
cQueryD2 += " AND D2_ORIGLAN <> 'LF'"
cQueryD2 += " AND D2_LOCAL = '"+mv_par08+"'"
//cQueryD2 += " AND D2_DOC in ('050560')  " // thiago
//cQueryD2 += " AND D2_LOCAL in ('01') "    // thiago produto B1_LOCPAD estava com armazem distinto do item da nota D2_LOCAL
cQueryD2 += " AND SD2.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' '"


// cQueryD3 := " SELECT 'SD3',SB1.B1_COD,SB1.B1_TIPO,SB1.B1_UM,SB1.B1_GRUPO,SB1.B1_DESC,SB1.B1_POSIPI,D3_SEQCALC,D3_EMISSAO,D3_TM,D3_CF,D3_NUMSEQ,D3_DOC,'',D3_QUANT,D3_QTSEGUM,D3_Local,D3_OP,D3_CC,'','','','',D3_CUSTO"
cQueryD3P := " SELECT 'SD3'"
cQueryD3P += ", SB1.B1_COD"
cQueryD3P += ", SB1.B1_TIPO"
cQueryD3P += ", SB1.B1_UM"
cQueryD3P += ", SB1.B1_GRUPO"
cQueryD3P += ", SB1.B1_DESC"
cQueryD3P += ", SB1.B1_POSIPI"
cQueryD3P += ", D3_SEQCALC"
cQueryD3P += ", D3_EMISSAO"
cQueryD3P += ", D3_TM"
cQueryD3P += ", D3_CF"
cQueryD3P += ", D3_NUMSEQ"
cQueryD3P += ", D3_DOC"
cQueryD3P += ", ''"
cQueryD3P += ", D3_QUANT"
cQueryD3P += ", D3_QTSEGUM"
cQueryD3P += ", D3_LOCAL"
cQueryD3P += ", D3_PROJPMS"
cQueryD3P += ", D3_OP"
cQueryD3P += ", D3_CC"
cQueryD3P += ", ''"
cQueryD3P += ", ''"
cQueryD3P += ", ''"
cQueryD3P += ", ''"
cQueryD3P += ", D3_CUSTO1"
cQueryD3P += ", D3_TRT"
cQueryD3P += ", D3_LOTECTL"
cQueryD3P += ", SD3.R_E_C_N_O_"		// 29
cQueryD3 := " FROM "
cQueryD3 += RetSqlName("SB1") + "(NOLOCK) SB1 , "+ RetSqlName("SD3")+ "(NOLOCK) SD3 "
cQueryD3 += " WHERE SB1.B1_COD = D3_COD AND D3_FILIAL = '"+_cFILIAL+"' "
cQueryD3 += " AND D3_EMISSAO >= '"+DTOS(mv_par05)+"' AND D3_EMISSAO <= '"+DTOS(mv_par06)+"'"
cQueryD3 += " AND D3_ESTORNO <> 'S'"
cQueryD3 += " AND D3_LOCAL = '"+mv_par08+"'"
cQueryD3 += " AND SD3.D_E_L_E_T_=' '"

// cQuery := cQueryD1 + cQueryB1A + " AND " + cQueryB1C + " UNION " + cQueryD2 + cQueryB1A + " AND " + cQueryB1C+" UNION "+cQueryD3+cQueryB1A+" AND "+cQueryB1C
cQuery := cQueryD1P + cQueryD1
cQuery += cQueryB1A
cQuery += " AND "
cQuery += cQueryB1C
cQuery += " UNION "
cQuery += cQueryD2P + cQueryD2
cQuery += cQueryB1A
cQuery += " AND "
cQuery += cQueryB1C
cQuery += " UNION "
cQuery += cQueryD3P + cQueryD3
cQuery += cQueryB1A
cQuery += " AND "
cQuery += cQueryB1C

cQuery += " ORDER BY 2,9"
//			cQuery += " ORDER BY 3, 27, 9,"

//cQuery:=ChangeQuery(cQuery) removido por Thiago
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTOP,.F.,.T.)},'PROCESSANDO')
dbSelectArea(cAliasTop)
Procregua(Reccount())
Dbgotop()
While !Eof()
	
	dbSelectArea("SB2")
	
	If !dbSeek(_cFilial+(cAliasTop)->PRODUTO+mv_par08)
		dbSelectArea(cAliasTop)
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea(cAliasTop)
	cProdAnt  := (cAliasTop)->PRODUTO
	cLocalAnt := SB2->B2_LOCAL
	nEntrada:=nSaida:=0
	nCEntrada:=nCSaida:=0
	lFirst:=.F.
	aSalAtu := CalcEst((cAliasTOP)->PRODUTO,mv_par08,mv_par05)
	
	While !Eof() .And. (cAliasTop)->PRODUTO = cProdAnt
		
		Incproc()
		
		lContinua := .F.
		
		Do Case
			Case Alltrim((cAliasTop)->ARQ) == "SD1" .And. !lContinua
				PROCSD1()
				lDev:=MTR910Dev(cAliasTop)
				If (cAliasTOP)->TES <= "500" .And. !lDev
					nEntrada   += (cAliasTOP)->QUANTIDADE
					aSalAtu[1] += (cAliasTOP)->QUANTIDADE
					nCEntrada  += (cAliasTOP)->CUSTO
					aSalAtu[2] += (cAliasTOP)->CUSTO
					aSalAtu[7] += (cAliasTOP)->QUANT2UM
				Else
					If lDev
						nSaida 	  -= (cAliasTOP)->QUANTIDADE
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						nCSaida	  -=(cAliasTOP)->CUSTO
						aSalAtu[2] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
					Else
						nSaida 	  += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						nCSaida	  +=(cAliasTOP)->CUSTO
						aSalAtu[2] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
					EndIf
				EndIf
			Case Alltrim((cAliasTop)->ARQ) = "SD2" .And. !lContinua
				lDev:=MTR910Dev(cAliasTop)
				If (cAliasTOP)->TES <= "500" .Or. lDev
					If lDev
						nEntrada   -= (cAliasTOP)->QUANTIDADE
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						nCEntrada  -= (cAliasTOP)->CUSTO
						aSalAtu[2] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
					Else
						nEntrada   += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						nCEntrada  += (cAliasTOP)->CUSTO
						aSalAtu[2] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
					EndIf
				Else
					nSaida     += (cAliasTOP)->QUANTIDADE
					aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
					nCSaida	  +=  (cAliasTOP)->CUSTO
					aSalAtu[2] -= (cAliasTOP)->CUSTO
					aSalAtu[7] -= (cAliasTOP)->QUANT2UM
				EndIf
				aSvAlias:={Alias(),IndexOrd(),Recno()}
				ProcSD2()
				dbSelectArea(aSvAlias[1])
				dbSetOrder(aSvAlias[2])
				dbGoto(aSvAlias[3])
			Case Alltrim((cAliasTop)->ARQ) == "SD3" .And. !lContinua
				Procsd3()
				If	lInverteMov
					If (cAliasTOP)->TES > "500"
						nEntrada  += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						nCEntrada  +=  (cAliasTOP)->CUSTO
						aSalAtu[2] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
					Else
						nSaida	  += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						nCSaida	  += (cAliasTOP)->CUSTO
						aSalAtu[2] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
					EndIf
					If lCusUnif
						lPriApropri:=.F.
					EndIf
				Else
					If (cAliasTOP)->TES <= "500"
						nEntrada	  += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						nCEntrada  +=  (cAliasTOP)->CUSTO
						aSalAtu[2] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
					Else
						nSaida	  += (cAliasTOP)->QUANTIDADE
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						nCSaida	  += (cAliasTOP)->CUSTO
						aSalAtu[2] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
					EndIf
				EndIf
		EndCase
		dbSelectArea(cAliasTop)
		dbSkip()
	EndDo
	
EndDo
dbSelectArea(cAliasTop)
dbCloseArea()

dbSelectArea("SB1")
dbClearFilter()
If !Empty(cArq1) .AND. File(cArq1 + OrdBagExt())
	RetIndex('SB1')
	FERASE(cArq1 + OrdBagExt())
EndIf
dbSetOrder(1)
dbSelectArea("SB2")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)
dbSelectArea("SD3")
dbSetOrder(1)
RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTR910Dev³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 25.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se item pertence a uma nota de devolu‡ao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MTR910Dev(cAliasTop)
Static lListaDev := NIL
Local lRet:=.F.

// Identifica se lista dev. na mesma coluna
lListaDev := If(ValType(lListaDev)#"L",GetMV("MV_LISTDEV"),lListaDev)

If lListaDev .And. (cAliasTop)->ARQ == "SD1"
	dbSelectArea("SF1")
	If dbSeek(_cFilial+(cAliasTop)->DOCUMENTO+(cAliasTop)->SERIE+(cAliasTop)->FORNECEDOR+(cAliasTop)->LOJA) .And. (cAliasTop)->TIPONF == "D"
		lRet:=.T.
	EndIf
ElseIf lListaDev .And. (cAliasTop)->ARQ == "SD2"
	dbSelectArea("SF2")
	If dbSeek(_cFilial+(cAliasTop)->DOCUMENTO+(cAliasTop)->SERIE+(cAliasTop)->FORNECEDOR+(cAliasTop)->LOJA) .And. (cAliasTop)->TIPONF == "D"
		lRet:=.T.
	EndIf
EndIf
dbSelectArea(cAliasTop)
Return lRet

Static Function Procsd1()
Dbselectarea("SD1")
Dbgoto((cAliasTop)->NRECNO)
Reclock("SD1",.F.)
SD1->D1_CUSTO4:=SD1->D1_CUSTO
msunlock()
dbSelectArea(cAliasTop)
Return

Static Function Procsd3()
Dbselectarea("SD3")
Dbgoto((cAliasTop)->NRECNO)
Reclock("SD3",.F.)
SD3->D3_CUSTO4:=SD3->D3_CUSTO1
msunlock()
dbSelectArea(cAliasTop)
Return

Static Function Procsd2()
Dbselectarea("SD2")
Dbgoto((cAliasTop)->NRECNO)
cRecno:=Alltrim(str((cAliasTop)->NRECNO))
/* 
 * chamado: 115101
 * comentado por Thiago para sistema alimentar o D2_CUSTO4 com D2_CUSTO1 só se não encontrar 
 * a ultima entrada após a data de emissao do item
if aSalAtu[1] > 0
	Dbselectarea("SD2")
	Reclock("SD2",.F.)
	SD2->D2_XCSTAGR:=SD2->D2_CUSTO1 // SD2->D2_QUANT
	SD2->D2_XSALDNF:=aSalAtu[1]
	SD2->D2_CUSTO4:=SD2->D2_CUSTO1
	msunlock()
Else
*
*/
	cQuer1 := "SELECT D1.R_E_C_N_O_ RECSD1,D1_CUSTO,D1_QUANT,D1_NUMSEQ,D1_DTDIGIT DTDIGSD1 FROM "+RetSqlName("SD1")+"(NOLOCK) D1, "+RetSqlName("SF4")+"(NOLOCK) F4 "
	cQuer1 += " WHERE D1.D_E_L_E_T_ = ' '  AND F4.D_E_L_E_T_ = ' '"
	cQuer1 += " AND D1_TES = F4_CODIGO AND F4_ESTOQUE = 'S' AND D1_TIPO = 'N' "
	cQuer1 += " AND D1_DTDIGIT >= '"+dtos(SD2->D2_EMISSAO)+"'"    //pega a nota de entrada da data encontrada como referencia.
	cQuer1 += " AND D1_COD     = '"+SD2->D2_COD+"'"
	cQuer1 += " AND D1_LOCAL   = '"+SD2->D2_LOCAL+"'"
	cQuer1 += " AND D1_FILIAL  = '"+SD2->D2_FILIAL+"'"
	cQuer1 += " AND F4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuer1 += " ORDER BY D1_DTDIGIT"   //SOMENTE UTILIZARÁ notas apos D2
	//cQuer1 := ChangeQuery(cQuer1)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuer1),"TRBCST",.T.,.T.)
	DbSelectArea("TRBCST")
	Dbgotop()
	IF !EOF()
		Dbselectarea("SD2")
		Reclock("SD2",.F.)
		SD2->D2_XCSTAGR:= (TRBCST->D1_CUSTO / TRBCST->D1_QUANT) * SD2->D2_QUANT
		SD2->D2_XD1SEQC:= ALLTRIM(STR(TRBCST->RECSD1))
		SD2->D2_XSALDNF:=aSalAtu[1]
		SD2->D2_CUSTO4:=(TRBCST->D1_CUSTO / TRBCST->D1_QUANT) * SD2->D2_QUANT
		msunlock()
	Else
		Dbselectarea("SD2")
		Reclock("SD2",.F.)
		SD2->D2_XCSTAGR:=SD2->D2_CUSTO1 // SD2->D2_QUANT
		SD2->D2_XSALDNF:=aSalAtu[1]
		SD2->D2_CUSTO4:=SD2->D2_CUSTO1
		msunlock()
	Endif
	dbSelectArea("TRBCST")
	dbCloseArea()
/*
 * chamado: 115101
 Endif 
 */
dbSelectArea(cAliasTop)
Return
