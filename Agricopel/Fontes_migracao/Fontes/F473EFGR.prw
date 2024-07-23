#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF473EFGR บAutor  ณMicrosiga           บ Data ณ  10/22/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto entrada para atualizar Dtdispo e Arqcnab p/cheques   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function F473EFGR(xRegistros)

	LOCAL lPadrao,  cPadrao := "567"        // Incluido Deco 23/08/06 para contabilizacao cfe alexandre/ctb na Reconcilia็ao
	LOCAL cArquivo, cComprobX               // Incluido Deco 23/08/06 para contabilizacao cfe alexandre/ctb na Reconcilia็ao
	LOCAL nTotal	:= 0                    // Incluido Deco 23/08/06 para contabilizacao cfe alexandre/ctb na Reconcilia็ao
	LOCAL nHdlPrv	:= 0                    // Incluido Deco 23/08/06 para contabilizacao cfe alexandre/ctb na Reconcilia็ao

    nE5_VALOR := retirar(cValorMov)
	cE5_VALOR := Transform(nE5_VALOR,"@E 999999999999,99")

	If Mv_par03 == "237"
  	    //cSeqExt  := Substr(PARAMIXB,(198),3)     
  	    cSeqExt  := Substr(PARAMIXB,(196),5)     
	ElseIf Mv_par03 == "001"   
  	    //cSeqExt  := Substr(PARAMIXB,(11),3)     
  	    cSeqExt  := Substr(PARAMIXB,(9),5)     
	ElseIf Mv_par03 == "246"   
  	    //cSeqExt  := Substr(PARAMIXB,(11),3)     
  	    cSeqExt  := Substr(PARAMIXB,(9),5)     
	ElseIf Mv_par03 == "033"   
  	    //cSeqExt  := Substr(PARAMIXB,(11),3)     
  	    cSeqExt  := Substr(PARAMIXB,(9),5)     
	EndIf
      
	//cArqCnab := Substr(MV_PAR01,11,9)+cSeqExt
	cArqCnab := Substr(MV_PAR01,11,7)+cSeqExt
	
	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "   //+RetSqlName("SE5")+" SET E5_DTDISPO = '"+cDataMOv+"' "
	cQuery += "FROM "+RetSqlName("SE5")+" "
	cQuery += "WHERE E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*' "
	cQuery += "AND E5_BANCO = '"+MV_PAR03+"' "
	cQuery += "AND E5_AGENCIA = '"+MV_PAR15+"' "
	cQuery += "AND E5_CONTA = '"+MV_PAR13+"' "
	cQuery += "AND E5_NUMCHEQ = '"+cNumMov+"' "
	cQuery += "AND E5_RECPAG = 'P' "
	cQuery += "AND E5_RECONC <> 'x' "
	cQuery += "AND E5_VALOR = '"+cE5_VALOR+"' "
	cQuery += "AND (E5_TIPODOC = 'CA' OR E5_TIPODOC = 'CH' OR E5_TIPODOC = 'DH')"

	cQuery := ChangeQuery(cQuery)

	If Select("F47301") <> 0
		dbSelectArea("F47301")
		dbCloseArea()
	Endif

	TCQuery cQuery NEW ALIAS "F47301"

	DbSelectArea("F47301")
	DbGoTop()
	While !Eof()

		DbSelectArea("SE5")
		DbGoto(F47301->nIdRecno)
		RecLock("SE5",.F.)
			SE5->E5_DTDISPO := cTod(cDataMov)   
			If alltrim(SE5->E5_ORIGEM) <> "AGR208"
			   SE5->E5_ARQCNAB	:= cArqCnab
			Endif
		MsUnLock("SE5")

		cQuery := ""
		cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "   // Posiciona Cheque SEF para lancamento contabil pela Reconcilia็ao 23/08/2006
		cQuery += "FROM "+RetSqlName("SEF")+" "
		cQuery += "WHERE EF_FILIAL = '"+xFilial("SEF")+"' "
		cQuery += "AND D_E_L_E_T_ <> '*' "
		cQuery += "AND EF_BANCO    = '"+MV_PAR03+"' "
		cQuery += "AND EF_AGENCIA  = '"+MV_PAR15+"' "
		cQuery += "AND EF_CONTA    = '"+MV_PAR13+"' "
		cQuery += "AND EF_NUM      = '"+cNumMov+"' "
		cQuery += "AND EF_VALOR    = '"+cE5_VALOR+"' "
		cQuery += "AND EF_IMPRESS <> 'C' "

		cQuery := ChangeQuery(cQuery)

		If Select("SEF001") <> 0
			dbSelectArea("SEF001")
			dbCloseArea()
		Endif

		TCQuery cQuery NEW ALIAS "SEF001"

		DbSelectArea("SEF001")
		DbGoTop()
		While !Eof()

			DbSelectArea("SEF")
			DbGoto(SEF001->nIdRecno)

			BEGIN TRANSACTION
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica o numero do Lote 											  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Private cLote
				LoteCont( "FIN" )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Monta Lanamento contabil.						  ณ   // Lancto contabil cfe necessidade alexandre/ctb 23/08/2006
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู // lancto contabil ira considerar rotina FINA470 (Reconcilia็ao ou seja cheque compensado)
				cPadrao := '567'
				If (lPadrao := VerPadrao( cPadrao ) .and. 1 == 1 .and. FunName() == "FINA470")
					nHdlPrv:=HeadProva(cLote,"FINA470",Substr(cUsuario,7,6),@cArquivo)
					nTotal+=DetProva(nHdlPrv,cPadrao,"FINA470",cLote)
					RodaProva(nHdlPrv,nTotal)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Envia para Lanamento Contabil 	    	 		    ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//Function cA100Incl(	cArquivo,nHdlPrv,nOpcx,cLoteContabil,lDigita,lAglut,cOnLine,;
					//dData,dReproc,aFlagCTB,aDadosProva,aSeqDiario,aTpSaldo,lSimula,cTabCTK,cTabCT2)
   					cA100Incl(cArquivo,nHdlPrv,3,cLote,iif(2==1,.T.,.F.),.F.,.T.,cTod(cDataMov))         // 1==1 faz tela contabilizacao aparecer
				EndIf                                                                                    // 2==1 faz tela contabilizacao oculta  
				
			END TRANSACTION

		    DbSelectArea("SE5")
		    DbGoto(F47301->nIdRecno)
		    RecLock("SE5",.F.)
			   SE5->E5_LA     := 'S'  // Grava Lancto do cheque reconciliado como lancado contabilmente cfe alexandre 23/08/2006
   	  		   If alltrim(SE5->E5_ORIGEM) <> "AGR208"
			      SE5->E5_RECONC := 'x'  // Grava Indicador cheque reconciliado     Deco 11/01/2008
			   Endif   
			   SE5->E5_DTRECON := dDataBase
		    MsUnLock("SE5")

			DbSelectArea("SEF001")
		    DbSkip()
		End

		DbSelectArea("F47301")
	    DbSkip()
	EndDo

Return .T.

Static Function Retirar(xValorMov)
	lPrim := .T.
	For xx := 1 to Len(xValorMov)
		If Substr(xValorMov,xx,1) <> "." .And.;
			Substr(xValorMov,xx,1) <> ","
			If lPrim
				cValor := Substr(xValorMov,xx,1)
			Else
				cValor := cValor + Substr(xValorMov,xx,1)
			EndIf
			lPrim := .F.
		EndIf
	Next xx
	nValor := Val(cValor)
Return nValor
