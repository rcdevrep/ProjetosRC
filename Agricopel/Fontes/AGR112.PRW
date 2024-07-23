#INCLUDE "RWMAKE.CH"

/*
Autor:    Deco
Programa: Gera NF Saida Combustiveis para importacao SCANC
Write:    28/04/04
Alterado: Deco
*/
User Function AGR112()

	Local cPerg := "AGR112"
	Local aRegistros := {}

	Aadd(aRegistros,{cPerg,"01","Emissao de   ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"02","Emissao ate  ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If (Pergunte(cPerg,.T.))
		Processa( {|| GeraArq() } )
	EndIf

Return(Nil)

Static Function GeraArq()

	Local oTmpReg40  := Nil
	Local oTmpAGR112 := Nil
	Local cAliReg40  := ""
	Local cAliAGR112 := ""

	Local NQUANT2
	Local NQTD10
	Local NQTD20
	Local NQTD40
	Local NQTD90
	Local CBAIRRO
	Local ND2QUANT
	Local ND2TOTAL
	Local CPRODUTO
	Local CINSCR
	Local CCEP
	Local CRESTO1
	Local CRESTO2
	Local CRESTO3
	Local ND2BRICMIC
	Local ND2ICMSTIC
	Local CCDSCANC

	cDiretorio := "C:\SCANCCTB\"
	cArq       := cDiretorio + "SAIDA.TXT"
	MakeDir(cDiretorio)

	If File(cArq)
		FErase(cArq)
	EndIf

	//
	// Criacao do arquivo texto informado.
	//
	nHdlArq := MSFcreate(cArq)
	*
	* Gera Registro tipo 10
	*
	cLinha := '10'+','+SM0->M0_CGC+','+'"'+SM0->M0_INSC+'"'+','+'"'+SM0->M0_ESTENT+'"'+','+'"'+SM0->M0_NOMECOM+'"'+','+'""'+','+'""'
	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Selecao de Chaves para os arquivos                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SD2->(DbSetOrder(5))               // filial+emissao+numseq
	SC5->(DbSetOrder(1))               // filial+num
	SA1->(DbSetOrder(1))               // filial+cod+loja
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracoes de arrays                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru:={}
	aadd(aStru,{'CLIENTE','C',06,0})
	aadd(aStru,{'LOJA','C',02,0})

	oTmpAGR112 := FwTemporaryTable():New()
	oTmpAGR112:SetFields(aStru)
	oTmpAGR112:AddIndex("AGR1121", {"CLIENTE","LOJA"})
	oTmpAGR112:Create()

	cAliAGR112 := oTmpAGR112:GetAlias()

	aStru:={}
	aadd(aStru,{'LINHA2','C',122,0})
	aadd(aStru,{'D2QUANT','N',14,2})
	aadd(aStru,{'D2TOTAL','N',14,2})
	aadd(aStru,{'NQUANT','N',14,2})
	aadd(aStru,{'D2BRICMIC','N',14,2})
	aadd(aStru,{'D2ICMSTIC','N',14,2})

	oTmpReg40 := FwTemporaryTable():New()
	oTmpReg40:SetFields(aStru)
	oTmpReg40:AddIndex("REG401", {"LINHA2"})
	oTmpReg40:Create()

	cAliReg40 := oTmpReg40:GetAlias()

	NQTD10 := 1
	NQTD20 := 0
	NQTD40 := 0
	NQTD90 := 4

	*
	* Le arquivo de Nfs para montar temporario para Registro tipo 20
	*
	sele SD2
	dbgotop()
	Procregua(Reccount())
	dbSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.)
	While !eof() .and. SD2->D2_filial == xfilial('SD2') .and.;
	SD2->D2_EMISSAO <= MV_PAR02
		Incproc()
		If SD2->D2_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		If SUBSTR(SD2->D2_CF,1,4) == '6908'  // Ignora Itens de Nf Remessa Comodato
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		If SUBSTR(SD2->D2_CF,1,4) == '5657' .Or.; // Ignora Itens de Nf Remessa Venda Ambulante (Saida e Entrada) cfe Fabi 20/09/2007
		SUBSTR(SD2->D2_CF,1,4) == '1415'
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		If SUBSTR(SD2->D2_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		IF SD2->D2_TP <> 'CO' .AND. SD2->D2_TP <> 'LU'
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF

		cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"SB1->B1_CDSCANC")
		If Empty(cCDSCANC)
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF

		DbSelectArea(cAliAGR112)
		DbGotop()
		If !DbSeek(SD2->D2_CLIENTE+SD2->D2_LOJA)
			(cAliAGR112)->(DbAppend())
			(cAliAGR112)->CLIENTE := SD2->D2_CLIENTE
			(cAliAGR112)->LOJA    := SD2->D2_LOJA
			MSUNLOCK(cAliAGR112)
		Endif
		sele sd2
		dbskip()
	End

	DbSelectArea(cAliAGR112)
	dbgotop()
	Procregua(Reccount())
	While !eof()
		Incproc()
		DbSelectArea("SA1")
		DbGotop()
		DbSeek(xFilial("SA1")+(cAliAGR112)->CLIENTE+(cAliAGR112)->LOJA)
		CINSCR  := SA1->A1_INSCR
		If Empty(SA1->A1_INSCR)
			CINSCR := 'ISENTO'
		Endif
		CBAIRRO := SA1->A1_BAIRRO
		If Empty(SA1->A1_BAIRRO)
			CBAIRRO := 'SEM BAIRRO'
		Endif
		CCEP := SA1->A1_CEP
		If Empty(SA1->A1_CEP)
			CCEP := '0'
		Endif

		cLinha1 := '20'                            +','
		cLinha1 := cLinha1 +     SA1->A1_CGC       +','
		cLinha1 := cLinha1 + '"'+CINSCR        +'"'+','
		cLinha1 := cLinha1 + '"'+'"'               +','
		cLinha1 := cLinha1 + '"'+SA1->A1_NOME  +'"'+','
		cLinha1 := cLinha1 + '"'+SA1->A1_END   +'"'+','
		cLinha1 := cLinha1 + '"'+CBAIRRO       +'"'+','
		cLinha1 := cLinha1 + '"'+SA1->A1_MUN   +'"'+','
		cLinha1 := cLinha1 + '"'+SA1->A1_EST   +'"'+','
		cLinha1 := cLinha1 + '"'+CCEP          +'"'+','
		cLinha1 := cLinha1 + '"'+SA1->A1_EMAIL +'"'+','

		If SA1->A1_TIPO == 'F' .Or.;
		SA1->A1_TIPO == 'L'
			cLinha1 := cLinha1 + '"'+'CNF'      +'"'
		EndIf

		If SA1->A1_TIPO == 'R' .Or.;
		SA1->A1_TIPO == 'S'
			cLinha1 := cLinha1 + '"'+'PRV'      +'"' // Substituido DIS por PRV cfe FAbi 03/10/2007
		EndIf

		fWrite(nHdlArq,cLinha1+chr(13)+chr(10),len(cLinha1)+2)

		NQTD20 := NQTD20 + 1

		DbSelectArea(cAliAGR112)
		dbskip()
	END

	sele SD2
	dbgotop()
	Procregua(Reccount())
	dbSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.)
	While !eof() .and. SD2->D2_filial == xfilial('SD2') .and.;
	SD2->D2_EMISSAO <= MV_PAR02
		Incproc()
		If SD2->D2_TIPO == 'C'  // Nota Fiscal Complementar nao Considera cfe Ademir 03/11/2006
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		If SUBSTR(SD2->D2_CF,1,4) == '6908'  // Ignora Itens de Nf Remessa Comodato
			dbSKIP()
			LOOP
		ENDIF
		If SUBSTR(SD2->D2_CF,1,4) == '1949'  // Ignora Itens de Nf entrada antes da nf da Petrobras cfe Ademir 03/11/2006
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		IF SD2->D2_TP <> 'CO' .AND. SD2->D2_TP <> 'LU'
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		cCDSCANC :=	Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"SB1->B1_CDSCANC")
		If Empty(cCDSCANC)
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF
		CPRODUTO := cCDSCANC

		If Empty(CPRODUTO)
			SELE SD2
			dbSKIP()
			LOOP
		ENDIF

		nD2Quant := SD2->D2_QUANT
		If Alltrim(SD2->D2_COD) == '00030157'
			nD2Quant := SD2->D2_QUANT * 5
		Endif
		If Alltrim(SD2->D2_COD) == '00030190'
			nD2Quant := SD2->D2_QUANT * 1
		Endif
		If Alltrim(SD2->D2_COD) == '00050254'
			nD2Quant := SD2->D2_QUANT * 1
		Endif
		If Alltrim(SD2->D2_COD) == '00060040'
			nD2Quant := SD2->D2_QUANT * 12
		Endif
		If Alltrim(SD2->D2_COD) == '00060041'
			nD2Quant := SD2->D2_QUANT * 20
		Endif
		If Alltrim(SD2->D2_COD) == '00060042'
			nD2Quant := SD2->D2_QUANT * 20
		Endif
		If Alltrim(SD2->D2_COD) == '00060087'
			nD2Quant := SD2->D2_QUANT * 200
		Endif
		If Alltrim(SD2->D2_COD) == '03278'
			nD2Quant := SD2->D2_QUANT * 1
		Endif

		NQUANT2  := 0

		IF Alltrim(SD2->D2_COD) == '00006' .OR.;
		Alltrim(SD2->D2_COD) == '00005' .OR.;
		Alltrim(SD2->D2_COD) == '00014' .OR.;
		Alltrim(SD2->D2_COD) == '00032' .OR.;
		Alltrim(SD2->D2_COD) == '00034' .OR.;
		(Alltrim(SD2->D2_COD) == '00024' .And. SM0->M0_CODIGO == '02') // Mime Distrib eh gasolina

			If SD2->D2_EMISSAO <= CTOD('19/11/06')
				NQUANT2 := (nD2QUANT * 0.80)  // Colocado em 80% no calculo cfe Fabi 14/03/2006
			Endif

			If SD2->D2_EMISSAO >= CTOD('20/11/06')
				NQUANT2 := (nD2QUANT * 0.75)  // Colocado em 75% no calculo cfe Fabi 02/08/2007
			Endif
		ENDIF

		DbSelectArea("SA1")
		DbGotop()
		DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
		CINSCR  := SA1->A1_INSCR
		If Empty(SA1->A1_INSCR)
			CINSCR := 'ISENTO'
		Endif

		cLinha2 := '40'                            +','
		cLinha2 := cLinha2 +  StrZero(Month(SD2->D2_EMISSAO),2)+Strzero(year(SD2->D2_EMISSAO),4)     +','
		cLinha2 := cLinha2 +     SA1->A1_CGC        +','
		cLinha2 := cLinha2 + '"'+CINSCR        +'"' +','
		cLinha2 := cLinha2 + '"'+SA1->A1_EST   +'"' +','
		cLinha2 := cLinha2 +  Strzero(year(SD2->D2_EMISSAO),4)+StrZero(Month(SD2->D2_EMISSAO),2)+StrZero(Day(SD2->D2_EMISSAO),2)     +','
		cLinha2 := cLinha2 + '0'                    +','
		cLinha2 := cLinha2 + '"'+SD2->D2_SERIE +'"' +','
		cLinha2 := cLinha2 +     Padr(SD2->D2_DOC,9)+','
		cLinha2 := cLinha2 + SUBSTR(SD2->D2_CF,1,4) +','

		DbSelectArea("SC5")
		DbGotop()
		If DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			If SC5->C5_TPFRETE == 'C'
				cLinha2 := cLinha2 + '1'                 +','
			ElseIf SC5->C5_TPFRETE == 'F'
				cLinha2 := cLinha2 + '2'                 +','
			Else
				cLinha2 := cLinha2 + '1'                 +','
			EndIf
		Else
			cLinha2 := cLinha2 + '1'                 +','
		Endif
		cLinha2 := cLinha2 +     SM0->M0_CGC        +','
		cLinha2 := cLinha2 + '"'+SM0->M0_ESTENT +'"'+','
		cLinha2 := cLinha2 + '"'+'"'                +','
		cLinha2 := cLinha2 + '"'+'"'                +','
		cLinha2 := cLinha2 + '"'+'"'                +','
		cLinha2 := cLinha2 + '"'+CPRODUTO+'"'       +','

		If len(alltrim(cLinha2)) <> 122
			MsgStop('Linha 40 do Arquivo com chave menor que 122 Posiçoes !!')
		EndIf

		DbSelectArea(cAliReg40)
		DbGotop()
		If !DbSeek(cLinha2)
			(cAliReg40)->(dbappend())
			(cAliReg40)->LINHA2  := cLinha2
			(cAliReg40)->D2QUANT := ND2QUANT
			(cAliReg40)->D2TOTAL := SD2->D2_TOTAL
			(cAliReg40)->NQUANT  := NQUANT2
			(cAliReg40)->D2BRICMIC := SD2->D2_BRICMIC
			(cAliReg40)->D2ICMSTIC := SD2->D2_ICMSTIC
			MSUNLOCK(cAliReg40)
		Else
			RecLock((cAliReg40),.F.)
			(cAliReg40)->D2QUANT   := (cAliReg40)->D2QUANT + ND2QUANT
			(cAliReg40)->D2TOTAL   := (cAliReg40)->D2TOTAL + SD2->D2_TOTAL
			(cAliReg40)->NQUANT    := (cAliReg40)->NQUANT  + NQUANT2
			(cAliReg40)->D2BRICMIC := (cAliReg40)->D2BRICMIC + SD2->D2_BRICMIC
			(cAliReg40)->D2ICMSTIC := (cAliReg40)->D2ICMSTIC + SD2->D2_ICMSTIC
			MSUNLOCK(cAliReg40)
		Endif

		sele sd2
		dbskip()
	End

	DbSelectArea(cAliReg40)
	dbgotop()
	Procregua(Reccount())
	While !eof()

		Incproc()

		cLinha2  := (cAliReg40)->LINHA2
		nD2QUANT := (cAliReg40)->D2QUANT
		nD2TOTAL := (cAliReg40)->D2TOTAL
		NQUANT2  := (cAliReg40)->NQUANT
		nD2BRICMIC := (cAliReg40)->D2BRICMIC
		nD2ICMSTIC := (cAliReg40)->D2ICMSTIC

		CRESTO1 := (nD2QUANT - Int(nD2QUANT)) * 1000
		CRESTO2 := (nD2TOTAL - Int(nD2TOTAL)) * 100
		CRESTO3 := (NQUANT2 - Int(NQUANT2)) * 1000
		cLinha2 := cLinha2 + Alltrim(STR(INT(nD2QUANT)))+'.'+STRZERO(CRESTO1,3) +','
		cLinha2 := cLinha2 + Alltrim(STR(INT(nD2TOTAL)))+'.'+STRZERO(CRESTO2,2) +','
		cLinha2 := cLinha2 + Alltrim(STR(INT(NQUANT2)))+'.' +STRZERO(CRESTO3,3)       +','

		If nD2BRICMIC == 0
			cLinha2 := cLinha2 +     '0'                +','
			cLinha2 := cLinha2 +     '0'                +','
			cLinha2 := cLinha2 +     '0'
		Else
			CRESTO1 := ((nD2BRICMIC) - Int(nD2BRICMIC)) * 100
			CRESTO2 := ((nD2ICMSTIC) - Int(nD2ICMSTIC)) * 100
			cLinha2 := cLinha2 +     '1'                +','
			cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2BRICMIC)))+'.'+STRZERO(CRESTO1,2) +','
			cLinha2 := cLinha2 +     Alltrim(STR(INT(nD2ICMSTIC)))+'.'+STRZERO(CRESTO2,2)
		EndIf
		fWrite(nHdlArq,cLinha2+chr(13)+chr(10),len(cLinha2)+2)

		NQTD40 := NQTD40 + 1

		DbSelectArea(cAliReg40)
		dbskip()
	End

	cLinha := '90'+','+SM0->M0_CGC+','+'10'+','+STRZERO(NQTD10,6)+','+STRZERO(NQTD10,6)
	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	cLinha := '90'+','+SM0->M0_CGC+','+'20'+','+STRZERO(NQTD20,6)+','+STRZERO(NQTD10,6)
	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	cLinha := '90'+','+SM0->M0_CGC+','+'40'+','+STRZERO(NQTD40,6)+','+STRZERO(NQTD10,6)
	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	cLinha := '90'+','+SM0->M0_CGC+','+'99'+','+STRZERO((NQTD90+NQTD10+NQTD20+NQTD40),6)+','+STRZERO(NQTD10,6)
	fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)

	FClose(nHdlArq)

	sele SA1
	dbsetorder(1) ; dbgotop()
	sele Sd2
	dbsetorder(1) ; dbgotop()
	sele Sc5
	dbsetorder(1) ; dbgotop()

	(cAliReg40)->(DbCloseArea())
	(cAliAGR112)->(DbCloseArea())

	oTmpAGR112:Delete()
	oTmpReg40:Delete()

Return()