#INCLUDE "PROTHEUS.CH"
#INCLUDE  'TOPCONN.CH'
#DEFINE ENTER CHR(13) + CHR(10)

//-------------------------------------------------------------------
/*{Protheus.doc} M103VRET

Ponto de Entrada para leitura do percentual de medição para o sistema gravar o valor no campo E2_RETCNTR.       
Este ponto de entrada funciona em conjunto com o ponto de entrada CN130VRET.        
Obs: Este ponto de entrada só é chamado se o parâmetro MV_CNRETNF estiver como 'S'.

@author TOTVS - Marcos Furtado
@version P11 - State Grid           
@Data - 20/02/2018
*/
//-------------------------------------------------------------------

User Function MT100GE2()
	Local aArea    := GetArea()      
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaCN9 := CN9->(GetArea())
	Local aAreaSC7 := SC7->(GetArea())

	Local cFornece	:= SE2->E2_FORNECE
	Local cLoja		:= SE2->E2_LOJA 
	Local cPrefixo	:= SE2->E2_PREFIXO 
	Local cNum		:= SE2->E2_NUM 
	
	Local nValCmp := 0
	Local nTotCmp := 0

	Local cContaOco 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCO'})]
	Local cContaCre 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XCREDIT'})]
	Local cContaDeb 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XDEBITO'})]
	Local cContaCC 		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_CC'})]	
	Local cContaTip 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMCTA'})]
	Local cXAprov	 	:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XAPROV'})]
	Local cProjDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC05DB'})]
	Local cProjCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC05CR'})]
	Local cContDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC06DB'})]
	Local cContCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC06CR'})]
	Local cTDesDB		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC07DB'})]
	Local cTDesCR		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_EC07CR'})]
	Local cPedido		:= acols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})]
	Local aFiles		:= {}
	Local aSizes		:= {}
	Local cChaveSe2		:= ""
	Local cChaveSf1		:= ""            
	Local _nRetPrc		:= 0
	Local nI, nX
	Private cTargetDir := "\TOTVS_ANEXOS" 

	cChaveSe2 := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+alltrim(E2_FORNECE))
	cChaveSf1 := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	_nRecSe2  := SE2->(Recno())

	cBanco		:= SF1->F1_XBANCOF
	cAgencia	:= SF1->F1_XAGENCF
	cConta		:= SF1->F1_XCONTAF

	SA2->(dbseek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA)) 
	If cBanco == SA2->A2_BANCO .and. cAgencia == SA2->A2_AGENCIA .and. cConta == SA2->A2_NUMCON
		cTpCnt:= "P"
	else
		cTpCnt:= "S"
	Endif

	IF !EMPTY(cChaveSe2)

		if !ExistDir(cTargetDir) 
			MakeDir( cTargetDir )	
		endif
		if !ExistDir(cTargetDir+"\"+cEmpAnt) 
			MakeDir( cTargetDir+"\"+cEmpAnt )	
		endif
		if !ExistDir(cTargetDir+"\"+cEmpAnt+"\"+cFilAnt) 
			MakeDir( cTargetDir+"\"+cEmpAnt+"\"+cFilAnt )	
		endif
		if !ExistDir(cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'FIN') 
			MakeDir( cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'FIN')	
		endif
		if !ExistDir(cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'FIN'+"\"+cChaveSe2) 
			MakeDir( cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'FIN'+"\"+cChaveSe2)	
		endif


		ADir(cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'NF'+"\"+cChaveSf1+"\*.*", aFiles, aSizes)

		cOrigem := cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'NF'+"\"+cChaveSf1+"\"
		cDIRECT := cTargetDir+"\"+cEmpAnt+"\"+cFilAnt+"\"+'FIN'+"\"+cChaveSe2+"\"

		For nx:=1 to len(aFiles)
			__CopyFile( cOrigem+aFiles[nx] , cDIRECT+aFiles[nx] )
		next nx			

	ENDIF
	
	nTotCmp:= u_fRetVrComp("NOTA")

	If nTotCmp <= 0
		For nI := 1 to len(acols)
			nValCmp := acols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_XVALCMP'})]
			nTotCmp := nTotCmp + nValCmp
		Next nI	
	EndIf

	While !SE2->(EOF()) .And. (SE2->(E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA) == cPrefixo+cNum+cFornece+cLoja) 
	
		SE2->(RecLock("SE2",.F.))
		SE2->E2_XCO 		:= cContaOco
		SE2->E2_CREDIT 		:= cContaCre
		SE2->E2_DEBITO		:= cContaDeb
		SE2->E2_CCD			:= cContaCC
		SE2->E2_ITEMD		:= cContaTip
		SE2->E2_XAPROV		:= cXAprov		
		SE2->E2_EC05DB		:= cProjDB
		SE2->E2_EC05CR		:= cProjCR		
		SE2->E2_EC06DB		:= cContDB
		SE2->E2_EC06CR		:= cContCR		
		SE2->E2_EC07DB		:= cTDesDB
		SE2->E2_EC07CR		:= cTDesCR
		SE2->E2_XFORPAG		:= SF1->F1_XFORPAG
		SE2->E2_XHOLD		:= IF(SD1->D1_TES $ GetMV("MV_XTESVC"),IF(SF1->F1_XLIBPAG=="S","N","S"),IF(SF1->F1_XCELNF=="S",IF(SF1->F1_XLIBPAG=="S","N","S"),SF1->F1_XHOLD))
		SE2->E2_FORBCO		:= SF1->F1_XBANCOF
		SE2->E2_FORAGE		:= SF1->F1_XAGENCF
		SE2->E2_FAGEDV		:= SF1->F1_XDAGENF
		SE2->E2_FORCTA		:= SF1->F1_XCONTAF
		SE2->E2_FCTADV		:= SF1->F1_XDCONTF
		SE2->E2_XTPCONT 	:= cTpCnt
		SE2->E2_XVALCMP		:= nTotCmp	
		SE2->E2_MDCONTR		:= Posicione("SC7", 1, xFilial("SC7")+cPedido,"C7_CONTRA")
		SE2->E2_DATAAGE		:= SF1->F1_XDTPGTO
		SE2->(MsUnlock())
		SE2->(DbSkip())    
	Enddo

	SE2->(DbGoto(_nRecSe2))

	cSql2  := " SELECT CND_XPERCR, CN9_TPCAUC, CN9_FLGCAU "             + ENTER
	cSql2  += "   FROM " + RetSqlName( 'CND' ) +" CND, "                + ENTER
	cSql2  += 			   RetSqlName( 'SC7' ) +" SC7, "                + ENTER
	cSql2  += 			   RetSqlName( 'CN9' ) +" CN9 "                + ENTER
	cSql2  += "   WHERE CND_CONTRA    = C7_CONTRA "      + ENTER
	cSql2  += "     and CND_REVISA    = C7_CONTREV "                      + ENTER
	//cSql2  += "     and CND_NUMERO    = C7_PLANILH " + ENTER 		
	cSql2  += "     and CND_NUMMED    = C7_MEDICAO " + ENTER
	cSql2  += "     and CND_PEDIDO    = C7_NUM " + ENTER
	//cSql2  += "     and CND_PEDIDO    = '"+SD1->D1_PEDIDO+"'" + ENTER
	cSql2  += "     and C7_NUM        = '"+SD1->D1_PEDIDO+"'" + ENTER
	cSql2  += "     and C7_ITEM       = '"+SD1->D1_ITEMPC+"'" + ENTER
	cSql2  += "     and CND_FILIAL    = C7_FILIAL " + ENTER
	cSql2  += "     and CND_REVISA    = CN9_REVISA " + ENTER
	cSql2  += "     and CND_CONTRA    = CN9_NUMERO " + ENTER 		
	cSql2  += "     and CND_FILCTR    = CN9_FILIAL " + ENTER 		
	cSql2  += "     and CND.D_E_L_E_T_= '' "                    + ENTER
	cSql2  += "     and C7_FILENT     = '"+XFILIAL("SD1")+"' " + ENTER
	cSql2  += "     and SC7.D_E_L_E_T_= '' "                    + ENTER
	cSql2  += "     and CN9.D_E_L_E_T_= '' "                    + ENTER

	If ( Select("QRYCND") > 0 )
		QRY2->( dbCloseArea() )
	EndIf

	TcQuery cSql2 Alias "QRYCND" New

	If QRYCND->CND_XPERCR > 0 .and. QRYCND->CN9_TPCAUC == "2" .and. QRYCND->CN9_FLGCAU == "1"
		_nRetPrc := QRYCND->CND_XPERCR
	EndIf                      

	If (_nRetPrc > 0) .Or. (_nRetPrc == 0 .And. SE2->E2_RETCNTR > 0)
		SE2->(RecLock("SE2",.F.))

		SE2->E2_SALDO   += SE2->E2_RETCNTR
		SE2->E2_VALOR   += SE2->E2_RETCNTR
		SE2->E2_VLCRUZ  += SE2->E2_RETCNTR

		SE2->E2_RETCNTR := SF1->F1_VALBRUT * _nRetPrc/100
		SE2->E2_SALDO   -= SE2->E2_RETCNTR
		SE2->E2_VALOR   -= SE2->E2_RETCNTR
		SE2->E2_VLCRUZ  -= SE2->E2_RETCNTR

		SE2->(MsUnlock())
	EndIF

	QRYCND->( dbCloseArea() )

	RestArea(aAreaSC7)
	RestArea(aAreaCN9)
	RestArea(aAreaSE2)
	RestArea(aArea) 

Return .T.
