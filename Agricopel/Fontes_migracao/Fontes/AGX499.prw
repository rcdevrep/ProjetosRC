#Include 'FIVEWIN.CH'
#Include 'DLGR230.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} AGX499
- Impressão de conferência cega
@author Leandro F Silveira
@since 04/06/2011
@return sem retorno
@type function
/*/
User Function AGX499(xArraConf)

Local Titulo     := ""
Local cDesc1     := "Emite uma listagem de produtos de NF"
Local cDesc2     := "para conferência Cega"
Local cDesc3     := ""
Local lDic       := .F.
Local lComp      := .F.
Local lFiltro    := .F.
Local WnRel      := "AGX499"
Local nomeprog   := "AGX499"
Private cTamanho := "G"
Private cPerg    := "AGX499"

Private aReturn  := {STR0001, 1, STR0002, 2, 1, "", "", 1}

Private lEnd     := .F.
Private m_pag    := 0
Private nLastKey := 0       

Default xArraConf := {}

CarregarDados(xArraConf)
 
Titulo := "Conferência Cega"

SetPrint("ZZJ",WnRel,"",,cDesc1,cDesc2,cDesc3,lDic,,lComp,cTamanho,,.F.,.F.,"epson.drv",,.T.,WnRel)

If (nLastKey==27)
	Return Nil
Endif

aReturn[5] := 1
SetDefault(aReturn,"ZZJ")

If (nLastKey==27)
	Return Nil
Endif

RptStatus({|lEnd| ImpDet(@lEnd, WnRel, nomeprog, Titulo/*, cNumConf*/, xArraConf)}, "Imprimindo Conferência Cega")     

Set Device To Screen

If (aReturn[5]==1)
	dbCommitAll()
	OurSpool(WnRel)
Endif

MS_FLUSH()

Return Nil

Static Function ImpDet(lEnd, WnRel, nomeprog, Titulo, xArraConf)

Local li     	 := 100
Local cbCont  	 := 0
Local cbText  	 := ''
Local cCabec1 	 := ""
Local cCabec2 	 := "CÓD PRODUTO    DESCRIÇÃO PRODUTO                                  TROCA   LOTE   EMB.  FORNECEDOR           COD. BARRAS       QUANTIDADE             VALIDADE               ENDEREÇO"
Local lIni	     := .T.
Local nChar      := 18
Local nPesoTotal := 0

IF cEmpAnt <> '01'
	cCabec2 := "CÓD PRODUTO    DESCRIÇÃO PRODUTO                                     LOTE    EMB.     FORNECEDOR           COD. BARRAS       QUANTIDADE               VALIDADE                 ENDEREÇO"	
ENDIF

cUltConf := ""
dbSelectArea('QRY_ZZJ')
dbGoTop()
Do While !Eof()    
                     
	//Se for mais de uma impressão
	If len(xArraConf) >  0    
	        
		If 	ALLTRIM(QRY_ZZJ->ZZJ_NUM) <>  cUltConf
			cCabec1 := "NF-SÉRIE: " + StrNotas(QRY_ZZJ->ZZJ_NUM)
			Titulo := MontarTitulo(QRY_ZZJ->ZZJ_NUM)
	   		Li := Cabec(Titulo, cCabec1, cCabec2, nomeprog, cTamanho, nChar,, .F.)

			Li += 3
			@ Li, 000 PSay "CONFERENTE:" + Replicate("_", 50) + "    DIGITADOR:" + Replicate("_", 50) + "     DATA:" + Replicate("_", 30)
			Li++
			Li++
			@ Li,000 PSAY __PrtFatLine()
    	Endif
    Endif
	
	If Li > 60
		
		If !lIni
			Li++
			@ Li,000 PSAY __PrtFatLine()
		Endif
		
		Li := Cabec(Titulo, cCabec1, cCabec2, nomeprog, cTamanho, nChar,, .F.)
		lIni := .F.
		
		Li++
		Li++
	Else
		Li++
		Li++
		Li++
	Endif 
	
	IF cEmpAnt == '01'
		IF QRY_ZZJ->B1_TROCA == 'S'
			cTroca := "SIM"
		ELSEIF QRY_ZZJ->B1_TROCA == 'N'
			cTroca := "NÃO"
		ELSEIF QRY_ZZJ->B1_TROCA == 'P'
			cTroca := "PARCIAL"
		ELSE
			cTroca := "N/I"
		ENDIF

		@ Li, 000 PSay AllTrim(QRY_ZZJ->ZZJ_PRODUT)					                                                  // CÓD PRODUTO
		@ Li, 015 PSay AllTrim(QRY_ZZJ->B1_DESC)  					                                                  // DESCRIÇÃO PRODUTO
		@ Li, 066 PSay cTroca                       				                                                  // TROCA
		@ Li, 074 PSay IIF(QRY_ZZJ->B1_RASTRO = "L", "SIM", "NÃO")                                                    // LOTE
		@ Li, 081 PSay AllTrim(QRY_ZZJ->ZZJ_UM)                                                                       // EMB.
		@ Li, 087 PSay AllTrim(POSICIONE("SA2", 1, xFilial("SA2")+QRY_ZZJ->B1_PROC+QRY_ZZJ->B1_LOJPROC, "A2_NREDUZ")) // FORNECEDOR
		@ Li, 110 PSay QRY_ZZJ->B1_CODBAR                                                                             // CODIGO DE BARRAS
		@ Li, 126 PSay Replicate("_", 20)							                                                  // QUANTIDADE
		@ Li, 149 PSay Replicate("_", 20)							                                                  // VALIDADE		
		@ Li, 174 PSay IIf(!Empty(QRY_ZZJ->ENDERECO), QRY_ZZJ->ENDERECO, Replicate("_", 20))                          // ENDEREÇO
	ELSE
		@ Li, 000 PSay AllTrim(QRY_ZZJ->ZZJ_PRODUT)					                                                  // CÓD PRODUTO
		@ Li, 015 PSay AllTrim(QRY_ZZJ->B1_DESC)					                                                  // DESCRIÇÃO PRODUTO
		@ Li, 069 PSay IIF(QRY_ZZJ->B1_RASTRO = "L", "SIM", "NÃO")	                                                  // LOTE
		@ Li, 077 PSay AllTrim(QRY_ZZJ->ZZJ_UM)    					                                                  // EMB.
		@ Li, 083 PSay AllTrim(POSICIONE("SA2", 1, xFilial("SA2")+QRY_ZZJ->B1_PROC+QRY_ZZJ->B1_LOJPROC, "A2_NREDUZ")) // FORNECEDOR
		@ Li, 109 PSay AllTrim(QRY_ZZJ->B1_CODBAR)                                                                    // CODIGO DE BARRAS
		@ Li, 128 PSay Replicate("_", 20)							                                                  // QUANTIDADE		
		@ Li, 153 PSay Replicate("_", 20)							                                                  // VALIDADE
		@ Li, 178 PSay IIf(!Empty(QRY_ZZJ->ENDERECO), QRY_ZZJ->ENDERECO, Replicate("_", 20))                          // ENDEREÇO
	ENDIF
	
	nPesoTotal += Round(QRY_ZZJ->B1_PESO, 2) * Round(QRY_ZZJ->ZZJ_QTDENF, 2)
	
	cUltConf := QRY_ZZJ->ZZJ_NUM
	
	DbSelectArea('QRY_ZZJ')
	QRY_ZZJ->(DbSkip())  
	                    
	
	If ( ALLTRIM(QRY_ZZJ->ZZJ_NUM) <>  cUltConf  .and. alltrim(cUltConf) <> "") .AND. QRY_ZZJ->(!eof()) 
		Li++
		Li++
		Li++
		Li++
		
		@ Li, 000 PSay " PESO TOTAL:" + Transform(nPesoTotal, "@E 999,999.9999") 
		nPesoTotal := 0 
	Endif
	
	
EndDo

Li++
Li++
Li++
Li++

@ Li, 000 PSay " PESO TOTAL:" + Transform(nPesoTotal, "@E 999,999.9999")

If Select("QRY_ZZJ") <> 0
	dbSelectArea("QRY_ZZJ")
	dbCloseArea()
Endif

Return Nil

Static Function CarregarDados(xArraConf)

cQuery := ""

cQuery += " SELECT ZZJ_NUM,ZZJ_PRODUT, "
cQuery += "        ZZJ_UM,     "
cQuery += "        ZZJ_QTDENF, "

cQuery += "        B1_DESC,   "
cQuery += "        B1_PESO,   "
cQuery += "        B1_CODBAR, "   

IF cEmpAnt == '01'
	cQuery += "        B1_RASTRO,B1_TROCA,B1_PROC,B1_LOJPROC,(B1_XRUA+B1_XBLOCO+B1_XNIVEL+B1_XAPTO) AS  ENDERECO "
ELSE
	cQuery += "        B1_RASTRO,B1_PROC,B1_LOJPROC,(B1_XRUA+B1_XBLOCO+B1_XNIVEL+B1_XAPTO) AS  ENDERECO "
ENDIF

cQuery += " FROM ZZJ010 (NOLOCK), SB1010 (NOLOCK) "    
    
cNumConf := ""
//Se For impressão de Mais de uma conferência  
If len(xArraConf) > 0 
	
    For  _i := 1 to len(xArraConf) 
       	cNumConf += "'"+xArraConf[_i]+"'"+iif(len(xArraConf)==_i,'',",")
    Next _i
	cQuery += " WHERE ZZJ_NUM IN (" + cNumConf + ")"
Else
	cQuery += " WHERE ZZJ_NUM = '" + "'"
Endif          

cQuery += " AND   ZZJ_FILIAL = '" + xFilial("ZZJ") + "'"

cQuery += " AND   B1_FILIAL = ZZJ_FILIAL "
cQuery += " AND   B1_COD = ZZJ_PRODUT "

cQuery += " AND ZZJ010.D_E_L_E_T_ = '' "
cQuery += " AND SB1010.D_E_L_E_T_ = '' "

cQuery += " ORDER BY ZZJ_NUM,ZZJ_SEQUEN "

If Select("QRY_ZZJ") <> 0
	dbSelectArea("QRY_ZZJ")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "QRY_ZZJ"
Return

Static Function MontarTitulo(cNumConf)

cTitulo := ""
cPessoa := ""

dbSelectArea("ZZI")
dbSetOrder(1)
ZZI->(dbSeek(xFilial("ZZI")+cNumConf))

if AllTrim(ZZI->ZZI_TIPO) == "N"
	dbSelectArea("SA2")
	dbSetOrder(1)
	SA2->(dbSeek(xFilial("SA2")+ZZI->ZZI_FORNEC+ZZI->ZZI_LOJA))
	cPessoa := AllTrim(SA2->A2_COD) + "/" + AllTrim(SA2->A2_LOJA) + " - " + AllTrim(SA2->A2_NOME)
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	SA1->(dbSeek(xFilial("SA1")+ZZI->ZZI_FORNEC+ZZI->ZZI_LOJA))
	cPessoa := AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME)
EndIf

cTitulo := " Conferência Cega Nr: " + cNumConf + " - Cliente/Fornecedor: " + cPessoa

Return cTitulo

Static Function StrNotas(cNumConf)

cNotas := ""
cQuery := ""

cQuery += " SELECT ZZK_DOC, "
cQuery += "        ZZK_SERIE "
cQuery += " FROM ZZK010 (NOLOCK) "

cQuery += " WHERE ZZK_NUM = '" + cNumConf + "'"
cQuery += " AND   ZZK_FILIAL = '" + xFilial("ZZK") + "'"
cQuery += " AND   D_E_L_E_T_ = '' "

cQuery += " ORDER BY ZZK_DOC "

If Select("QRY_ZZK") <> 0
	dbSelectArea("QRY_ZZK")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "QRY_ZZK"

dbSelectArea("QRY_ZZK")
While !Eof()
	
	if AllTrim(cNotas) <> ""
		cNotas += " / " + AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
	Else
		cNotas := AllTrim(QRY_ZZK->ZZK_DOC) + "-" + AllTrim(QRY_ZZK->ZZK_SERIE)
	EndIf
	
	dbSkip()
End

Return cNotas
