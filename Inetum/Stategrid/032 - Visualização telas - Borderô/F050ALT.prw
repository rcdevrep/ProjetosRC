#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"   
#DEFINE ENTER CHR(13) + CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±*Ponto de Entrada* F050ALT * Autor *Angelo Henrique    * Data* 09/12/13 *±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±*Descri‡…o *Ponto de entrada para inclusão de condição para legenda     *±±
±±* na alteração do titulo a pagar                                        *±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±*Sintaxe	* F050ALT    												  *±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±* Uso		 * SIGAFIN													  *±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function F050ALT()

	Local aArea 	:= GetArea()
	Local cGrupoAp  := GetMv("MV_XALCFIN")
	Local nOpc		:= PARAMIXB[1]
	Local cDadUsu 	:= __cUserId
	Local cNmTtPai	:= ""
	Local cAliasQry	:= GetNextAlias() 
	Local c := ""
	Local nValor := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC+SE2->E2_XMULTA+SE2->E2_XJUR+SE2->E2_XTAXA-SE2->E2_XDESC
	Private cIdioma := RetAcsName()

	Reclock("SE2" , .F. ) 

		SE2->E2_XVLIQ := nValor 

	MsUnlock()	

	Conout(nOpc)
	FWLogMsg("INFO",,"SGBH",,,"Ponto 00")

	IF (M->E2_ORIGEM = 'FINA050')
		
		if (M->E2_MULTNAT <> '1')
			FWLogMsg("INFO",,"SGBH",,,"Ponto 10")
		
			If fLctoInv('SE2'+xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA)
		
				PcoIniLan("000002")
			    PcoDetLan("000002", "01", "FINA050")      
			    PcoFinLan("000002") 
			EndIF
		else
		
			  DbSelectArea("SEV")
			  DbSetOrder(2)
			  DbSeek(xFilial("SEV")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA)
			  While !Eof() .And. xFilial("SEV")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA = SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)
				   	
				   	If AllTrim(SEV->EV_RATEICC) == '1'
		
				    	DbSelectArea("SEZ")
				    	DbSetOrder(4)
				    	DbSeek(xFilial("SEZ")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ))
				    	While !Eof() .And. xFilial("SEZ")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ) == SEZ->(EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ)
							
							IF fLctoInv('SEZ'+SEZ->(EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ+EZ_CCUSTO))
		
							PcoIniLan("000002")
						    PcoDetLan("000002", "05", "FINA050")
					    	PcoFinLan("000002")
					    	ENDIF
	
					    SEZ->(DbSkip()) 
					   	End
					Else
		
		
							IF fLctoInv('SEV'+SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT+EV_SEQ+EV_NATUREZ))
		
								PcoIniLan("000002")
							    PcoDetLan("000002", "04", "FINA050")
						    	PcoFinLan("000002")
					    	ENDIF
					
					EndIF
					SEV->(DbSkip())
				End
			
		ENDIF
	ENDIF

	if empty(cGrupoAp)
		FWLogMsg("INFO",,"SGBH",,,"Ponto 01")
		FWLogMsg("INFO",,"SGBH",,,"Grupo: "+cGrupoAp)
		RestArea(aArea)
		Return
	endif

	If UPPER(Alltrim(FunName())) $ "STAAGLIMP|FINA050|FINA750"
		FWLogMsg("INFO",,"SGBH",,,"Ponto 11")

//		*'---------------------------------------------------------------------------'*
//		*'Angelo Henrique - Data: 06/12/2013									     '*
//		*'Só ira disparar o workflow e mudar o status do titulo se for confirmação   '*
//		*'---------------------------------------------------------------------------'*

		IF ALLTRIM(SE2->E2_FATURA) == 'NOTFAT'  .AND. ALLTRIM(SE2->E2_NATUREZ) == 'ISS'
			If !EMPTY(SE2->E2_CODBAR) .OR. !EMPTY(SE2->E2_ACRESC) .OR. !EMPTY(SE2->E2_DECRESC)
				Return
			Else
				Iss := .T.
			Endif
		ELSEIF  SE2->E2_PREFIXO == 'AGP' .OR. SE2->E2_PREFIXO == 'AGL'
			If !EMPTY(SE2->E2_CODBAR) .OR. !EMPTY(SE2->E2_ACRESC) .OR. !EMPTY(SE2->E2_DECRESC)
				Return
			Else
				Iss := .T.
			Endif
			
		ELSEIF	!EMPTY(SE2->E2_DATALIB)
			Return
		ENDIF
		
		/*
		if !EMPTY(SE2->E2_DATALIB) .AND. (SE2->E2_PREFIXO <> 'AGP' .OR. SE2->E2_PREFIXO <> 'AGL')
			IF SE2->E2_FATURA == 'NOTFAT'  .AND. SE2->E2_TIPO == 'FT'  .AND. SE2->E2_NATUREZ == 'ISS'
				lIss := .T.
			ELSE
				Return
			ENDIF
		endif 
*/

		If nOpc == 1
			
				FWLogMsg("INFO",,"SGBH",,,"Ponto 02")
		
				Reclock("SE2" , .F. )
		
				SE2->E2_XLIBERA	:= "B"
				SE2->E2_XGRPG 	:= cGrupoAp
				SE2->E2_XSOLIC  := cDadUsu
				SE2->E2_DATALIB := CTOD(" / / ")
		
				If !EMPTY(AllTrim(SE2->E2_XGRPG))
		
						FWLogMsg("INFO",,"SGBH",,,"Ponto 03")
		//				*'-------------------------------------------'*
		//				*'Rotina que gera alçada e dispara o workflow'*
		//				*'-------------------------------------------'*
						U_TOTVSANEXO(cEmpAnt,cFilAnt,"FIN",SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+ALLTRIM(SE2->E2_FORNECE) )
		
						If U_STAA008()
						
							FWLogMsg("INFO",,"SGBH",,,"Ponto 04")
		
							cNmTtPai := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
		
							Reclock("SE2" , .F. )
		
							SE2->E2_XLIBERA	:= "B"
							SE2->E2_XGRPG	:= cGrupoAp
							SE2->E2_DATALIB := CTOD(" / / ")
							SE2->E2_USUALIB	:= ""
		
							MsUnlock()
		
							/*
							//Solicitado pela STATE GRID, os títulos de impostos ja caem liberados e não possuem tratamento.
							*'-------------------------------------------'*
							*'Inicio da alteração nos títulos de impostos'*
							*'-------------------------------------------'*
		
							aAreaE2 := GetArea()
		
							cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA "
							cQuery += " FROM "+RetSqlName("SE2")+" SE2"
							cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
							cQuery += " AND E2_TITPAI = '"+cNmTtPai+"'"
							cQuery += " AND SE2.D_E_L_E_T_ = ' '"
		
							If Select(cAliasQry) > 0
							DbselectArea(cAliasQry)
							(cAliasQry)->(DbcloseArea())
							EndIf
		
							DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		
							While (cAliasQry)->(!Eof())
		
							DbSelectArea("SE2")
							DbSetOrder(1)
							If DbSeek(xFilial("SE2")+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
		
							Reclock("SE2",.F.)
		
							SE2->E2_XLIBERA	:= "B"
							SE2->E2_XGRPG	:= cGrupoAp
							SE2->E2_DATALIB := CTOD(" / / ")
							SE2->E2_USUALIB	:= ""
		
							MsUnlock()
		
							EndIf
		
							(cAliasQry)->(DbSkip())
		
							EndDo
		
							If Select(cAliasQry) > 0
							DbselectArea(cAliasQry)
							(cAliasQry)->(DbcloseArea())
							EndIf
		
		
							RestArea(aAreaE2)
		
							*'-------------------------------------------'*
							*'Fim da alteração nos títulos de impostos	 '*
							*'-------------------------------------------'*
							*/
						Endif
		
		
		
				EndIf
			
		EndIf

	EndIf
    
	RestArea(aArea)

Return
            
/************************************/
Static Function fLctoInv(_cChave)
/************************************/ 

Local _cSql := ""
Local _lRet := .F.

_cSql  := " SELECT AKD_CHAVE  "             			    + ENTER
_cSql  += "   FROM " + RetSqlName( 'AKD' )                  + ENTER                        
_cSql  += "   WHERE AKD_FILIAL = '" + XFILIAL("AKD") +"' "  + ENTER
_cSql  += "     and AKD_CHAVE = '"+_cChave+"' "             + ENTER
_cSql  += "     and AKD_PROCES = '000002' "                 + ENTER
_cSql  += "     and AKD_STATUS = '2' "                      + ENTER
_cSql  += "     and D_E_L_E_T_  = ' ' "                     + ENTER

If ( Select("QRY2") > 0 )
	QRY2->( dbCloseArea() )
EndIf

TcQuery _cSql Alias "QRY2" New

If !QRY2->(EOF())     
	If !Empty(QRY2->AKD_CHAVE)
        	_lRet := .T.               
    Endif         
EndIF
 
Return(_lRet)
