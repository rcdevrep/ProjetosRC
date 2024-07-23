#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

User Function GeraTKE()

Private cPerg := "GERTKE"
Private cDir := "C:\SPED_TKE\" + space(100)

aRegistros := {}
AADD(aRegistros,{cPerg,"01","Filial de  ?","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Filial ate ?","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Data de    ?","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Data ate   ?","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Carga de dados Cadastrais - Microsiga x TKE") FROM 000,000 TO 20,66 OF oMainWnd
@ 0.5,001 TO 10,32
@ 1.5,002 SAY OemToAnsi("Este programa tem por objetivo realizar a exportação dos dados necessários ") COLOR CLR_BLUE  SIZE 265,8
@ 2.5,002 SAY OemToAnsi("para o TKE gerar o arquivo SPED Fiscal.                                    ") COLOR CLR_BLUE  SIZE 265,8

@ 4.5,002 SAY OemToAnsi("Informe o diretório: ") COLOR CLR_BLUE  SIZE 265,8
@ 4.5,002 GET cDir SIZE 200,10

DEFINE SBUTTON oPar FROM 110,150 TYPE 5 ACTION (Pergunte(cPerg,.T.)) ENABLE OF oDlg
DEFINE SBUTTON oCon FROM 110,180 TYPE 1 ACTION (Processa({|| ExportaDados()}),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON oCan FROM 110,210 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function ExportaDados()

If !File(cDir)
	MakeDir(cDir)
EndIf

Processa({|| fProdutos()}, "PRODUTOS")
Processa({|| fFornecedores()}, "FORNECEDORES")
Processa({|| fNotas()}, "NOTAS FISCAIS")
Processa({|| fConhecimento()}, "CONHECIMENTO FRETE")
ApMsgInfo("Dados gerados com sucesso na pasta " + ALLTRIM(cDir) + " !!")

Return

//================================================ PRODUTOS ================================================

Static Function fProdutos()

nHandle := 0
nTam := 0

cArquivo := "0200_PRODUTOS.TXT"

If !File(ALLTRIM(cDir)+cArquivo)
	nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Else
	fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Endif

cQuery := ""
cQuery += "SELECT B1_COD, B1_DESC, B1_UM "
cQuery += "FROM " + RETSQLNAME("SB1") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND (SUBSTRING(B1_COD,1,3) = 'DES' OR B1_COD IN('9933','ATI0010','ATI0006','ATI0008')) "

If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"

dbSelectArea("QRY")
ProcRegua(500)
dbGoTop()
While !Eof()

	IncProc("Aguarde...")

	cLinha := ALLTRIM(QRY->B1_COD)+";"+ALLTRIM(QRY->B1_DESC)+";"+ALLTRIM(QRY->B1_UM)
	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))

	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo

fClose(nHandle)

Return


//================================================ FORNECEDORES ================================================

Static Function fFornecedores()

nHandle := 0
nTam := 0

cArquivo := "0150_FORNECEDORES.TXT"

If !File(ALLTRIM(cDir)+cArquivo)
	nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Else
	fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Endif

cQuery := ""
cQuery += "SELECT A2_COD, A2_NOME, A2_CGC, A2_TIPO, A2_INSCR, A2_END, A2_BAIRRO, A2_COD_MUN, A2_EST "
cQuery += "FROM " + RETSQLNAME("SA2") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND A2_COD+A2_LOJA IN (SELECT DISTINCT D1_FORNECE+D1_LOJA  "
cQuery += "						FROM " + RETSQLNAME("SD1") + " "
cQuery += "						WHERE D_E_L_E_T_ <> '*' "
cQuery += " 					AND (SUBSTRING(D1_COD,1,3) = 'DES' OR  D1_CF IN('2353','1353','2916','2551','1551','1933','2933','1949','2949','1556', '2353', '1303'))  " 
cQuery += "						AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "') "

If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"

dbSelectArea("QRY")
ProcRegua(500)
dbGoTop()
While !Eof()

	IncProc("Aguarde...")

	cLinha := ALLTRIM(QRY->A2_COD) + ";" + ALLTRIM(QRY->A2_NOME) + ";" + ALLTRIM(QRY->A2_CGC) + ";" + ALLTRIM(QRY->A2_TIPO) + ";" + ALLTRIM(QRY->A2_INSCR) + ";" + ALLTRIM(QRY->A2_END) + ";" + ALLTRIM(QRY->A2_BAIRRO) + ";" + ALLTRIM(QRY->A2_COD_MUN) + ";" + ALLTRIM(QRY->A2_EST) + ";"
	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))

	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo

fClose(nHandle)

Return

//================================================ NOTAS FISCAIS ================================================

Static Function fNotas()

nHandle := 0
nTam := 0

cArquivo := "C100_NOTAS_FISCAIS.TXT"

If !File(ALLTRIM(cDir)+cArquivo)
	nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Else
	fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Endif

cQuery := ""
cQuery += "SELECT	F1_FILIAL, '0' AS IND_OPER , '0' AS IND_EMIT ,F1_FORNECE, F1_LOJA, '01' AS COD_MOD, '00' AS COD_SIT, F1_SERIE, F1_DOC, F1_CHVNFE, F1_EMISSAO, F1_DTDIGIT, F1_VALBRUT, "
cQuery += "		(CASE F1_COND WHEN '001' THEN '0' ELSE '1' END) AS IND_PGTO, F1_DESCONT, 0 AS VL_ABAT_NT, F1_VALMERC, '9' AS IND_FRETE, "
cQuery += "		0 AS VL_FRT, F1_SEGURO, F1_DESPESA, F1_BASEICM, F1_VALICM, F1_BRICMS, F1_ICMSRET, F1_VALIPI, F1_VALPIS, "
cQuery += "		F1_VALCOFI, 0 AS VL_PIS_ST, 0 AS VL_COFINS_ST "
cQuery += "FROM " + RETSQLNAME("SF1") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA IN ( "
cQuery += "													SELECT DISTINCT D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA "
cQuery += "													FROM " + RETSQLNAME("SD1") + " "
cQuery += "													WHERE D_E_L_E_T_ <> '*' "
cQuery += "													AND D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "													AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cQuery += "													AND (SUBSTRING(D1_COD,1,3) = 'DES'  OR D1_CF IN('2353','1353','2916','2551','1551','1933','2933','1949','2949','1556', '2353', '1303'))"
cQuery += "													) "
cQuery += "ORDER BY F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA "

If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"
TCSetField("QRY","F1_VALBRUT","N",15,3)
TCSetField("QRY","F1_DESCONT","N",15,3)
TCSetField("QRY","VL_ABAT_NT","N",15,3)
TCSetField("QRY","F1_VALMERC","N",15,3)
TCSetField("QRY","VL_FRT","N",15,3)
TCSetField("QRY","F1_SEGURO","N",15,3)
TCSetField("QRY","F1_DESPESA","N",15,3)
TCSetField("QRY","F1_BASEICM","N",15,3)
TCSetField("QRY","F1_VALICM","N",15,3)
TCSetField("QRY","F1_BRICMS","N",15,3)
TCSetField("QRY","F1_ICMSRET","N",15,3)
TCSetField("QRY","F1_VALIPI","N",15,3)
TCSetField("QRY","F1_VALPIS","N",15,3)
TCSetField("QRY","F1_VALCOFI","N",15,3)
TCSetField("QRY","VL_PIS_ST","N",15,3)
TCSetField("QRY","VL_COFINS_ST","N",15,3)


aCli := {}
Aadd(aCli,{"FILIAL"		,"C",02,0})
Aadd(aCli,{"PREFIXO"	,"C",03,0})
Aadd(aCli,{"NUM"	    ,"C",06,0})
Aadd(aCli,{"FORNECE" 	,"C",06,0})
Aadd(aCli,{"PARCELA"	,"C",01,0})
Aadd(aCli,{"VENCTO"		,"C",08,0})
Aadd(aCli,{"VALOR"		,"N",15,3})

If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif

cArqCli := CriaTrab(aCli,.T.)
dbUseArea(.T.,,cArqCli,"TRB",.T.,.F.)
Indregua("TRB",cArqCli,"VENCTO",,,OemToAnsi("Selecionando Ordem..."))

nCount := 0

dbSelectArea("QRY")
dbGoTop()
While !Eof()

	nCount++
	
	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo

aItens := {}

dbSelectArea("QRY")
ProcRegua(nCount)
dbGoTop()
While !Eof()

	IncProc("Aguarde...")
	
	cFilNova := ""
	
	// Se for Posto Rosario setar a filial como 50, pois eh como esta cadastrada dentro do tke.
	If cEmpAnt == "21"
		cFilNova := "50"
	else
		cFilNova := QRY->F1_FILIAL
	EndIf

	cLinha := ALLTRIM(cFilNova)+";"+ALLTRIM(QRY->IND_OPER)+";"+ALLTRIM(QRY->IND_EMIT)+";"+ALLTRIM(QRY->F1_FORNECE)+";"+ALLTRIM(QRY->COD_MOD)+";"+ALLTRIM(QRY->COD_SIT)+";"+ALLTRIM(QRY->F1_SERIE)+";"+ALLTRIM(QRY->F1_DOC)+";"+ALLTRIM(QRY->F1_CHVNFE)+";"+ALLTRIM(QRY->F1_EMISSAO)+";"+ALLTRIM(QRY->F1_DTDIGIT)+";"+ALLTRIM(STR(QRY->F1_VALBRUT))+";"
	cLinha += ALLTRIM(QRY->IND_PGTO)+";"+ALLTRIM(STR(QRY->F1_DESCONT))+";"+ALLTRIM(STR(QRY->VL_ABAT_NT))+";"+ALLTRIM(STR(QRY->F1_VALMERC))+";"+ALLTRIM(QRY->IND_FRETE)+";"
	cLinha += ALLTRIM(STR(QRY->VL_FRT))+";"+ALLTRIM(STR(QRY->F1_SEGURO))+";"+ALLTRIM(STR(QRY->F1_DESPESA))+";"+ALLTRIM(STR(QRY->F1_BASEICM))+";"+ALLTRIM(STR(QRY->F1_VALICM))+";"+ALLTRIM(STR(QRY->F1_BRICMS))+";"+ALLTRIM(STR(QRY->F1_ICMSRET))+";"+ALLTRIM(STR(QRY->F1_VALIPI))+";"+ALLTRIM(STR(QRY->F1_VALPIS))+";"
	cLinha += ALLTRIM(STR(QRY->F1_VALCOFI))+";"+ALLTRIM(STR(QRY->VL_PIS_ST))+";"+ALLTRIM(STR(QRY->VL_COFINS_ST))

	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))

//================================================ ITENS NOTA FISCAL ================================================

	cQuery := ""
	cQuery += "SELECT D1_FILIAL, RIGHT(D1_ITEM,3) AS ITEM, D1_COD, '' AS DESCR_COMPL, D1_QUANT, D1_UM, D1_TOTAL, "
	cQuery += "			D1_VALDESC, (CASE D1_TIPO WHEN 'N' THEN '0' ELSE '1' END) IND_MOV, '' AS CST_ICMS, D1_CF, D1_CF AS COD_NAT, "
	cQuery += "			D1_BASEICM, D1_PICM, D1_VALICM, 0 AS VL_BC_ICMS_ST, 0 AS ALIQ_ST, 0 AS VL_ICMS_ST, '0' AS IND_APUR, "
	cQuery += "			'' AS CST_IPI, '' AS COD_ENQ, D1_BASEIPI, D1_IPI, D1_VALIPI, '' AS CST_PIS, 0 AS VL_BC_PIS, 0 AS ALIQ_PIS_P, "
	cQuery += "			0 AS QUANT_BC_PIS, 0 AS ALIQ_PIS_R, 0 AS VL_PIS, '' AS CST_COFINS, 0 AS VL_BC_COFINS, 0 AS ALIQ_COFINS_P, 0 AS QUANT_BC_COFINS,  "
	cQuery += "			0 AS ALIQ_COFINS_R, 0 AS VL_COFINS, D1_ITEMCTA "
	cQuery += "FROM " + RETSQLNAME("SD1") + " "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND D1_FILIAL = '" + QRY->F1_FILIAL + "' "
	cQuery += "AND D1_DOC = '" + QRY->F1_DOC + "' "
	cQuery += "AND D1_SERIE = '" + QRY->F1_SERIE + "' "
	cQuery += "AND D1_FORNECE = '" + QRY->F1_FORNECE + "' "
	cQuery += "AND D1_LOJA = '" + QRY->F1_LOJA + "' "

	cQuery += "ORDER BY D1_FILIAL+D1_DOC+D1_SERIE+RIGHT(D1_ITEM,3)+D1_FORNECE+D1_LOJA "

	If (Select("MSD1") <> 0)
		dbSelectArea("MSD1")
		dbCloseArea()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "MSD1"
	TCSetField("MSD1","D1_QUANT","N",15,3)
	TCSetField("MSD1","D1_TOTAL","N",15,3)
	TCSetField("MSD1","D1_VALDESC","N",15,3)
	TCSetField("MSD1","D1_BASEICM","N",15,3)
	TCSetField("MSD1","D1_PICM","N",15,3)
	TCSetField("MSD1","D1_VALICM","N",15,3)
	TCSetField("MSD1","VL_BC_ICMS_ST","N",15,3)
	TCSetField("MSD1","ALIQ_ST","N",15,3)
	TCSetField("MSD1","VL_ICMS_ST","N",15,3)
	TCSetField("MSD1","D1_BASEIPI","N",15,3)
	TCSetField("MSD1","D1_IPI","N",15,3)
	TCSetField("MSD1","D1_VALIPI","N",15,3)
	TCSetField("MSD1","VL_BC_PIS","N",15,3)
	TCSetField("MSD1","ALIQ_PIS_P","N",15,3)
	TCSetField("MSD1","QUANT_BC_PIS","N",15,3)
	TCSetField("MSD1","ALIQ_PIS_R","N",15,3)
	TCSetField("MSD1","VL_PIS","N",15,3)
	TCSetField("MSD1","VL_BC_COFINS","N",15,3)
	TCSetField("MSD1","ALIQ_COFINS_P","N",15,3)
	TCSetField("MSD1","QUANT_BC_COFINS","N",15,3)
	TCSetField("MSD1","ALIQ_COFINS_R","N",15,3)
	TCSetField("MSD1","VL_COFINS","N",15,3)

	
	dbSelectArea("MSD1")
	dbGoTop()
	While !Eof()
	   
		cDescrCF := POSICIONE("SX5",1,XFILIAL("SX5")+"13"+MSD1->D1_CF,"X5_DESCRI")
		cCSTICM  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+MSD1->D1_COD,"B1_ORIGEM"))+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+MSD1->D1_COD,"B1_CLASFIS"))
		
		//Se empresa for Posto Rosario setar filial como 50
		cFilNova := ""
		If cEmpAnt == "21"
			cFilNova := "50"
		Else
			cFilNova := MSD1->D1_FILIAL
		EndIf
		
		AADD(aItens,{	QRY->F1_DOC, QRY->F1_SERIE, QRY->F1_FORNECE, cFilNova, MSD1->ITEM, MSD1->D1_COD, MSD1->DESCR_COMPL, STR(MSD1->D1_QUANT), MSD1->D1_UM, STR(MSD1->D1_TOTAL),;
							STR(MSD1->D1_VALDESC), MSD1->IND_MOV, cCSTICM, MSD1->D1_CF, MSD1->COD_NAT,;
							STR(MSD1->D1_BASEICM), STR(MSD1->D1_PICM), STR(MSD1->D1_VALICM), STR(VL_BC_ICMS_ST), STR(MSD1->ALIQ_ST), STR(MSD1->VL_ICMS_ST), MSD1->IND_APUR,;
							MSD1->CST_IPI, MSD1->COD_ENQ, STR(MSD1->D1_BASEIPI), STR(MSD1->D1_IPI), STR(MSD1->D1_VALIPI), MSD1->CST_PIS, STR(MSD1->VL_BC_PIS), STR(MSD1->ALIQ_PIS_P),;
							STR(MSD1->QUANT_BC_PIS), STR(MSD1->ALIQ_PIS_R), STR(MSD1->VL_PIS), MSD1->CST_COFINS, STR(MSD1->VL_BC_COFINS), STR(MSD1->ALIQ_COFINS_P), STR(MSD1->QUANT_BC_COFINS),;
							STR(MSD1->ALIQ_COFINS_R), STR(MSD1->VL_COFINS), MSD1->D1_ITEMCTA, cDescrCF})

		dbSelectArea("MSD1")
		MSD1->(dbSkip())
	EndDo
	
//================================================ DUPLICATAS ================================================

	cQuery := "SELECT E2_PREFIXO, E2_NUM, E2_FORNECE, (CASE E2_PARCELA WHEN '' THEN 'A' ELSE E2_PARCELA END) AS PARCELA, E2_VENCTO, E2_VALOR "
	cQuery += "FROM " + RETSQLNAME("SE2") + " "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND E2_PREFIXO = '" + QRY->F1_SERIE + "' "
	cQuery += "AND E2_NUM = '" + QRY->F1_DOC + "' "
	cQuery += "AND E2_FORNECE = '" + QRY->F1_FORNECE + "' "
	cQuery += "AND E2_LOJA = '" + QRY->F1_LOJA + "' "
	cQuery += "ORDER BY E2_PARCELA "
	
	If (Select("MSE2") <> 0)
		dbSelectArea("MSE2")
		dbCloseArea()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "MSE2"
	TCSetField("MSE2","E2_VALOR","N",15,3)
	
	dbSelectArea("MSE2")
	dbGoTop()
	While !Eof()
	  
	  //Se for Posto Rosario setar filial como 50, pois eh como esta cadasatrada no TKE.
	  cFilNova:= ""                                                                        
	  If cEmpAnt == "21"
	  	cFilNova := "50"
	  Else
	  	cFilNova := QRY->F1_FILIAL
	  EndIf
	  
	            
      Reclock("TRB",.T.)
	    TRB->FILIAL  := cFilNova
		TRB->PREFIXO := MSE2->E2_PREFIXO
		TRB->NUM     := MSE2->E2_NUM
		TRB->FORNECE := MSE2->E2_FORNECE
		TRB->PARCELA := MSE2->PARCELA
		TRB->VENCTO  := MSE2->E2_VENCTO
		TRB->VALOR   := MSE2->E2_VALOR
		TRB->(MsUnlock())
		
		dbSelectArea("MSE2")
		MSE2->(dbSkip())
	EndDo

	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo


fClose(nHandle)

//================================================ ITENS NOTAS FISCAIS ================================================
nHandle := 0
nTam := 0

cArquivo := "C170_ITENS_NOTAS_FISCAIS.TXT"

If !File(ALLTRIM(cDir)+cArquivo)
	nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Else
	fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Endif

For i:=1 to Len(aItens)
	cLinha := ALLTRIM(aItens[i,01])+";"+ALLTRIM(aItens[i,02])+";"+ALLTRIM(aItens[i,03])+";"+ALLTRIM(aItens[i,04])+";"+ALLTRIM(aItens[i,05])+";"
	cLinha += ALLTRIM(aItens[i,06])+";"+ALLTRIM(aItens[i,07])+";"+ALLTRIM(aItens[i,08])+";"+ALLTRIM(aItens[i,09])+";"+ALLTRIM(aItens[i,10])+";"
	cLinha += ALLTRIM(aItens[i,11])+";"+ALLTRIM(aItens[i,12])+";"+ALLTRIM(aItens[i,13])+";"+ALLTRIM(aItens[i,14])+";"+ALLTRIM(aItens[i,15])+";"
	cLinha += ALLTRIM(aItens[i,16])+";"+ALLTRIM(aItens[i,17])+";"+ALLTRIM(aItens[i,18])+";"+ALLTRIM(aItens[i,19])+";"+ALLTRIM(aItens[i,20])+";"
	cLinha += ALLTRIM(aItens[i,21])+";"+ALLTRIM(aItens[i,22])+";"+ALLTRIM(aItens[i,23])+";"+ALLTRIM(aItens[i,24])+";"+ALLTRIM(aItens[i,25])+";"
	cLinha += ALLTRIM(aItens[i,26])+";"+ALLTRIM(aItens[i,27])+";"+ALLTRIM(aItens[i,28])+";"+ALLTRIM(aItens[i,29])+";"+ALLTRIM(aItens[i,30])+";"
	cLinha += ALLTRIM(aItens[i,31])+";"+ALLTRIM(aItens[i,32])+";"+ALLTRIM(aItens[i,33])+";"+ALLTRIM(aItens[i,34])+";"+ALLTRIM(aItens[i,35])+";"
	cLinha += ALLTRIM(aItens[i,36])+";"+ALLTRIM(aItens[i,37])+";"+ALLTRIM(aItens[i,38])+";"+ALLTRIM(aItens[i,39])+";"+ALLTRIM(aItens[i,40])+";"
	cLinha += ALLTRIM(aItens[i,41])
	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))	
Next i

fClose(nHandle)

//================================================ DUPLICATAS ================================================
nHandle := 0
nTam := 0

cArquivo := "C140_DUPLICATAS.TXT"

If !File(ALLTRIM(cDir)+cArquivo)
	nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Else
	fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
Endif

dbSelectArea("TRB")
dbGoTop()
While !Eof()

	cLinha := ALLTRIM(TRB->FILIAL)+";"+ALLTRIM(TRB->PREFIXO)+";"+ALLTRIM(TRB->NUM)+";"+ALLTRIM(TRB->FORNECE)+";"+ALLTRIM(TRB->PARCELA)+";"+ALLTRIM(TRB->VENCTO)+";"+ALLTRIM(STR(TRB->VALOR))
	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))	

	dbSelectArea("TRB")
	TRB->(dbSkip())
EndDo

fClose(nHandle)

Return       


//================================================ CONHECIMENTO FRETE ================================================
                                                               
Static Function fConhecimento()
	nHandle := 0
	nTam := 0

	cArquivo := "D100_CONHECIMENTO_FRETE.TXT"

	If !File(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
	Else
		fErase(ALLTRIM(cDir)+cArquivo)
		nHandle := MSFCreate(ALLTRIM(cDir)+cArquivo)
	Endif

cQuery := ""
cQuery += "SELECT	F1_FILIAL, '0' AS IND_OPER , '1' AS IND_EMIT ,F1_FORNECE, F1_LOJA, (CASE F1_ESPECIE WHEN 'CTR' THEN '08' ELSE '57' END) AS COD_MOD,"
cQuery += "'00' AS COD_SIT, F1_SERIE AS SER, F1_DOC, F1_CHVNFE, F1_EMISSAO, F1_DTDIGIT, (CASE F1_ESPECIE WHEN 'CTE' THEN '0' ELSE '' END) AS TP_CTE, F1_VALBRUT AS VL_DOC, "
cQuery += "	 F1_DESCONT AS VL_DESC, '2' AS IND_FRT, F1_VALMERC AS VL_SERV,"
cQuery += "	 F1_BASEICM AS VL_BC_ICMS, F1_VALICM AS VL_ICMS, '0' AS VL_NT , D1_CF AS CFOP,D1_PICM AS ALIQ_ICM, B1_CLASFIS AS CST_ICMS "
cQuery += "FROM " + RETSQLNAME("SF1") + " AS F1 ," + RETSQLNAME("SD1") + " AS D1, " + RETSQLNAME("SB1") + " AS B1 "
cQuery += "WHERE F1.D_E_L_E_T_ <> '*' "
cQuery += "AND F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA IN ( "
cQuery += "													SELECT DISTINCT D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA "
cQuery += "													FROM " + RETSQLNAME("SD1") + " "
cQuery += "													WHERE D_E_L_E_T_ <> '*' "
cQuery += "													AND D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "													AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
cQuery += "													AND D1_CF IN('2353','1353') "
cQuery += "													) "
cQuery += "AND D1.D1_FILIAL = F1.F1_FILIAL AND D1.D1_DOC = F1.F1_DOC AND D1.D1_SERIE = F1.F1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE AND D1.D1_LOJA = F1.F1_LOJA "
cQuery += "AND B1.B1_COD = D1.D1_COD "
cQuery += "AND D1.D_E_L_E_T_ <> '*' "                                                                    
cQuery += "AND B1.D_E_L_E_T_ <> '*' "                                                                    
cQuery += "ORDER BY F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA "

If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"
TCSetField("QRY","F1_VALBRUT","N",15,3)
TCSetField("QRY","F1_DESCONT","N",15,3)
TCSetField("QRY","F1_VALMERC","N",15,3)
TCSetField("QRY","F1_BASEICM","N",15,3)
TCSetField("QRY","F1_VALICM","N",15,3)    
TCSetField("QRY","D1_PICM","N",2,3)       


nCount := 0

dbSelectArea("QRY")
dbGoTop()
While !Eof()

	nCount++
	
	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo




dbSelectArea("QRY")
ProcRegua(nCount)
dbGoTop()
While !Eof()

	IncProc("Aguarde...")   
	
	//Se for empresa Posto Rosario, setar filial como 50, pois eh como esta cadastrada dentro do TKE.
	cFilNova := "" 
	If cEmpAnt == "21
		cFilNova	:= "50"
	else
		cFilNova := QRY->F1_FILIAL
	EndIf
	
	
	cLinha := ALLTRIM(cFilNova)+";"+ALLTRIM(QRY->IND_OPER)+";"+ALLTRIM(QRY->IND_EMIT)+";"+ALLTRIM(QRY->F1_FORNECE)+";"+ALLTRIM(QRY->COD_MOD)+";"
	cLinha += ALLTRIM(QRY->COD_SIT)+";"+ALLTRIM(QRY->SER)+";;"+ALLTRIM(QRY->F1_DOC)+";"+ALLTRIM(QRY->F1_CHVNFE)+";"+ALLTRIM(QRY->F1_EMISSAO)+";"
	cLinha += ALLTRIM(QRY->F1_DTDIGIT)+";"+ ALLTRIM(QRY->TP_CTE) + ";;" 
	cLinha += ALLTRIM(STR(QRY->VL_DOC))+";"+ALLTRIM(STR(QRY->VL_DESC))+";"+ALLTRIM(QRY->IND_FRT)+";"
	cLinha += ALLTRIM(STR(QRY->VL_SERV))+";"+ALLTRIM(STR(QRY->VL_BC_ICMS))+";"+ALLTRIM(STR(QRY->VL_ICMS))+";"+ALLTRIM(QRY->VL_NT)+";"+ALLTRIM(QRY->CST_ICMS)+";"
	cLinha += ALLTRIM(QRY->CFOP)+";"+ALLTRIM(STR(QRY->ALIQ_ICM))

	cLinha += chr(13)+chr(10)
	FWrite(nHandle,cLinha,Len(cLinha))

	dbSelectArea("QRY")
	QRY->(dbSkip())
EndDo

fClose(nHandle)

Return                  



