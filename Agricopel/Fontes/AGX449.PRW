#Include 'FIVEWIN.CH'
#Include 'DLGR230.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AGX449 ³ Autor ³ Leandro F. Silveira     ³Data  ³14/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reabastecimento                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function AGX449(cPedidos)

Local Titulo     := "Materiais para Reabastecimento"
Local cDesc1     := "Emite relatório"
Local cDesc2     := "de Reabastecimento"
Local cDesc3     := ""
Local cString    := "SDB"
Local lDic       := .F.
Local lComp      := .F.
Local lFiltro    := .T.
Local WnRel      := "AGX449"
Local nomeprog   := "AGX449"
Private Tamanho  := "G"
Private Limite   := 180
Private cPerg    := "AGX449"
Private aReturn  := {STR0001, 1,STR0002, 1, 2, 1, "",1 }
Private lEnd     := .F.
Private m_pag    := 1
Private nLastKey := 0

if AllTrim(cPedidos) == ""
	CriarPerg()
EndIf

WnRel := SetPrint(cString, WnRel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, lDic,, lComp, Tamanho, lFiltro)

If (nLastKey==27)
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return Nil
Endif

SetDefault(aReturn,cString)

If (nLastKey==27)
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return Nil
Endif

RptStatus({|lEnd| ImpDet(@lEnd, WnRel, cString, nomeprog, Titulo, cPedidos)}, Titulo)

Return Nil

Static Function ImpDet(lEnd, WnRel, cString, nomeprog, Titulo, cPedidos)

Local nx         := 0
Local li     	 := 80
Local lImp    	 := .F.
Local cbCont  	 := 0
Local cbText  	 := ''
Local CHRCOMP 	 := 15
Local nSomaVol   := 0
Local cCodCFG    := ''
Local cPicCFG    := ''
Local cCodCFG1   := ''
Local cPicCFG1	 := ''
Local lTipo      := .F.
Local nTam       := TamSx3("DB_DOC")[1]
Local cCabec1 	 := ''
Local cCabec2 	 := ''
Local cArq       := ''
Local cChave     := ''
Local cCondicao  := ''
Local cValoWhile := ''
Local cProduto   := ''
Local cNumSeq    := ''
Local nRegistro  := 0
Local nQtdpLinha := 24
Local nIndSDB    := 0
Local cLocaliz   := ''
Local lIni	     := .T.
Local nUMI       := 0
Local n1UM       := 0
Local n2UM       := 0
Local aImpDet    := {}
Local RecNoSBF   := 0

Private nOrdTot  := 0
Private nOrdAtu  := 0

SB1->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SBE->(dbSetOrder(1))
DC8->(dbSetOrder(1))

cCabec2 := 'Endereco Origem      Estru. Endereco Destino      Carga      Unitiz. Lote    Cod.Produto      UN Produto                                                               Quantidade     Qtde Origem   RecNoSaldo '

dbSelectArea(cString)
cArq := CriaTrab("", .F.)

If AllTrim(cPedidos) <> ""
	cCondicao += cPedidos
Else
	cCondicao += '       DB_TAREFA >= "'     + MV_PAR03       + '" .And. DB_TAREFA <= "' + MV_PAR04 + '"'
	cCondicao += ' .And. DB_ATIVID >= "'     + MV_PAR05       + '" .And. DB_ATIVID <= "' + MV_PAR06 + '"' 
	cCondicao += ' .And. DB_DOC    >= "'     + MV_PAR07       + '" .And. DB_DOC    <= "' + MV_PAR08 + '"'
	cCondicao += ' .And. DB_SERIE  >= "'     + MV_PAR09       + '" .And. DB_SERIE  <= "' + MV_PAR10 + '"'
EndIf

cCondicao += ' .And. DtoS(DB_DATA) >= "' + DtoS(MV_PAR11) + '"'
cCondicao += ' .And. DtoS(DB_DATA) <= "' + DtoS(MV_PAR12) + '"'

cCondicao += ' .And. DB_SERVIC = "016" '
cCondicao += ' .And. Empty(DB_ESTORNO) .And. DB_ATUEST == "N"'

cChave	 := 'DB_FILIAL+DB_ESTFIS+DB_LOCALIZ+DB_DOC+DB_SERIE+DB_PRODUTO+DB_LOCAL'

IndRegua(cString, cArq, cChave,, cCondicao, STR0004) //'Selecionando Registros...'

nIndSDB := RetIndex('SDB')
#IFNDEF TOP
	dbSetIndex(cArq+OrdBagExt())
#ENDIF
dbSetOrder(nIndSDB+1)

dbSelectArea('SDB')
SetRegua(LastRec())
dbGoTop()
Do While !Eof()

	cQuery := "" 
	cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SDB")
	cQuery += " WHERE DB_DOC = '" + SDB->DB_DOC + "'"
	cQuery += "   AND DB_FILIAL = '" + xFilial("SDB") + "'"
	cQuery += "   AND DB_ESTORNO = 'S' "
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	
	if select("MSDB") <> 0
		Dbselectarea("MSDB")
		dbCloseArea()
	endif
	
	DbUseArea( .T., "TOPCONN", TCGenQry( Nil, Nil, cQuery ), "MSDB", .T., .F. )
	
	cExiste := "N" 
	dbSelectArea("MSDB")
	dbgotop()
	Do While !Eof()   
		cExiste := "S"   
		MSDB->(dbskip())
	EndDo                             
   
	DbSelectArea("SDB")
	
	If cExiste =="N"		  
	
		nRegistro  := Recno()
		nOrdAtu    := 0
		lVerfOrd   := If(cValoWhile#SDB->DB_ESTFIS,.T.,.F.)
		nOrdTot    := If(cValoWhile#SDB->DB_ESTFIS,0,nOrdTot)
		cValoWhile := SDB->DB_ESTFIS
		
		Do While !Eof() .And. (cValoWhile==SDB->DB_ESTFIS) .And. lVerfOrd
			nOrdAtu++
			dbSkip()
		Enddo

		nOrdTot := nOrdAtu / nQtdpLinha
		nOrdTot := Int(nOrdTot)+If(nOrdTot==Int(nOrdTot),0,1)
		nOrdAtu := 0
		DbGoto(nRegistro)

		lVerfOrd := .F.
		
		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf

		//-- Posiciona Arquivos
		cProduto := SDB->DB_PRODUTO
		cNumSeq  := SDB->DB_NUMSEQ
		SB1->(MsSeek(xFilial('SB1')+cProduto))
		SB5->(MsSeek(xFilial('SB5')+cProduto))
		DC8->(MsSeek(xFilial('DC8')+SDB->DB_ESTFIS))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Le picture do endereco Origem                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SBE->(MsSeek(xFilial('SBE')+SDB->DB_LOCAL+SDB->DB_LOCALIZ, .F.))
			If !(cCodCFG==SBE->BE_CODCFG) //-- Verifica se o codigo mudou
				cCodCFG := SBE->BE_CODCFG
				cPicCFG := DLXPicEnd(SBE->BE_CODCFG)
			EndIf
		EndIf

		If Li > 55 .Or. !(cLocaliz==SDB->DB_ESTFIS)
		
			If !(cLocaliz==SDB->DB_ESTFIS) .And. !lIni
				Li++
				@ Li,000 PSAY __PrtFatLine()
			Endif

			nOrdAtu++
			cCabec1 := "Estrutura: " + SDB->DB_ESTFIS + '-' + DC8->DC8_DESEST

			cCabec1 += PadL("Ordem: " + StrZero(nOrdAtu,3)+'/'+StrZero(nOrdTot,3),132-Len(cCabec1))

			Li := Cabec(Titulo, cCabec1, cCabec2, nomeprog, Tamanho, CHRCOMP)

			lIni := .F.
		Endif

		cLocaliz := SDB->DB_ESTFIS
		Li++

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Le picture do endereco Destino                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SBE->(MsSeek(xFilial('SBE')+SDB->DB_LOCAL+SDB->DB_ENDDES, .F.))
			If !(cCodCFG1==SBE->BE_CODCFG) //-- Verifica se o codigo mudou
				cCodCFG1 := SBE->BE_CODCFG
				cPicCFG1 := DLXPicEnd(SBE->BE_CODCFG)
			EndIf
		EndIf

		DbSelectArea("SBF")
		DbGoTop()
		DbSetOrder(1)

		if DbSeek(xFilial("SBF")+SDB->DB_LOCAL+SDB->DB_LOCALIZ+cProduto)
			nQtdeOrigem := SBF->BF_QUANT
			RecNoSBF    := SBF->(RecNo())
		Else
			nQtdeOrigem := 0
			RecNoSBF    := 0
		Endif

		@ Li, 000 PSay SDB->DB_LOCALIZ Picture cPicCFG
		@ Li, 021 PSay SDB->DB_ESTDES
		@ Li, 028 PSay SDB->DB_ENDDES Picture cPicCFG1
		@ Li, 050 PSay AllTrim(SDB->DB_DOC)
		@ Li, 061 Psay SDB->DB_LOTECTL
		@ Li, 077 PSay cProduto
		@ Li, 094 PSay SB1->B1_UM
		@ Li, 097 PSay AllTrim(SB1->B1_DESC)
		@ Li, 165 PSay SDB->DB_QUANT Picture '@E 9,999,999.99'
		@ Li, 181 PSay nQtdeOrigem   Picture '@E 9,999,999.99'
		@ Li, 196 PSay AllTrim(Str(RecNoSBF))

		Li+=2
		@ Li,000 PSay "Separador: "  + ' _______________________   ___:___   ___:___'
		@ Li,075 PSay "Conferente: " + ' _______________________   ___:___   ___:___'
		Li++

		@ Li,000 PSAY __PrtThinLine()
		lImp := .T.
	EndIf

	DbSelectArea("SDB")
	SDB->(DbSkip())
	IncRegua()
EndDo

RetIndex(cString)
FErase(cArq+OrdBagExt())

If (lImp)
	Li++
	@ Li,000 PSAY __PrtFatLine()
	Roda(cbCont,cbText,Tamanho)
EndIf

Set Device To Screen
Set Printer To
If (aReturn[5]==1)
	dbCommitAll()
	OurSpool(WnRel)
Endif
MS_FLUSH()

Return Nil

Static Function CriarPerg()

	cPerg := "AGX436"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Servico De        ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"02","Servico Ate       ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","L4"})
	AADD(aRegistros,{cPerg,"03","Tarefa De         ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"04","Tarefa Ate        ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","L2"})
	AADD(aRegistros,{cPerg,"05","Atividade De      ?","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"06","Atividade Ate     ?","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","L3"})
	AADD(aRegistros,{cPerg,"07","Documento De      ?","mv_ch7","C",TamSX3("DB_DOC")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Documento Ate     ?","mv_ch8","C",TamSX3("DB_DOC")[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Serie De          ?","mv_ch9","C",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Serie Ate         ?","mv_chA","C",03,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Data De           ?","mv_chB","D",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Data Ate          ?","mv_chC","D",08,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Quantidade        ?","mv_chD","N",01,0,0,"C","","mv_par13","1a.UM","","","2a.UM","","","U.M.I.","","","Não Imprime","","","","",""})
	AADD(aRegistros,{cPerg,"14","Tipo de Documento ?","mv_chE","N",01,0,0,"C","","mv_par14","Doc/Ser WMS","","","oc/Ser Ori. CQ","","","Carga/Unitiz.","","","","","","","",""})
	AADD(aRegistros,{cPerg,"15","Mostrar Impressos ?","mv_chF","N",01,0,0,"C","","mv_par15","Sim","","","Não","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"16","Executor Serviço  ?","mv_chG","C",04,0,0,"G","","mv_par16","","","","","","","","","","","","","","","ZZA"})
	AADD(aRegistros,{cPerg,"17","Armazem           ?","mv_chH","C",02,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg, .F.)

Return()