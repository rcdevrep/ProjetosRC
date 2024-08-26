#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*
-------------------------------------------------------------------
{Protheus.doc} User Function XAG0148
    Rotina executada no gatilho do campo DA3_ZZSREM

    @author Rodrigo Colpani
    @since 04/03/2024
    @version 1.00
-------------------------------------------------------------------
*/
User function XAG0148


	//NOSSO NUMERO com base na Série NF-e

	Local _cAliasQry := GetNextAlias()
	Local _cQuery    := ""
	Local cRet := M->DA3_ZZSREM+"0000"
	Local nTam := 8

	IF(M->DA3_ZZBCO == "237")
		nTam := 11
		cRet := M->DA3_ZZSREM+"00000000"
	ELSEIF(M->DA3_ZZBCO == "341")
		nTam := 10
		cRet := M->DA3_ZZSREM+"0000000"
	ELSEIF(M->DA3_ZZBCO == "001")
		nTam := 08
		cRet := M->DA3_ZZSREM+"000000"
	ENDIF

	_cQuery += " SELECT E1_FILIAL, "
	_cQuery += " MAX(E1_NUMBCO) NOSSONUM FROM " + RetSqlName("SE1")
	_cQuery += " WHERE SUBSTRING(E1_NUMBCO,1,3) = '"+M->DA3_ZZSREM+"'  AND D_E_L_E_T_ <> '*' group by E1_FILIAL "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	DbSelectArea(_cAliasQry)
	While !(_cAliasQry)->(Eof())
		cRet := (_cAliasQry)->NOSSONUM
		(_cAliasQry)->(dbSkip())
	End

	cRet := SUBSTRING(cRet,4,nTam)

	cRet := RIGHT(SOMA1(ALLTRIM(cRet)),nTam-3)
	cRet := M->DA3_ZZSREM + cRet

	//M->DA3_ZZNFEM := U_XAG0148E()

Return cRet


/*
-------------------------------------------------------------------
{Protheus.doc} User Function XAG0148A
    Rotina executada no validação do campo DA3_ZZFILI

    @author Rodrigo Colpani
    @since 04/03/2024
    @version 1.00
-------------------------------------------------------------------
*/
User function XAG0148A
	Local lRet := .T.

	IF(!Empty(DA3->DA3_ZZPVIN))
		lRet := .F.
		MSGALERT("Viagem já iniciada")
		RETURN lRet
	ENDIF


	SM0->(dbSeek("01" + M->DA3_ZZFILI))

	M->DA3_ZZNOME := SM0->M0_NOMECOM
	M->DA3_ZZEND  := SM0->M0_ENDCOB
	M->DA3_ZZMUN  := SM0->M0_CIDCOB
	M->DA3_ZZEST  := SM0->M0_ESTCOB
	M->DA3_ZZCEP  := SM0->M0_CEPCOB
	M->DA3_ZZCGC  := SM0->M0_CGC
	M->DA3_ZZINSC := SM0->M0_INSC
	M->DA3_ZZTEL  := SM0->M0_TEL
	M->DA3_ZZSREM := ""
	M->DA3_ZZNFEM := ""
	M->DA3_ZZALMO := ""
	M->DA3_ZZCONT := ""
	M->DA3_ZZBCO  := ""
	M->DA3_ZZAGEN := ""
	M->DA3_ZZSBCT := ""
	M->DA3_ZZCODE := ""
	M->DA3_ZZCART := ""

	M->DA3_ZZALMO := U_XAG0148B() //

	M->DA3_ZZSREM := U_XAG0148D()

	M->DA3_ZZNNEM := ""

	M->DA3_ZZNFEM := U_XAG0148E()



return lRet


/*
-------------------------------------------------------------------
{Protheus.doc} User Function XAG0148A
    Rotina executada no validação de campo do campo DA3_ZZFILI
	Retorno Almoxarifado vinculado a placa

    @author Rodrigo Colpani
    @since 04/03/2024
    @version 1.00
-------------------------------------------------------------------
*/

user function XAG0148B
	Local cRet := " "
	Local _cAliasQry := GetNextAlias()
	Local _cQuery    := "  "

	_cQuery += " select NNR_CODIGO from " + RetSqlName("DA3") + " DA3 inner join " + RetSqlName("NNR") + " NNR on NNR.D_E_L_E_T_ <> '*' AND RTRIM(NNR_DESCRI) = DA3_PLACA "
	_cQuery += " where DA3.D_E_L_E_T_ <> '*' AND NNR_MSBLQL <> '1' AND DA3_PLACA = '"+M->DA3_PLACA+"' "

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	DbSelectArea(_cAliasQry)
	While !(_cAliasQry)->(Eof())

		cRet := (_cAliasQry)->NNR_CODIGO

		(_cAliasQry)->(dbSkip())
	End


return cRet


user function XAG0148Z
	Local lRet := .T.

	IF(!Empty(M->DA3_ZZPVIN))
		lRet := .F.
		RETURN lRet
	ENDIF

return

//8 itau
//10 bb
//11 bradesco

//esta serie já esta sendo utilizada no caminhão X

/*3
------------------v-------------------------------------------------
{Protheus.doc} User Function XAG0148A
    Rotina executada no validação do campo DA3_ZZBCO

    @author Rodrigo Colpani
    @since 04/03/2024
    @version 1.00
-------------------------------------------------------------------
*/


user function XAG0148C
	Local lRet := .T.

	dbSelectArea("SEE")
	dbsetorder(1)
	If SEE->( dbSeek(xFilial("SEE") + M->DA3_ZZBCO))
		While SEE->( !Eof() )
			IF(SEE->EE_XGERABO == 'S')

				M->DA3_ZZAGEN := SEE->EE_AGENCIA
				M->DA3_ZZCONT := SUBSTR(SEE->EE_CONTA,1,7)
				M->DA3_ZZSBCT := SUBSTR(SEE->EE_CONTA,8,1)

				M->DA3_ZZNNEM := U_XAG0148() //NOSSO NUMERO
				return .T.
			ENDIF
			SEE->(DbSkip())
		END
	ENDIF

return lRet




/*3
------------------v-------------------------------------------------
{Protheus.doc} User Function XAG0148D
    Rotina executada no validação do campo DA3_ZZBCO

    @author Rodrigo Colpani
    @since 04/03/2024
    @version 1.00
-------------------------------------------------------------------
*/


user function XAG0148D

	Local cRet := " "
	Local _cAliasQry := GetNextAlias()
	Local _cQuery    := "  "



	_cQuery += "  "

	_cQuery += "SELECT MIN(X5_CHAVE) SERIE FROM "+RetSQLName("SX5")+" (NOLOCK) A  "
	_cQuery += "WHERE A.D_E_L_E_T_ <> '*' "
	_cQuery += "AND X5_TABELA = 'SN' "
	_cQuery += "AND X5_DESCRI LIKE '%=SPED%' "
	_cQuery += "AND X5_FILIAL = '"+M->DA3_ZZFILI+"' "

	_cQuery += "AND NOT EXISTS (SELECT 1 FROM "+RetSQLName("SF2")+" (NOLOCK) B  "
	_cQuery += "  WHERE B.D_E_L_E_T_ <> '*' "
	_cQuery += "AND B.F2_FILIAL = A.X5_FILIAL "
	_cQuery += "AND B.F2_SERIE = A.X5_CHAVE) "
	_cQuery += "AND NOT EXISTS (SELECT 1 FROM "+RetSQLName("DA3")+" (NOLOCK) C "
	_cQuery += "   WHERE C.D_E_L_E_T_ <> '*' "
	_cQuery += "AND DA3_ZZFILI = X5_FILIAL "
	_cQuery += "AND DA3_ZZSREM = X5_CHAVE "
	_cQuery += ") "
	_cQuery += " "

	/*_cQuery += " select SERIE from  "
	_cQuery += "(select MAX(F2_SERIE)+1 SERIE from " + RetSqlName("SF2") + " SF2  "
	_cQuery += "where F2_EMISSAO >= '20221101'  "
	_cQuery += "AND F2_SERIE NOT IN ('IS','NFD', 'AJT') AND F2_FILIAL = '"+M->DA3_ZZFILI+"' AND SF2.D_E_L_E_T_ <> '*'   "
	_cQuery += "group by F2_FILIAL ) tab  "
	_cQuery += "LEFT JOIN " + RetSqlName("DA3") + " DA3 on DA3_ZZSREM = SERIE AND D_E_L_E_T_ <> '*' "
	_cQuery += "where DA3_FILIAL IS NULL "*/

	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	DbSelectArea(_cAliasQry)
	While !(_cAliasQry)->(Eof())

		cRet := ALLTRIM((_cAliasQry)->SERIE)

		(_cAliasQry)->(dbSkip())
	End


return cRet



/*
select SERIE from 
(select MAX(F2_SERIE)+1 SERIE from SF2010 SF2 
where F2_EMISSAO >= '20231101' 
AND F2_SERIE NOT IN ('IS','NFD') AND F2_FILIAL = '17' AND SF2.D_E_L_E_T_ <> '*'  
group by F2_FILIAL ) tab 
LEFT JOIN DA3010 DA3 on DA3_ZZSREM = SERIE AND D_E_L_E_T_ <> '*'
where DA3_FILIAL IS NULL
*/



user function XAG0148E
	Local cNF := "        "
	Local _cAliasQry := GetNextAlias()
	Local _cQuery    := "  "

	//_cQuery += " Select MAX(F2_DOC) F2_DOC from "+RetSqlName("SF2")+" SF2 where F2_SERIE = '"+M->DA3_ZZSREM+"' AND SF2.D_E_L_E_T_ <> '*' AND F2_FILIAL = '"+M->DA3_ZZFILI+"' "

	_cQuery += "select MAX(ULTIMANF) ULTIMANF from (select  MAX(C5_ZZNFEMB) ULTIMANF, 'SC5' ORIGEM FROM "+RetSQLName("SC5")+" SC5 (NOLOCK)  "
	_cQuery += "where C5_FILIAL = '"+M->DA3_ZZFILI+"' AND C5_ZZSREMB = '"+M->DA3_ZZSREM+"' AND SC5.D_E_L_E_T_ <> '*' "
	_cQuery += "UNION  "
	_cQuery += "select MIN(D9_DOC) ULTIMANF, 'SD9' ORIGEM from "+RetSQLName("SD9")+" SD9 (NOLOCK) "
	_cQuery += "where D9_FILIAL = '"+M->DA3_ZZFILI+"' AND D9_SERIE = '"+M->DA3_ZZSREM+"' AND D9_DTUSO = '' AND SD9.D_E_L_E_T_ <> '*' "
	_cQuery += "group by D9_SERIE ) TAB "


	TCQuery _cQuery NEW ALIAS (_cAliasQry)

	DbSelectArea(_cAliasQry)
	While !(_cAliasQry)->(Eof())

		cNF := (_cAliasQry)->ULTIMANF

		(_cAliasQry)->(dbSkip())
	End

	IF(EMPTY(cNF))
		cNF := "000000001"
	ELSE
		cNF := SOMA1(cNF)
	ENDIF

return cNF
